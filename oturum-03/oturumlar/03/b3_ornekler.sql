-- Oturum 3 | Blok 3 örnekleri: hat bilgisi değişince
-- DuckDB'de çalışır: .read oturumlar/03/b3_ornekler.sql
-- Örnekler iki hatlık küçük bir boyut tablosunda çalışır: 54E ve 500T. Şubat'ta listeye D2 hattı da gelir.

-- Örnek 1: Ocak'ın boyutu. Her satır 1 Ocak'tan beri geçerli ve güncel.
CREATE OR REPLACE TABLE ornek_boyut AS
SELECT line_name AS hat, any_value(line) AS guzergah,
       DATE '2024-01-01' AS gecerli_baslangic,
       DATE '9999-12-31' AS gecerli_bitis, true AS guncel
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
  AND line_name IN ('54E', '500T')
GROUP BY line_name;
SELECT * FROM ornek_boyut ORDER BY hat;

-- Örnek 2: Şubat'ın hat listesi. Güzergah adındaki tırnak ve baştaki, sondaki boşluk temizlenir.
-- 500T'nin güzergah değişikliği eğitim için eklenmiş bir örnektir.
CREATE OR REPLACE TABLE ornek_subat AS
SELECT line_name AS hat,
       any_value(trim(replace(line, '"', ''))) AS guzergah
FROM lake.silver.toplu_ulasim
WHERE transition_date >= DATE '2024-02-01'
  AND line_name IN ('54E', '500T', 'D2')
GROUP BY line_name;
UPDATE ornek_subat SET guzergah = 'TUZLA-TOPKAPI-CEVIZLIBAG'
WHERE hat = '500T';
SELECT * FROM ornek_subat ORDER BY hat;

-- Örnek 3: MERGE. Şubat'ın her satırı boyuttaki karşılığıyla eşleşir ve üç işten biri yapılır.
-- Tip 1: temizlenmiş Ocak adı Şubat adıyla aynıysa fark yalnızca yazımdır; ad üzerine yazılır.
-- Tip 2: temizlenmiş ad bile farklıysa güzergah değişmiştir; eski sürüm 31 Ocak'ta kapanır.
-- Boyutta karşılığı olmayan Şubat satırı yeni bir hattır; 1 Şubat'tan geçerli olarak eklenir.
MERGE INTO ornek_boyut AS d
USING ornek_subat AS s
ON d.hat = s.hat
WHEN MATCHED AND trim(replace(d.guzergah, '"', '')) = s.guzergah   -- Tip 1
    THEN UPDATE SET guzergah = s.guzergah
WHEN MATCHED AND trim(replace(d.guzergah, '"', '')) <> s.guzergah  -- Tip 2
    THEN UPDATE SET gecerli_bitis = DATE '2024-01-31', guncel = false
WHEN NOT MATCHED                                                    -- yeni hat
    THEN INSERT VALUES (s.hat, s.guzergah,
                        DATE '2024-02-01', DATE '9999-12-31', true);

-- Örnek 4: Tip 2'nin yeni sürümü. Kapanan hattın Şubat güzergahı 1 Şubat'tan geçerli olarak eklenir.
INSERT INTO ornek_boyut
SELECT hat, guzergah, DATE '2024-02-01', DATE '9999-12-31', true
FROM ornek_subat
WHERE hat IN (SELECT hat FROM ornek_boyut WHERE NOT guncel);
SELECT * FROM ornek_boyut ORDER BY hat, gecerli_baslangic;

-- Örnek 5: sürümlü boyutla JOIN. Her gün, o gün geçerli olan sürümle eşleşir.
-- Sonuç her sürümün kaç günle eşleştiğini sayar.
SELECT d.hat, d.guzergah, d.gecerli_baslangic,
       count(DISTINCT s.transition_date) AS gun
FROM lake.silver.toplu_ulasim AS s
JOIN ornek_boyut AS d
  ON s.line_name = d.hat
 AND s.transition_date
     BETWEEN d.gecerli_baslangic AND d.gecerli_bitis
GROUP BY ALL
ORDER BY d.hat, d.gecerli_baslangic;
