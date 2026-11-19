# Kayıtlı API yanıtları

`trafik` klasöründeki üç JSON dosyası, Saatlik Trafik Yoğunluk Veri Seti'nin 1 Şubat 2024 kayıtlarını taşır. Dosyalar lab için `veri/trafik_2024_02.csv.gz` dosyasından üretildi. Biçimleri, İBB Açık Veri Portalı'nın kullandığı CKAN yazılımının `datastore_search` yanıtıdır: kayıtlar `result.records` dizisinde durur, değerler metin olarak gelir, bir sayfada en çok 32.000 kayıt bulunur. `resource_id` alanındaki `lab-trafik-2024-02` değeri dosyaların lab üretimi olduğunu gösterir.

| Dosya | Çekim zamanı | Kayıt | İçerik |
|---|---|---|---|
| `2024-02-02T01-10_sayfa1.json` | 2 Şubat 2024 01:10 | 32.000 | İlk çekimin 1. sayfası |
| `2024-02-02T01-10_sayfa2.json` | 2 Şubat 2024 01:10 | 24.426 | İlk çekimin 2. sayfası |
| `2024-02-03T01-10_sayfa1.json` | 3 Şubat 2024 01:10 | 7.185 | 21:00, 22:00 ve 23:00 saatlerinin ikinci çekimi |

Dosya adının ilk 16 karakteri yanıtın çekildiği zamanı verir. İlk çekimde son üç saatin (21:00-23:00) bazı ölçümleri henüz yoktur, bazılarının da araç sayısı eksiktir. İkinci çekim bu üç saati kaynağın tamamladığı haliyle verir. Lab kopyası bu durumu eğitim için canlandırır.

Kaynak: İBB Açık Veri Portalı (data.ibb.gov.tr), İBB Açık Veri Lisansı.
