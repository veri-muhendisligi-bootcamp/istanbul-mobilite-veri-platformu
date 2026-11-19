-- Oturum 2 | U2.3 API yanıtlarından MERGE
-- make sql oturumunda çalışır: .read oturumlar/02/u2_3_merge.sql
-- veri/api/trafik klasöründeki üç JSON dosyası, trafik API'sinin 1 Şubat 2024 için kayıtlı yanıtlarıdır.
-- Dosya adının ilk 16 karakteri yanıtın çekildiği zamanı verir.
-- Dosya yeniden çalıştığında lake.silver.trafik tablosu silinir ve boş olarak yeniden kurulur.

-- 1. Yanıtın yapısı: kayıt sayısı ve ilk kayıt
SELECT result.total AS toplam, result.records[1] AS ilk_kayit
FROM read_json('veri/api/trafik/2024-02-02T01-10_sayfa1.json');

-- 2. Tipli görünüm: her kayıt bir satırdır, değerler doğru tipe çevrilir.
CREATE OR REPLACE VIEW trafik_api AS
SELECT r.DATE_TIME::TIMESTAMP AS DATE_TIME,
       r.LATITUDE::DOUBLE AS LATITUDE,
       r.LONGITUDE::DOUBLE AS LONGITUDE,
       r.GEOHASH,
       r.MINIMUM_SPEED::BIGINT AS MINIMUM_SPEED,
       r.MAXIMUM_SPEED::BIGINT AS MAXIMUM_SPEED,
       r.AVERAGE_SPEED::BIGINT AS AVERAGE_SPEED,
       r.NUMBER_OF_VEHICLES::BIGINT AS NUMBER_OF_VEHICLES,
       parse_filename(filename) AS _kaynak_dosya,
       strptime(left(parse_filename(filename), 16), '%Y-%m-%dT%H-%M') AS _cekim_zamani
FROM (SELECT unnest(result.records) AS r, filename
      FROM read_json('veri/api/trafik/*.json', filename = true));

SELECT _kaynak_dosya, _cekim_zamani, count(*) AS kayit
FROM trafik_api
GROUP BY ALL
ORDER BY 1;

-- 3. Hedef tablo
DROP TABLE IF EXISTS lake.silver.trafik;
CREATE TABLE lake.silver.trafik (
    DATE_TIME TIMESTAMP,
    LATITUDE DOUBLE,
    LONGITUDE DOUBLE,
    GEOHASH VARCHAR,
    MINIMUM_SPEED BIGINT,
    MAXIMUM_SPEED BIGINT,
    AVERAGE_SPEED BIGINT,
    NUMBER_OF_VEHICLES BIGINT,
    _kaynak_dosya VARCHAR,
    _cekim_zamani TIMESTAMP)
PARTITIONED BY (month(DATE_TIME));

-- 4. Kontrol makrosu: her MERGE'ten sonra FROM yukleme_kontrol('lake.silver.trafik'); ile çalışır.
-- satir: tablodaki satır, anahtar: tekil anahtar, snapshot: tablonun snapshot sayısı,
-- fark: 1 Şubat satırlarından kaynak CSV dosyasında karşılığı olmayanların sayısı. Doğru yüklemede fark 0 olur.
CREATE OR REPLACE MACRO yukleme_kontrol(tablo) AS TABLE
SELECT (SELECT count(*) FROM query_table(tablo)) AS satir,
       (SELECT count(DISTINCT (DATE_TIME, GEOHASH)) FROM query_table(tablo)) AS anahtar,
       (SELECT count(*) FROM iceberg_snapshots(tablo)) AS snapshot,
       (SELECT count(*) FROM (
            SELECT DATE_TIME, LATITUDE, LONGITUDE, GEOHASH,
                   MINIMUM_SPEED, MAXIMUM_SPEED, AVERAGE_SPEED, NUMBER_OF_VEHICLES
            FROM query_table(tablo)
            WHERE DATE_TIME >= TIMESTAMP '2024-02-01' AND DATE_TIME < TIMESTAMP '2024-02-02'
            EXCEPT
            SELECT * FROM read_csv('veri/trafik_2024_02.csv.gz')
            WHERE DATE_TIME < TIMESTAMP '2024-02-02')) AS fark;

FROM yukleme_kontrol('lake.silver.trafik');

-- 5. MERGE kalıbı: /* */ ile işaretli üç yer doldurulur, sorgu iki kez çalışır.
-- MERGE INTO lake.silver.trafik AS h
-- USING (
--     SELECT * FROM trafik_api
--     QUALIFY row_number() OVER (
--         PARTITION BY /* anahtar kolonlar */
--         ORDER BY /* kazanan kayıt kuralı */) = 1
-- ) AS k
-- ON /* h ile k arasında anahtar eşitliği */
-- WHEN MATCHED AND k._cekim_zamani > h._cekim_zamani THEN UPDATE BY NAME
-- WHEN NOT MATCHED THEN INSERT BY NAME;
