-- Oturum 3 | Hazırlık
-- Bugünün bütün örnekleri ve uygulamaları ödevde kurulan silver tablosunu okur: lake.silver.toplu_ulasim.
-- make sql ile açılan DuckDB'de çalışır: .read oturumlar/03/hazirlik.sql
-- Tablolar doğruysa dosya hiçbir şeyi değiştirmez ve birkaç saniyede biter.
-- Silver tablosu yoksa ya da sayıları farklıysa dosya onu bronze tablosundan yeniden kurar; bu durumda dosya bir dakika kadar sürer.
-- Dosya ödev dosyalarına dokunmaz.

-- 1. Bronze tablosu: yoksa ay partition'ıyla ve Ocak dosyasıyla kurulur
CREATE TABLE IF NOT EXISTS lake.bronze.toplu_ulasim
PARTITIONED BY (month(transition_date)) AS
SELECT * EXCLUDE (filename),
       parse_filename(filename) AS _kaynak_dosya,
       now() AS _yukleme_zamani
FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz', filename = true);

-- 2. Ocak dosyası bronze tablosunda tam bir kez bulunur
BEGIN TRANSACTION;
DELETE FROM lake.bronze.toplu_ulasim
WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz'
  AND (SELECT count(*) FROM lake.bronze.toplu_ulasim
       WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz') <> 17283355;
INSERT INTO lake.bronze.toplu_ulasim
SELECT * EXCLUDE (filename), parse_filename(filename), now()
FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz', filename = true)
WHERE NOT EXISTS (SELECT 1 FROM lake.bronze.toplu_ulasim
                  WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz');
COMMIT;

-- 3. Şubat dosyası bronze tablosunda tam bir kez bulunur
BEGIN TRANSACTION;
DELETE FROM lake.bronze.toplu_ulasim
WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz'
  AND (SELECT count(*) FROM lake.bronze.toplu_ulasim
       WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz') <> 16958106;
INSERT INTO lake.bronze.toplu_ulasim
SELECT * EXCLUDE (filename), parse_filename(filename), now()
FROM read_csv('veri/toplu_ulasim_2024_02.csv.gz', filename = true)
WHERE NOT EXISTS (SELECT 1 FROM lake.bronze.toplu_ulasim
                  WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz');
COMMIT;

-- 4. Silver tablosu: yoksa ödevdeki gibi kurulur; parça satırlar toplanır
CREATE TABLE IF NOT EXISTS lake.silver.toplu_ulasim
PARTITIONED BY (month(transition_date)) AS
SELECT * EXCLUDE (number_of_passage, number_of_passenger, _kaynak_dosya, _yukleme_zamani),
       sum(number_of_passage)::BIGINT AS number_of_passage,
       sum(number_of_passenger)::BIGINT AS number_of_passenger
FROM lake.bronze.toplu_ulasim
GROUP BY ALL;

-- 5. Satır sayısı farklıysa ya da toplam, tekrar gönderilen iki günün bölünmesiyle düzelmeyecek bir değerse
--    silver tablosu boşaltılır ve bronze'dan yeniden doldurulur.
--    Kabul edilen toplamlar: iki gün de bölünmüş, ikisi de bölünmemiş, yalnızca 10 Ocak ya da yalnızca 14 Şubat bölünmüş.
BEGIN TRANSACTION;
DELETE FROM lake.silver.toplu_ulasim
WHERE (SELECT count(*) FROM lake.silver.toplu_ulasim) <> 16779679
   OR (SELECT sum(number_of_passage) FROM lake.silver.toplu_ulasim)
      NOT IN (421347288, 436495305, 429284951, 428557642);
INSERT INTO lake.silver.toplu_ulasim
SELECT * EXCLUDE (number_of_passage, number_of_passenger, _kaynak_dosya, _yukleme_zamani),
       sum(number_of_passage)::BIGINT,
       sum(number_of_passenger)::BIGINT
FROM lake.bronze.toplu_ulasim
WHERE NOT EXISTS (SELECT 1 FROM lake.silver.toplu_ulasim)
GROUP BY ALL;
COMMIT;

-- 6. Tekrar gönderilen iki gün: toplamı iki kat kalmışsa ikiye bölünür
UPDATE lake.silver.toplu_ulasim
SET number_of_passage = number_of_passage // 2,
    number_of_passenger = number_of_passenger // 2
WHERE transition_date = DATE '2024-01-10'
  AND (SELECT sum(number_of_passage) FROM lake.silver.toplu_ulasim
       WHERE transition_date = DATE '2024-01-10') = 14420708;
UPDATE lake.silver.toplu_ulasim
SET number_of_passage = number_of_passage // 2,
    number_of_passenger = number_of_passenger // 2
WHERE transition_date = DATE '2024-02-14'
  AND (SELECT sum(number_of_passage) FROM lake.silver.toplu_ulasim
       WHERE transition_date = DATE '2024-02-14') = 15875326;

-- 7. Sonuç: tek satır
SELECT CASE
         WHEN (SELECT count(*) FROM lake.silver.toplu_ulasim) = 16779679
          AND (SELECT sum(number_of_passage) FROM lake.silver.toplu_ulasim) = 421347288
         THEN 'HAZIR: silver tablosu 16.779.679 satır, 421.347.288 yolculuk'
         ELSE 'EKSİK: silver tablosunun sayıları beklenenden farklı, sohbete yazın'
       END AS durum;
