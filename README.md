# İstanbul Mobilite Veri Platformu

Bu depo, Tech İstanbul Data Engineering Online Bootcamp'inin lab ortamını ve bitirme projesinin başlangıç iskeletini taşır. On oturum boyunca İstanbul'un toplu ulaşım ve trafik verisini işleyen uçtan uca bir veri platformunu bu depo üzerinde kurarsınız.

## Ortamın açılması

Lab, GitHub Codespaces üzerinde tarayıcıda çalışır ve bilgisayarınıza kurulum gerektirmez. İlk açılış dört adımda tamamlanır:

1. Bu sayfanın üstündeki "Use this template" düğmesinden "Create a new repository" seçeneğine geçiyorsunuz. "Owner" alanında kişisel hesabınızı ve görünürlükte "Public" seçeneğini bırakıp "Create repository" düğmesine basıyorsunuz.
2. Kendi deponuzda "Code" düğmesinin altındaki "Codespaces" sekmesinden "Create codespace on main" düğmesine basıyorsunuz. GitHub, lab için gereken 2 çekirdekli ve 8 GB bellekli makineyi kendisi seçer.
3. İlk açılışta ortam kendini kurar. Kurulum bittiğinde terminalde "İlk kurulum tamamlandı" satırı görünür.
4. Terminalde önce `make veri`, ardından `make kontrol` komutunu çalıştırıyorsunuz. `make veri` lab veri setlerini indirir. `make kontrol` ortamı on iki adımda sınar ve bütün adımlar TAMAM olduğunda altı haneli hazırlık kodunu yazar.

## Komutlar

| Komut | İşlev |
|---|---|
| `make baslat` | PostgreSQL ve Polaris'i başlatır |
| `make durdur` | Çalışan lab servislerini durdurur |
| `make durum` | Servislerin durumunu gösterir |
| `make sql` | DuckDB'yi lab kataloğuna bağlı olarak açar |
| `make spark` | PySpark kabuğunu lab kataloğuna bağlı olarak açar |
| `make kafka-baslat` | Kafka'yı başlatır |
| `make kafka-durdur` | Kafka'yı durdurur |
| `make veri` | Lab veri setlerini indirir ve doğrular |
| `make kontrol` | Ortamı adım adım sınar ve hazırlık kodunu üretir |
| `make oz-degerlendirme` | Ön koşul öz değerlendirmesini çalıştırır |
| `make oturum N=01` | Oturumun başlangıç dosyalarını depoya ekler, var olan dosyalara dokunmaz |
| `make odev-kontrol N=01` | Oturumlar arası görevi sınar ve kanıt kodunu yazar |

Codespace her açıldığında PostgreSQL ve Polaris kendiliğinden başlar. Kafka belleği ilgili oturumlarda kullandığı için kendiliğinden açılmaz; `make kafka-baslat` komutu onu ayrıca başlatır.

## Klasörler

| Klasör | İçerik |
|---|---|
| `lab/` | Kurulum, servis, veri ve kontrol betikleri |
| `on-hazirlik/` | Ön koşul öz değerlendirmesi |
| `veri/` | `make veri` ile inen veri dosyaları |
| `lakehouse/` | Iceberg tablolarının veri ve metadata dosyaları |
| `.lab/` | Servislerin durum dosyaları ve bağlantı bilgileri |

Veri dosyaları ve parolalar depoya girmez: `.gitignore` dosyası `veri/`, `lakehouse/` ve `.lab/` klasörlerini depo dışında tutar.

## Sürümler

Lab sürümleri eğitim boyunca sabit kalır.

| Bileşen | Sürüm |
|---|---|
| Python | 3.13 |
| Java | 21 |
| PostgreSQL | 17 |
| DuckDB | 2.0.0 |
| Apache Iceberg | 1.12.0 |
| PyIceberg | 0.12.0 |
| Apache Polaris (REST katalog) | 1.9.0 |
| Apache Spark | 4.1.4 |
| Apache Kafka | 4.4.0 |
| Apache Airflow | 3.4.0 |
| dbt | 2.0.11 |
| dbt Core ve dbt-duckdb | 1.12.7 ve 1.11.1 |

Python paketlerinin tam listesi `lab/gereksinimler/` klasöründeki kilit dosyalarında durur.

## Veri ve lisans

Lab, İstanbul Büyükşehir Belediyesi Açık Veri Portalı'ndaki (data.ibb.gov.tr) iki veri setini kullanır:

- Saatlik Toplu Ulaşım Veri Seti: Ocak, Şubat ve Mart 2024
- Saatlik Trafik Yoğunluk Veri Seti: 2024 yılının on iki ayı

İBB bu veri setlerini İBB Açık Veri Lisansı ile yayımlar ve lisans kaynak gösterimini zorunlu tutar. Lab kopyası eğitim için yeniden düzenlendiğinden sonuçlar İBB'nin yayımladığı dosyalarla birebir örtüşmeyebilir. Ayrıntılar `veri/OKU-BENI.md` dosyasında yer alır.

## Codespaces kotası

Kişisel GitHub hesabı her ay 120 çekirdek-saat işlem ve 15 GB-ay depolama kotasıyla gelir. 2 çekirdekli lab makinesinde aylık işlem kotası 60 saatlik çalışmaya karşılık gelir. Hesapta ödeme yöntemi tanımlı değilse kota bittiğinde Codespaces durur ve ücret çıkmaz.

Kotayı iki ayar korur:

- github.com/settings/codespaces sayfasındaki "Default idle timeout" değerini 10 dakika yapıyorsunuz. Codespace, 10 dakika işlem görmediğinde kendiliğinden durur.
- Eğitim boyunca tek bir Codespace kullanıyorsunuz. Her yeni Codespace depolama kotasından ayrıca harcar.

Kullanım miktarı github.com/settings/billing sayfasında görünür.

## Sorun giderme

`make kontrol` her HATA satırının yanına nedeni ve çözüm komutunu yazar. Polaris'e bağlanılamazsa `make baslat`, veri dosyası eksikse `make veri` komutu sorunu giderir. Diğer durumlar ön hazırlık rehberinin "Sorun giderme" bölümünde anlatılır.
