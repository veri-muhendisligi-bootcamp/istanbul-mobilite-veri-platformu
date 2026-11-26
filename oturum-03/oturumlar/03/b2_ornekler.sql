-- Oturum 3 | Blok 2 örnekleri: raporun tabloları
-- DuckDB'de çalışır: .read oturumlar/03/b2_ornekler.sql
-- Örnekler silver tablosunun Ocak satırlarını okur; tablo kurmaz.

-- Örnek 1: silver tablosunun bir satırı neyi anlatıyor? Ocak'ın satır sayısı ve hat-gün sayısı
SELECT count(*) AS satir,
       count(DISTINCT (transition_date, line_name)) AS hat_gun
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01';

-- Örnek 2: CTE. Önce hat_gun adlı ara sonuç kurulur: her hattın günlük toplamı. Sonra o ara sonuç okunur.
WITH hat_gun AS (
    SELECT transition_date AS gun, line_name AS hat,
           sum(number_of_passage) AS yolculuk
    FROM lake.silver.toplu_ulasim
    WHERE transition_date < DATE '2024-02-01'
    GROUP BY transition_date, line_name
)
SELECT count(*) AS satir, sum(yolculuk) AS yolculuk
FROM hat_gun;

-- Örnek 3: toplam testi. Silver'ın Ocak toplamı, Örnek 2'deki toplamla aynı olmalı.
SELECT sum(number_of_passage) AS yolculuk
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01';

-- Örnek 4: tarih boyutunun ilk yedi günü. Ocak ve Şubat'ın her günü bir satır.
SELECT CAST(gun AS DATE) AS gun,
       ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba',
        'Perşembe', 'Cuma', 'Cumartesi']
           [dayofweek(gun) + 1] AS gun_adi,
       dayofweek(gun) IN (0, 6) AS hafta_sonu,
       CAST(gun AS DATE) = DATE '2024-01-01' AS tatil
FROM generate_series(DATE '2024-01-01', DATE '2024-02-29',
                     INTERVAL 1 DAY) AS t(gun)
LIMIT 7;
