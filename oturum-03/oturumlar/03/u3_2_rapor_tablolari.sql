-- Oturum 3 | Uygulama 2: raporun tabloları
-- 1. ___ yazan üç yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/03/u3_2_rapor_tablolari.sql
-- Sonuç Ocak'ta hafta içi günlük ortalaması en yüksek beş hattı gösterir. En üstteki hattı ve ortalamasını sohbete yazın.

-- Hat boyutu: her hat bir satır (Uygulama 1'deki tablo, gold katmanında)
DROP TABLE IF EXISTS lake.gold.dim_hat;
CREATE TABLE lake.gold.dim_hat AS
SELECT line_name AS hat,
       any_value(line) AS guzergah,
       mode(road_type) AS yol_turu
FROM lake.silver.toplu_ulasim
WHERE transition_date < DATE '2024-02-01'
GROUP BY line_name;

-- Tarih boyutu: Ocak ve Şubat'ın her günü bir satır
DROP TABLE IF EXISTS lake.gold.dim_tarih;
CREATE TABLE lake.gold.dim_tarih AS
SELECT CAST(gun AS DATE) AS gun,
       ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba',
        'Perşembe', 'Cuma', 'Cumartesi']
           [dayofweek(gun) + 1] AS gun_adi,
       dayofweek(gun) IN (0, 6) AS hafta_sonu,
       CAST(gun AS DATE) = DATE '2024-01-01' AS tatil
FROM generate_series(DATE '2024-01-01', DATE '2024-02-29',
                     INTERVAL 1 DAY) AS t(gun);

-- Fact tablosu: Ocak, bir satır bir hattın bir günü
DROP TABLE IF EXISTS lake.gold.fact_hat_gunluk;
CREATE TABLE lake.gold.fact_hat_gunluk AS
WITH hat_gun AS (
    SELECT transition_date AS gun, line_name AS hat,
           sum(number_of_passage) AS yolculuk,
           sum(number_of_passenger) AS yolcu
    FROM lake.silver.toplu_ulasim
    WHERE transition_date < DATE '2024-02-01'
    GROUP BY ___                             -- ① Bir satır bir hattın bir günü olsun: hangi iki kolon?
)
SELECT * FROM hat_gun;

-- Toplam testi: iki sayı da 208.447.924 olmalı
SELECT (SELECT sum(yolculuk) FROM lake.gold.fact_hat_gunluk) AS fact,
       (SELECT sum(number_of_passage) FROM lake.silver.toplu_ulasim
        WHERE transition_date < DATE '2024-02-01') AS silver;

-- Rapor: Ocak'ta hafta içi günlük ortalaması en yüksek beş hat
SELECT d.hat, d.guzergah, round(avg(f.yolculuk)) AS ortalama
FROM lake.gold.fact_hat_gunluk AS f
JOIN lake.gold.dim_tarih AS t ON ___         -- ② Fact ile tarih boyutunu bağlayan koşul
JOIN lake.gold.dim_hat AS d ON f.hat = d.hat
WHERE NOT t.___ AND NOT t.tatil              -- ③ Hafta sonunu gösteren kolon
GROUP BY d.hat, d.guzergah
ORDER BY ortalama DESC
LIMIT 5;

-- Metriğin tek tanımı: aylık hat yolculuğu. Raporlar ve AI asistanları bu görünümden okur.
CREATE OR REPLACE VIEW hat_aylik AS
SELECT month(f.gun) AS ay, f.hat, d.guzergah, sum(f.yolculuk) AS yolculuk
FROM lake.gold.fact_hat_gunluk AS f
JOIN lake.gold.dim_hat AS d ON f.hat = d.hat
GROUP BY ALL;

SELECT * FROM hat_aylik ORDER BY yolculuk DESC LIMIT 5;

-- İleri görev: Ocak yolculuğunun yüzde kaçını en kalabalık 10 hat taşıyor? Aşağıdaki /* ve */ satırlarını silin,
-- ④ numaralı boşluğu doldurun. CTE'nin adı sorguda iki kez kullanılır.
/*
WITH sirali AS (
    SELECT hat, yolculuk, row_number() OVER (ORDER BY yolculuk DESC) AS sira
    FROM hat_aylik
    WHERE ay = 1
)
SELECT round(100.0 * (SELECT sum(yolculuk) FROM sirali WHERE sira <= ___)   -- ④ Kaç hat?
             / (SELECT sum(yolculuk) FROM sirali), 1) AS yuzde;
*/
