# Oturum 1 | Çalışma dosyası

Bu dosya Oturum 1'in uygulamalarını tarif eder. Her uygulamada ilk deneme anlatımdan önce gelir ve bloğun sonundaki çözümle karşılaştırılır.

`make sql` komutu DuckDB'yi lab kataloğuna bağlı olarak açar ve bütün sorgular bu oturumda çalışır. Bir SQL dosyası DuckDB içinde `.read` komutuyla çalışır; örnek: `.read oturumlar/01/u1_1_ham_veri_kesfi.sql`.

## U1.1 Ham veri keşfi (20 dakika)

- Soru: Ocak 2024 toplu ulaşım dosyasında bir satırı hangi kolonlar tekil kılıyor?
- `make sql` ile DuckDB'yi açıyor, `.read oturumlar/01/u1_1_ham_veri_kesfi.sql` ile başlangıç dosyasını çalıştırıyorsunuz. Dosya kolonları, satır sayısını ve ilk on satırı gösteriyor.
- Ekrana sığmayan kolonlar `…` ile gizleniyor. `.last` komutu ilk on satırı bütün kolonlarıyla açıyor. Sağ ok tuşuyla kaydırıyor, `q` ile çıkıyorsunuz.
- İlk on satıra bakıp bir satırı tekil kıldığını düşündüğünüz kolonları seçiyorsunuz. Tahmininizi aşağıdaki sorguyla sınıyorsunuz. `kolon_1, kolon_2` yerine kendi seçtiğiniz kolonları yazıyorsunuz:

```
SELECT count(*) FROM (
  SELECT DISTINCT kolon_1, kolon_2
  FROM ham_ocak);
```

- Sorguyu DuckDB'ye doğrudan yazıyorsunuz. Başlangıç dosyasını yeniden çalıştırmak tabloyu baştan kurar.
- Sorgunun verdiği sayı satır sayısına eşitse seçtiğiniz kolonlar bir satırı tekil kılıyor. Küçükse bazı kombinasyonlar birden fazla satırda tekrar ediyor.
- Seçtiğiniz kolonları ve sorgunun verdiği sayıyı Zoom sohbetine yazıyorsunuz.
- Erken bitirenler bronze katmanında işaretlenmesi gereken bir anomali arıyor.

## U1.2 Bronze katmanı (25 dakika)

- Ocak 2024 dosyasını `lake.bronze.toplu_ulasim` adlı bir Iceberg tablosuna yüklüyorsunuz. Şubat dosyası aynı tabloya çözüm bölümünde eklenir.
- Başlangıç kodu `oturumlar/01/u1_2_bronze.sql` dosyasındadır.
- Partition dönüşümünü (ay, gün ya da ulaşım türü) siz seçiyorsunuz.
- Deneme bittiğinde tablonun bir snapshot'ı olur; Şubat yüklemesinden sonra snapshot sayısı ikiye çıkar. Her kaynak dosyanın satır sayısı tabloda aynen yer alır ve her satır `_kaynak_dosya` ile `_yukleme_zamani` kolonlarını taşır.
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
