-- Oturum 3 | Uygulama 1: her hat için tek satır
-- 1. ___ yazan üç yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/03/u3_1_hat_tablosu.sql
-- Sonuç Ocak yolculuğunu yol türüne göre gösterir. Üç yol türünün yolculuğunu sohbete yazın.

-- Ocak'ın hat toplamları (örnek dosyasındaki tabloyla aynı)
CREATE OR REPLACE TABLE hat_toplam AS
SELECT line_name, sum(number_of_passage) AS yolculuk
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY line_name;

-- Adım 1: hat tablosu. Her hat tek satır olur; yol türü olarak hattın en sık görülen yol türü alınır.
CREATE OR REPLACE TABLE hat AS
SELECT line_name,
       any_value(line) AS guzergah,          -- any_value: gruptaki değerlerden biri
       mode(road_type) AS yol_turu           -- mode: gruptaki en sık görülen değer
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY ___;                                -- ① Her hat tek satır olsun: hangi kolona göre gruplanır?

-- Adım 2: anahtar tekil mi? İki sayı aynı olmalı.
SELECT count(*) AS satir, count(DISTINCT line_name) AS hat
FROM hat;

-- Adım 3: yol türüne göre Ocak yolculuğu
CREATE OR REPLACE TABLE yol_turu_ocak AS
SELECT h.yol_turu, count(*) AS hat_sayisi, sum(t.yolculuk) AS yolculuk
FROM hat_toplam AS t
JOIN hat AS h ON ___                         -- ② İki tabloyu bağlayan koşul: iki tablonun hat kodu eşit
GROUP BY ___;                                -- ③ Sonuçta her yol türü bir satır olsun: hangi kolon?

SELECT * FROM yol_turu_ocak ORDER BY yolculuk DESC;

-- Adım 4: toplam testi. JOIN hiçbir yolculuğu çoğaltmadıysa 922 hat ve 208.447.924 yolculuk çıkar.
SELECT sum(hat_sayisi) AS hat, sum(yolculuk) AS yolculuk
FROM yol_turu_ocak;

-- İleri görev: Şubat'ta çalışıp Ocak'ın hat tablosunda olmayan hatlar. Aşağıdaki /* ve */ satırlarını silin,
-- ④ numaralı boşluğu doldurun. IN bir değerin listede olup olmadığına bakar; listeyi bir alt sorgu da verebilir.
/*
SELECT DISTINCT line_name
FROM lake.silver.toplu_ulasim
WHERE transition_date >= DATE '2024-02-01'
  AND line_name ___ (SELECT line_name FROM hat)   -- ④ Listede olmayanlar: IN'in önüne hangi kelime gelir?
ORDER BY line_name;
*/
