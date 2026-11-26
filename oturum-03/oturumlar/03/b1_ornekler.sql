-- Oturum 3 | Blok 1 örnekleri: hat bilgisini ayrı bir tabloya almak
-- DuckDB'de çalışır: .read oturumlar/03/b1_ornekler.sql
-- Örnekler silver tablosunu okur ve iki küçük yerel tablo kurar: hat_listesi ve hat_toplam.

-- Örnek 1: 54E hattının güzergah adı tabloda kaç satırda yazıyor?
SELECT line_name, line, count(*) AS satir
FROM lake.silver.toplu_ulasim
WHERE line_name = '54E'
GROUP BY ALL
ORDER BY satir DESC;

-- Örnek 2: Ocak'taki hatlar ayrı bir tabloda; her farklı satır bir kez
CREATE OR REPLACE TABLE hat_listesi AS
SELECT DISTINCT line_name, line, road_type
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01';

SELECT count(*) AS satir,
       count(DISTINCT line_name) AS hat
FROM hat_listesi;

-- Örnek 3: anahtar tekil mi? Birden fazla satırla gelen hat ve satırları.
-- HAVING, GROUP BY'dan sonra grupları süzer.
SELECT line_name, count(*) AS adet
FROM hat_listesi
GROUP BY line_name
HAVING count(*) > 1;

SELECT * FROM hat_listesi
WHERE line_name = 'M5' ORDER BY road_type;

-- Örnek 4: Ocak'ın hat toplamları; her hat bir satır
CREATE OR REPLACE TABLE hat_toplam AS
SELECT line_name, sum(number_of_passage) AS yolculuk
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY line_name;

SELECT count(*) AS satir, sum(yolculuk) AS yolculuk
FROM hat_toplam;

-- Örnek 5: JOIN. Hat toplamları hat listesiyle birleşince satır sayısı ve toplam
SELECT count(*) AS satir, sum(t.yolculuk) AS yolculuk
FROM hat_toplam AS t
JOIN hat_listesi AS h ON t.line_name = h.line_name;
