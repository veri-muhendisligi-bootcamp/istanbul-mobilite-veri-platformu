# Oturum 2 | Çalışma dosyası

Bu dosya Oturum 2'nin üç uygulamasını tarif eder. Her blok kısa bir soruyla başlar, ardından konu anlatılır ve uygulama gelir. Uygulamanın çözümü bloğun sonunda birlikte yapılır.

`make sql` komutu DuckDB'yi lab kataloğuna bağlı olarak açar ve bütün sorgular bu oturumda çalışır. Bir SQL dosyası DuckDB içinde `.read` komutuyla çalışır; örnek: `.read oturumlar/02/u2_1_window.sql`. `make sql` ve `.read` ayrı ayrı yazılır: `.read` satırı DuckDB'nin `calisma D` istemi göründükten sonra yazılır. Oturum, Oturum 1'de kurulan `ham_ocak`, `lake.bronze.toplu_ulasim` ve `lake.bronze.trafik` tablolarını kullanır.

## U2.1 Geçen haftaya göre değişim (20 dakika)

- Görev: Ocak 2024'ün her gününü geçen haftanın aynı günüyle karşılaştırıyor ve yüzde 50'den fazla artan günü buluyorsunuz.
- `hat_saatlik` tablosu anlatımda `.read oturumlar/02/u2_1_window.sql` komutuyla kuruldu. Tablonun bir satırı, bir saatte bir hattın yolculuk toplamıdır. Tablo yoksa aynı komut onu kurar.
- Başlangıç kodu `oturumlar/02/u2_1_gecen_hafta.sql` dosyasındadır. Dosyadaki `gunluk` CTE'si her günün toplam yolculuğunu alır; `lag()` önceki bir günün yolculuğunu yanına getirir. `kac_satir` yerine kaç satır önceye bakılacağını yazıyor, dosyayı kaydediyor ve DuckDB'de `.read oturumlar/02/u2_1_gecen_hafta.sql` ile çalıştırıyorsunuz.
- Sorguya geçen haftaya göre yüzde değişimi veren bir kolon ekliyorsunuz. Değişim, günün yolculuğunun geçen haftanın yolculuğuna bölümünden 1 çıkarılıp 100 ile çarpılmasıyla bulunur.
- `QUALIFY` ile yüzde 50'den fazla artan günleri bırakıyorsunuz. `QUALIFY` satırı `FROM gunluk` ile `ORDER BY gun` arasına yazılır.
- Bulduğunuz günü ve artış yüzdesini Zoom sohbetine yazıyorsunuz.
- Erken bitirenler M2 hattının her saatteki yolculuğunun bir önceki saate göre farkını buluyor; önceki satır bir saat önce değilse fark boş kalır. Önceki satırın zamanı `lag(zaman)` ile okunur.

## U2.2 Plan avı (20 dakika)

- Görev: İki sorgunun üç farklı fiziksel yerleşimde ne kadar veri okuduğunu ölçüyorsunuz.
- `.read oturumlar/02/u2_2_plan_avi.sql` Ocak verisinden iki karşılaştırma tablosu kurar: `lake.bronze.deneme_gun` gün partition'lıdır, `lake.bronze.deneme_hat` partition'sızdır ve hat koduna göre sıralı yazılmıştır. Üçüncü yerleşim, Oturum 1'de kendi partition kararınızla kurduğunuz `lake.bronze.toplu_ulasim` tablosudur. Dosya ilk sorguyu kendi tablonuzda `EXPLAIN ANALYZE` ile çalıştırır.
- `EXPLAIN ANALYZE` sorguyu çalıştırır ve planını ölçümleriyle gösterir. Planda üç değeri okuyorsunuz: `Summary` kutusundaki `Data Read`, `Table Scan` kutusundaki `Total Files Read` ve `Row Groups Scanned`. Planın en üstündeki `HTTPFS HTTP Stats` kutusu katalogla yapılan istekleri sayar; bu uygulamada kullanılmaz.
- Dosyanın sonundaki iki sorguyu üç tabloda çalıştırıyorsunuz: tablo adını `toplu_ulasim`, `deneme_gun` ve `deneme_hat` olarak değiştiriyorsunuz. Sorgu 2'nin satırlarının başındaki `--` işaretlerini siliyorsunuz.
- Altı ölçümü aşağıdaki tabloya yazıyorsunuz:

| Tablo | Sorgu 1: okunan veri, dosya, row group | Sorgu 2: okunan veri, dosya, row group |
|---|---|---|
| `toplu_ulasim` | | |
| `deneme_gun` | | |
| `deneme_hat` | | |

- Zoom sohbetine her sorgu için en az veriyi okuyan tabloyu ve okuduğu veri miktarını yazıyorsunuz.
- Erken bitirenler Sorgu 1'i `SELECT *` ile çalıştırıyor ve okunan veriyi tek kolonlu sorguyla karşılaştırıyor.

## U2.3 API yanıtlarından MERGE (20 dakika)

- Görev: Trafik API'sinin kayıtlı yanıtlarını `lake.silver.trafik` tablosuna, ikinci kez çalıştığında tabloyu değiştirmeyen bir MERGE ile yüklüyorsunuz. Aynı ölçüm iki çekimde farklı değerle gelirse en son çekilen kayıt kalır.
- `veri/api/trafik` klasöründeki üç JSON dosyası, trafik API'sinin 1 Şubat 2024 için kayıtlı yanıtlarıdır. İki dosya 2 Şubat 01:10'daki çekimin iki sayfasıdır. Üçüncü dosya 3 Şubat 01:10'daki çekimdir ve 21:00, 22:00 ve 23:00 saatlerini yeniden verir.
- `.read oturumlar/02/u2_3_merge.sql` yanıtın yapısını gösterir, kayıtları `trafik_api` görünümünde tipli satırlara çevirir, boş `lake.silver.trafik` tablosunu kurar ve `yukleme_kontrol` makrosunu tanımlar.
- `FROM yukleme_kontrol('lake.silver.trafik');` tabloyu dört ölçüyle sınar: satır sayısı, tekil anahtar sayısı, snapshot sayısı ve kaynak CSV dosyasıyla fark. Doğru bir yüklemede fark 0 olur.
- Dosyanın sonundaki MERGE kalıbında `/* */` ile işaretli üç yeri dolduruyorsunuz: anahtar kolonlar, kazanan kayıt kuralı ve iki tablo arasındaki anahtar eşitliği. Veri sözlüğüne göre bir satır, verilen saatte bir geohash alanının ölçümüdür. Satır başlarındaki `--` işaretlerini siliyorsunuz.
- MERGE'ü çalıştırıyor ve kontrolü çalıştırıyorsunuz. Aynı MERGE'ü ikinci kez çalıştırıyor ve kontrolü yeniden çalıştırıyorsunuz.
- Hatalı bir çalıştırmadan sonra `.read oturumlar/02/u2_3_merge.sql` tabloyu boş haline döndürür.
- Zoom sohbetine seçtiğiniz anahtar kolonları, kazanan kayıt kuralını ve iki çalıştırmadan sonraki kontrol değerlerini yazıyorsunuz.
- Erken bitirenler kayıtlarda duran `_id` alanının iki çekimde aynı ölçümü gösterip göstermediğini sınıyor: aynı `_id` değerinin birden fazla `DATE_TIME` ve `GEOHASH` çiftiyle gelip gelmediğini sayıyor.

## Oturumlar arası görev (60-90 dakika, Oturum 3'e kadar)

- Bronze tablolarından silver katmanı kurulur. `lake.silver.toplu_ulasim` tekrar gönderilen günleri ayıklar, bozuk hat kodlarını düzeltir, gün ve saati İstanbul saatiyle zaman damgasına çevirir ve parçaları yayımlanan boyutlara göre toplar.
- `lake.silver.trafik` tablosuna Ocak satırları Blok 3'teki MERGE ile `lake.bronze.trafik` tablosundan eklenir.
- Sorgular `sql/silver/toplu_ulasim.sql` ve `sql/silver/trafik.sql` dosyalarına yazılır ve `git push` ile deponuza gönderilir. İki dosya bu oturumun paketiyle başlık satırlarıyla gelir.
- Kontrol komutu `make odev-kontrol N=02` olur. Bütün adımlar TAMAM olduğunda betik kanıt kodunu yazar; kod ve depo bağlantısı Tech İstanbul platformundaki göreve yüklenir.
- Görevin ayrıntıları `Data-Engineering-Oturum-02-Odev.docx` dosyasındadır.

## Ortam çalışmazsa

Uygulamalar eğitmen ekranından takip edilir ve aynı görevler oturumdan sonra tamamlanır.
