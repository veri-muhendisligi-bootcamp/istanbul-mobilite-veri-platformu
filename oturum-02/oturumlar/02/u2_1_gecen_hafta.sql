-- Oturum 2 | U2.1 Uygulama: geçen haftaya göre değişim
-- kac_satir yerine sayı yazılıp dosya kaydedildikten sonra make sql oturumunda çalışır:
-- .read oturumlar/02/u2_1_gecen_hafta.sql
-- hat_saatlik tablosu oturumlar/02/u2_1_window.sql ile kurulur.
WITH gunluk AS (
  SELECT zaman::DATE AS gun,
         sum(yolculuk)::BIGINT AS yolculuk
  FROM hat_saatlik GROUP BY ALL)
SELECT gun, yolculuk,
  lag(yolculuk, kac_satir)
    OVER (ORDER BY gun) AS gecen_hafta
FROM gunluk
ORDER BY gun;
