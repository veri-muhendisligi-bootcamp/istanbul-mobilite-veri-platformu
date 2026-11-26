-- Oturum 3 | Uygulama 4: hatta göre sıralı tablo
-- 1. ___ yazan üç yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/03/u3_4_hat_sirasi.sql
-- Dosya önce silver tablosunun hatta göre sıralı bir kopyasını kurar; bu adım 15-20 saniye sürer.
-- Üç planın Data Read ve Row Groups Scanned değerlerini sohbete yazın.

-- Adım 1: silver tablosunun bir kopyası; satırlar hat koduna göre sıralı yazılır
DROP TABLE IF EXISTS lake.silver.toplu_ulasim_hat;
CREATE TABLE lake.silver.toplu_ulasim_hat AS
SELECT * FROM lake.silver.toplu_ulasim
ORDER BY ___;                                -- ① Satırlar hangi kolona göre sıralanır?

-- Adım 2: M2'nin yolculuğu, tarihe göre bölünmüş silver tablosundan
EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim
WHERE line_name = 'M2';

-- Adım 3: M2'nin yolculuğu, hatta göre sıralı kopyadan
EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM ___                                     -- ② Hatta göre sıralı kopyanın adı
WHERE line_name = 'M2';

-- Adım 4: Ocak'ın yolculuğu, hatta göre sıralı kopyadan
EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim_hat
WHERE ___;                                   -- ③ Yalnızca Ocak: örnek dosyasının üçüncü örneğindeki koşul

-- İleri görev: aya göre bölünmüş ve hatta göre sıralı tablo. Aşağıdaki /* ve */ satırlarını silin, ④ numaralı boşluğu doldurun.
-- Tablo aya göre bölünür, her ayın içinde satırlar hatta göre sıralı yazılır.
/*
DROP TABLE IF EXISTS lake.silver.toplu_ulasim_ay_hat;
CREATE TABLE lake.silver.toplu_ulasim_ay_hat
PARTITIONED BY (___) AS                      -- ④ Silver tablosundaki gibi: ay partition'ı
SELECT * FROM lake.silver.toplu_ulasim
ORDER BY line_name;

EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim_ay_hat
WHERE line_name = 'M2';

EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim_ay_hat
WHERE transition_date < DATE '2024-02-01';
*/
