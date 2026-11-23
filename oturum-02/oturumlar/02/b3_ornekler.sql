-- Oturum 2 | Blok 3 örnekleri: sorgu ne kadar veri okuyor?
-- DuckDB'de çalışır: .read oturumlar/02/b3_ornekler.sql
-- Her planın üstündeki Summary kutusunda Data Read satırına bakın.

-- Örnek 1: bütün tablo, bütün kolonlar
EXPLAIN ANALYZE
SELECT * FROM lake.bronze.toplu_ulasim;

-- Örnek 2: bütün tablo, tek kolon
EXPLAIN ANALYZE
SELECT sum(number_of_passage) FROM lake.bronze.toplu_ulasim;
