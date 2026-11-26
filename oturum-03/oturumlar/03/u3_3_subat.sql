-- Oturum 3 | Uygulama 3: Şubat geldi
-- 1. ___ yazan üç yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/03/u3_3_subat.sql
-- Sonuç 500T hattının Ocak ve Şubat yolculuğunu o ayın güzergahıyla gösterir. İki satırı sohbete yazın.

-- Adım 0: Ocak'ın hat boyutu, geçmişi tutacak üç kolonla, ve Ocak'ın fact tablosu (Uygulama 2'nin tabloları)
DROP TABLE IF EXISTS lake.gold.dim_hat;
CREATE TABLE lake.gold.dim_hat AS
SELECT line_name AS hat,
       any_value(line) AS guzergah,
       mode(road_type) AS yol_turu,
       DATE '2024-01-01' AS gecerli_baslangic,
       DATE '9999-12-31' AS gecerli_bitis,
       true AS guncel
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY line_name;

DROP TABLE IF EXISTS lake.gold.fact_hat_gunluk;
CREATE TABLE lake.gold.fact_hat_gunluk AS
SELECT transition_date AS gun, line_name AS hat,
       sum(number_of_passage) AS yolculuk,
       sum(number_of_passenger) AS yolcu
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY transition_date, line_name;

-- Adım 1: Şubat'ın hat listesi. Güzergah adındaki tırnak ve baştaki, sondaki boşluk temizlenir.
-- 500T'nin güzergah değişikliği eğitim için eklenmiş bir örnektir.
CREATE OR REPLACE TABLE hat_subat AS
SELECT line_name AS hat,
       any_value(trim(replace(line, '"', ''))) AS guzergah,
       mode(road_type) AS yol_turu
FROM lake.silver.toplu_ulasim
WHERE transition_date >= DATE '2024-02-01'
GROUP BY line_name;

UPDATE hat_subat SET guzergah = 'TUZLA-TOPKAPI-CEVIZLIBAG' WHERE hat = '500T';

-- Adım 2: MERGE ile hat boyutu güncellenir. Örnek dosyasının üçüncü örneğindeki üç iş:
-- yazım farkı üzerine yazılır (Tip 1), güzergahı değişen hattın eski sürümü kapanır (Tip 2), yeni hat eklenir.
MERGE INTO lake.gold.dim_hat AS d
USING hat_subat AS s
ON ___                                       -- ① Boyut satırı ile Şubat satırı hangi kolonla eşleşir?
WHEN MATCHED AND trim(replace(d.guzergah, '"', '')) = s.guzergah   -- Tip 1
    THEN UPDATE SET guzergah = s.guzergah
WHEN MATCHED AND trim(replace(d.guzergah, '"', '')) <> s.guzergah  -- Tip 2
    THEN UPDATE SET gecerli_bitis = ___, guncel = false             -- ② Eski sürüm hangi gün sona erer?
WHEN NOT MATCHED                                                    -- yeni hat
    THEN INSERT VALUES (s.hat, s.guzergah, s.yol_turu,
                        DATE '2024-02-01', DATE '9999-12-31', true);

-- Tip 2'nin yeni sürümü: kapanan hattın Şubat güzergahı 1 Şubat'tan geçerli olarak eklenir
INSERT INTO lake.gold.dim_hat
SELECT hat, guzergah, yol_turu, DATE '2024-02-01', DATE '9999-12-31', true
FROM hat_subat
WHERE hat IN (SELECT hat FROM lake.gold.dim_hat WHERE NOT guncel);

-- Boyutun son hali: 936 satır, 935 hat, 935 güncel satır
SELECT count(*) AS satir, count(DISTINCT hat) AS hat, count_if(guncel) AS guncel
FROM lake.gold.dim_hat;

-- Adım 3: Şubat'ın fact satırları eklenir
INSERT INTO lake.gold.fact_hat_gunluk
SELECT transition_date, line_name, sum(number_of_passage), sum(number_of_passenger)
FROM lake.silver.toplu_ulasim
WHERE transition_date >= DATE '2024-02-01'
GROUP BY transition_date, line_name;

-- Adım 4: metriğin tek tanımı güncellenir. Her gün, o gün geçerli olan sürümle eşleşir.
CREATE OR REPLACE VIEW hat_aylik AS
SELECT month(f.gun) AS ay, f.hat, d.guzergah, sum(f.yolculuk) AS yolculuk
FROM lake.gold.fact_hat_gunluk AS f
JOIN lake.gold.dim_hat AS d
  ON f.hat = d.hat
 AND ___                                     -- ③ Günün tarihi, sürümün geçerlilik aralığında olmalı
GROUP BY ALL;

SELECT * FROM hat_aylik WHERE hat = '500T' ORDER BY ay;

-- Toplam testi: 1.845 satır ve 421.347.288 yolculuk
SELECT count(*) AS satir, sum(yolculuk) AS yolculuk FROM hat_aylik;

-- İleri görev: Ocak'ta çalışıp Şubat listesinde olmayan hatlar. Aşağıdaki /* ve */ satırlarını silin,
-- ④ numaralı boşluğu doldurun. Bu hatların sürümü için ne yapılmalı? Cevabınızı sohbete yazın.
/*
SELECT hat, guzergah
FROM lake.gold.dim_hat
WHERE hat NOT IN (SELECT hat FROM ___)       -- ④ Şubat'ın hat listesi hangi tabloda?
ORDER BY hat;
*/
