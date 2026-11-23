-- Oturum 2 | Uygulama 3: sorgu ne kadar veri okuyor?
-- 1. ___ yazan iki yeri doldurun, kaydedin ve çalıştırın: .read oturumlar/02/u2_3_okunan_veri.sql
-- 2. Her planın üstündeki Summary kutusunda Data Read satırını okuyun.
-- Üç sorgunun Data Read değerini sohbete yazın.

-- Sorgu 1: 15 Ocak, bütün kolonlar
EXPLAIN ANALYZE
SELECT * FROM lake.bronze.toplu_ulasim
WHERE transition_date = DATE '2024-01-15';

-- Sorgu 2: 15 Ocak, yalnızca yolculuk toplamı
EXPLAIN ANALYZE
SELECT sum(___) FROM lake.bronze.toplu_ulasim                  -- ① Yolculuk sayısını taşıyan kolon
WHERE transition_date = DATE '2024-01-15';

-- Sorgu 3: bütün günler, yalnızca M2 hattının yolculuk toplamı
EXPLAIN ANALYZE
SELECT sum(number_of_passage) FROM lake.bronze.toplu_ulasim
WHERE ___ = 'M2';                                               -- ② Hat kodunu taşıyan kolon

-- İleri görev: yalnızca Şubat. Aşağıdaki /* ve */ satırlarını silin ve Total Files Read satırına bakın.
/*
EXPLAIN ANALYZE
SELECT sum(number_of_passage) FROM lake.bronze.toplu_ulasim
WHERE transition_date >= DATE '2024-02-01';
*/
