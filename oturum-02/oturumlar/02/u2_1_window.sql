-- Oturum 2 | U2.1 Window fonksiyonları
-- make sql oturumunda çalışır: .read oturumlar/02/u2_1_window.sql
-- ham_ocak tablosu Oturum 1'de kuruldu. Tablo yoksa ilk komut onu Ocak dosyasından yeniden kurar (yaklaşık 40 saniye).
CREATE TABLE IF NOT EXISTS ham_ocak AS
SELECT * FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz');

-- Saatlik hat tablosu: bir satır, bir saatte bir hattın yolculuk toplamıdır.
CREATE OR REPLACE TABLE hat_saatlik AS
SELECT transition_date + transition_hour::INTEGER * INTERVAL 1 HOUR AS zaman,
       line_name AS hat,
       sum(number_of_passage)::BIGINT AS yolculuk
FROM ham_ocak
GROUP BY ALL;

SELECT count(*) AS satir FROM hat_saatlik;

-- Örnek: 15 Ocak 08:00'de hatların sırası
SELECT zaman, hat, yolculuk,
       row_number() OVER (PARTITION BY zaman ORDER BY yolculuk DESC) AS sira
FROM hat_saatlik
WHERE zaman = TIMESTAMP '2024-01-15 08:00'
ORDER BY sira
LIMIT 5;
