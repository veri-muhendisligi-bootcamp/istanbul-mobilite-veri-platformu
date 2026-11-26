-- Oturum 3 | Blok 4 örnekleri: sorgu ne kadar veri okuyor?
-- DuckDB'de çalışır: .read oturumlar/03/b4_ornekler.sql
-- EXPLAIN ANALYZE sorguyu çalıştırır ve sonucu değil, sorgu planını yazar.
-- Her planın Summary kutusunda Data Read, Table Scan kutusunda Total Files Read ve Row Groups Scanned satırlarına bakın.
-- Örnek 5 fact tablosunu okur; tablo Uygulama 2 ya da 3 çalıştıktan sonra vardır.

-- Örnek 1: silver tablosu, bütün kolonlar
EXPLAIN ANALYZE
SELECT * FROM lake.silver.toplu_ulasim;

-- Örnek 2: silver tablosu, tek kolon
EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim;

-- Örnek 3: tek kolon, yalnızca Ocak
EXPLAIN ANALYZE
SELECT sum(number_of_passage)
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01';

-- Örnek 4: Ocak'ın hat toplamları silver tablosundan
EXPLAIN ANALYZE
SELECT line_name, sum(number_of_passage)
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY line_name;

-- Örnek 5: aynı toplamlar fact tablosundan
EXPLAIN ANALYZE
SELECT hat, sum(yolculuk)
FROM lake.gold.fact_hat_gunluk
WHERE gun < DATE '2024-02-01'
GROUP BY hat;
