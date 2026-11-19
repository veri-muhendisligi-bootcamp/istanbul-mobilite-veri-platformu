-- silver.toplu_ulasim | Oturumlar arası görev 02
-- Kaynak: lake.bronze.toplu_ulasim. Dosya make sql içinde .read sql/silver/toplu_ulasim.sql ile çalışır.
-- Dosya her çalıştığında tablo silinir ve baştan kurulur; iki çalıştırma aynı tabloyu verir.
-- Sorgunun adımları görev belgesinde tarif edilir:
--   1. Tekrar gönderilen günler
--   2. Tekrar gönderilen günde satırların yarısı
--   3. Hat kodlarının düzeltilmesi
--   4. İstanbul saatiyle zaman kolonu
--   5. Yayımlanan boyutlara göre toplam
DROP TABLE IF EXISTS lake.silver.toplu_ulasim;
