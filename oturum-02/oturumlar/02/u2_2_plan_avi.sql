-- Oturum 2 | U2.2 Plan avı
-- make sql oturumunda çalışır: .read oturumlar/02/u2_2_plan_avi.sql
-- Dosya Ocak verisinden iki karşılaştırma tablosu kurar; iki tablonun kurulması yaklaşık bir dakika sürer.
-- Dosya yeniden çalıştığında iki tablo silinir ve baştan kurulur.
DROP TABLE IF EXISTS lake.bronze.deneme_gun;
DROP TABLE IF EXISTS lake.bronze.deneme_hat;

-- 1. Gün partition'lı tablo: her gün ayrı bir veri dosyasında durur.
CREATE TABLE lake.bronze.deneme_gun
PARTITIONED BY (day(transition_date)) AS
SELECT * FROM ham_ocak;

-- 2. Partition'sız ve hat koduna göre sıralı yazılmış tablo.
CREATE TABLE lake.bronze.deneme_hat AS
SELECT * FROM ham_ocak
ORDER BY line_name;

-- Üç tablonun veri dosyası sayısı
SELECT 'toplu_ulasim' AS tablo, count(*) AS veri_dosyasi
FROM iceberg_metadata('lake.bronze.toplu_ulasim')
UNION ALL
SELECT 'deneme_gun', count(*) FROM iceberg_metadata('lake.bronze.deneme_gun')
UNION ALL
SELECT 'deneme_hat', count(*) FROM iceberg_metadata('lake.bronze.deneme_hat');

-- Ölçülecek iki sorgu aşağıda. Her sorgu üç tabloda çalışır; tablo adı toplu_ulasim,
-- deneme_gun ve deneme_hat olarak değiştirilir.
-- Sorgu 1: 15 Ocak'ın yolcu toplamı
EXPLAIN ANALYZE
SELECT sum(number_of_passenger)
FROM lake.bronze.toplu_ulasim
WHERE transition_date = DATE '2024-01-15';

-- Sorgu 2: 34 hattının Ocak ayındaki yolcu toplamı
-- EXPLAIN ANALYZE
-- SELECT sum(number_of_passenger)
-- FROM lake.bronze.toplu_ulasim
-- WHERE line_name = '34' AND transition_date < DATE '2024-02-01';
