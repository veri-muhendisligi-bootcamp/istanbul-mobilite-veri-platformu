# Oturum 1 | Çalışma dosyası

Bu dosya Oturum 1'in uygulamalarını tarif eder. Her uygulamada ilk deneme anlatımdan önce gelir ve bloğun sonundaki çözümle karşılaştırılır.

`make sql` komutu DuckDB'yi lab kataloğuna bağlı olarak açar ve bütün sorgular bu oturumda çalışır. Bir SQL dosyası DuckDB içinde `.read` komutuyla çalışır; örnek: `.read oturumlar/01/u1_1_ham_veri_kesfi.sql`.

## U1.1 Ham veri keşfi (20 dakika)

- Ocak 2024 toplu ulaşım dosyasında bir satırı tekil kılan kolon kombinasyonunu ve bronze katmanında işaretlenecek en az bir anomaliyi arıyorsunuz.
- Başlangıç kodu `oturumlar/01/u1_1_ham_veri_kesfi.sql` dosyasındadır.
- Aday anahtarın kolonlarına ve işaretlenecek anomaliye siz karar veriyorsunuz.
- Uygulamanın sonunda aday anahtarın kolon listesi, bu anahtarla tekrar eden satır sayısı, bir anomali ve onu gösteren sorgu elinizde olur.
- Aday anahtar kolonlarını ve bulduğunuz anomaliyi Zoom sohbetine yazıyorsunuz.
- Erken bitirenler `product_kind` ve `transfer_type` kolonlarındaki beklenmeyen değerleri inceler.

## U1.2 Bronze katmanı (25 dakika)

- Ocak 2024 dosyasını `lake.bronze.toplu_ulasim` adlı bir Iceberg tablosuna yüklüyorsunuz. Şubat dosyası aynı tabloya çözüm bölümünde eklenir.
- Başlangıç kodu `oturumlar/01/u1_2_bronze.sql` dosyasındadır.
- Partition dönüşümünü (ay, gün ya da ulaşım türü) siz seçiyorsunuz.
- Uygulamanın sonunda tablonun iki snapshot'ı olur. Her kaynak dosyanın satır sayısı tabloda aynen yer alır ve her satır `_kaynak_dosya` ile `_yukleme_zamani` kolonlarını taşır.
- Partition seçiminizi, satır sayısını ve snapshot sayısını Zoom sohbetine yazıyorsunuz.
- Erken bitirenler `iceberg_metadata` ile partition seçiminin veri dosyası sayısına etkisini inceler.

## U1.3 Mimari karar kaydı (20 dakika)

- Projenin ilk mimari karar kaydını `docs/kararlar/0001-mimari.md` dosyasında taslak olarak yazıyorsunuz.
- Kayıt batch ve streaming bileşenlerini, gecikme hedefini, tablo formatını ve kataloğu belirler.
- Uygulamanın sonunda kayıtta Durum satırı ve dolu dört bölüm (Bağlam, Karar, Gerekçe, Sonuçlar) bulunur. Gerekçe en az bir ölçülebilir ihtiyaca dayanır.
- Kararın tek cümlelik özetini Zoom sohbetine yazıyorsunuz.
- Erken bitirenler ikinci bir mimariyle maliyet ve yönetişim karşılaştırmasını karar kaydına "Elenen seçenekler" alt başlığıyla ekler.

## Oturumlar arası görev (30-45 dakika, Oturum 2'ye kadar)

- Trafik yoğunluğu verisinin Ocak 2024 dosyası (`veri/trafik_2024_01.csv.gz`) `lake.bronze.trafik` tablosuna yüklenir. Tablo bronze kararına uyar: kaynağı değiştirmez, `_kaynak_dosya` ve `_yukleme_zamani` kolonlarını taşır.
- `lake.bronze.toplu_ulasim` tablosunda Ocak ve Şubat dosyaları yer alır.
- Karar kaydı dört bölümüyle tamamlanır.
- Kontrol komutu `make odev-kontrol N=01` olur. Bütün adımlar TAMAM olduğunda betik kanıt kodunu yazar; kod ve depo bağlantısı Tech İstanbul platformundaki göreve yüklenir.

## Ortam çalışmazsa

Uygulamalar eğitmen ekranından takip edilir ve aynı görevler oturumdan sonra tamamlanır.
