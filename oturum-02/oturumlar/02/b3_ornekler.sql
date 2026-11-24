-- Oturum 2 | Blok 3 örnekleri: tekrar mı, parça mı?
-- DuckDB'de çalışır: .read oturumlar/02/b3_ornekler.sql

-- Örnek 1: sıradan bir gün, 3 Ocak. Her kolonu aynı olan satırlardan üç örnek.
-- adet: aynı satırın tabloda kaç kez geçtiği
SELECT line_name, town, transition_hour, number_of_passage, adet
FROM (SELECT *, count(*) AS adet
      FROM ham_ocak
      WHERE transition_date = DATE '2024-01-03'
      GROUP BY ALL)
WHERE adet > 1
ORDER BY adet DESC, line_name
LIMIT 3;

-- Örnek 2: 3 Ocak'ın satır sayısı ve yolculuğu; önce bütün satırlar, sonra DISTINCT ile tekil satırlar
SELECT count(*) AS satir, sum(number_of_passage) AS yolculuk
FROM ham_ocak
WHERE transition_date = DATE '2024-01-03';

SELECT count(*) AS satir, sum(number_of_passage) AS yolculuk
FROM (SELECT DISTINCT *
      FROM ham_ocak
      WHERE transition_date = DATE '2024-01-03');

-- Örnek 3: 10 Ocak'ın yolculuğu, düzeltmeden önce ve sonra
SELECT sum(number_of_passage) AS once,
       sum(number_of_passage) // 2 AS sonra
FROM ham_ocak
WHERE transition_date = DATE '2024-01-10';

-- Örnek 4: her dosya bronze tablosuna kaç kez yüklenmiş?
SELECT _kaynak_dosya, count(DISTINCT _yukleme_zamani) AS yukleme, count(*) AS satir
FROM lake.bronze.toplu_ulasim
GROUP BY ALL
ORDER BY _kaynak_dosya;
