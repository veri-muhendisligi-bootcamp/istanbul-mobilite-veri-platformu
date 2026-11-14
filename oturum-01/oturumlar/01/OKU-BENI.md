# Oturum 1 | Çalışma dosyası

Bu dosya Oturum 1'in uygulamalarını tarif eder. Her uygulamada ilk deneme anlatımdan önce gelir ve bloğun sonundaki çözümle karşılaştırılır.

`make sql` komutu DuckDB'yi lab kataloğuna bağlı olarak açar ve bütün sorgular bu oturumda çalışır. Bir SQL dosyası DuckDB içinde `.read` komutuyla çalışır; örnek: `.read oturumlar/01/u1_1_ham_veri_kesfi.sql`.

## U1.1 Ham veri keşfi (20 dakika)

- Görev: Ocak 2024 toplu ulaşım dosyasında bir satırı tekil kılan kolon kombinasyonunu ve bronze katmanında işaretlenecek en az bir anomaliyi bulmak.
- Başlangıç kodu: `oturumlar/01/u1_1_ham_veri_kesfi.sql`
- Karar: aday anahtarın kolonları ve işaretlenecek anomali.
- Beklenen çıktı: aday anahtarın kolon listesi, bu anahtarla tekrar eden satır sayısı, bir anomali ve onu gösteren sorgu.
- Zoom sohbetine: aday anahtar kolonları ve bulduğunuz anomali.
- İleri görev: `product_kind` ve `transfer_type` kolonlarındaki beklenmeyen değerler.

## U1.2 Bronze katmanı (25 dakika)

- Görev: Ocak 2024 dosyasını `lake.bronze.toplu_ulasim` adlı bir Iceberg tablosuna yüklemek; çözüm bölümünde Şubat dosyasını aynı tabloya eklemek.
- Başlangıç kodu: `oturumlar/01/u1_2_bronze.sql`
- Karar: partition dönüşümü (ay, gün ya da ulaşım türü).
- Beklenen çıktı: iki snapshot'ı olan bir tablo. Her kaynak dosyanın satır sayısı tabloda aynen yer alır ve her satır `_kaynak_dosya` ile `_yukleme_zamani` kolonlarını taşır.
- Zoom sohbetine: partition seçimi, satır sayısı ve snapshot sayısı.
- İleri görev: `iceberg_metadata` ile partition seçiminin veri dosyası sayısına etkisi.

## U1.3 Mimari karar kaydı (20 dakika)

- Görev: `docs/kararlar/0001-mimari.md` dosyasında projenin ilk mimari karar kaydının taslağı.
- Karar: batch ve streaming bileşenleri, gecikme hedefi, tablo formatı ve katalog.
- Beklenen çıktı: Durum satırı ve dört bölümü (Bağlam, Karar, Gerekçe, Sonuçlar) dolu bir karar kaydı; gerekçede en az bir ölçülebilir ihtiyaç.
- Zoom sohbetine: kararın tek cümlelik özeti.
- İleri görev: ikinci bir mimariyle maliyet ve yönetişim karşılaştırması, karar kaydındaki "Elenen seçenekler" alt başlığında.

## Oturumlar arası görev (30-45 dakika, Oturum 2'ye kadar)

- Trafik yoğunluğu verisinin Ocak 2024 dosyası (`veri/trafik_2024_01.csv.gz`) `lake.bronze.trafik` tablosuna yüklenir. Tablo bronze kararına uyar: kaynağı değiştirmez, `_kaynak_dosya` ve `_yukleme_zamani` kolonlarını taşır.
- `lake.bronze.toplu_ulasim` tablosunda Ocak ve Şubat dosyaları yer alır.
- Karar kaydı dört bölümüyle tamamlanır.
- Kontrol komutu `make odev-kontrol N=01` olur. Bütün adımlar TAMAM olduğunda betik kanıt kodunu yazar; kod ve depo bağlantısı Tech İstanbul platformundaki göreve yüklenir.

## Ortam çalışmazsa

Uygulamalar eğitmen ekranından takip edilir ve aynı görevler oturumdan sonra tamamlanır.
