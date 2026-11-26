# Oturum 3 | Çalışma Dosyası

Bugünün bütün uygulamaları aynı beş adımla yapılır:

1. Dosyayı soldaki gezginde `oturumlar/03` klasöründen açıyorsunuz.
2. `___` ile işaretli boşlukları dolduruyorsunuz. Her boşluğun yanındaki not ne yazılacağını söyler.
3. Dosyayı Ctrl+S (Mac'te Cmd+S) ile kaydediyorsunuz.
4. Dosyayı DuckDB'de `.read` ve dosyanın yoluyla çalıştırıyorsunuz.
5. Çıktıyı okuyorsunuz.

Doldurulmamış bir boşluk hata verir ve hata mesajı boşluğun yerini `^^^` işaretiyle gösterir. Boşluğu doldurup dosyayı kaydettikten sonra dosya yeniden çalıştırılır. Uygulama dosyaları tablolarını her çalışmada baştan kurar; bir dosyayı ikinci kez çalıştırmak sonucu değiştirmez.

## Terminal Mi, DuckDB Mi?

| Satırın başı | Program | Buraya yazılanlar |
|---|---|---|
| `$` ile biter | Terminal | `make` ve `git` komutları |
| `calisma D` ile başlar | DuckDB | SQL sorguları, `.read` ve `.quit` |

- DuckDB terminalde `make sql` komutuyla açılır, `.quit` komutuyla kapanır.
- Uzun süren bir sorgu Ctrl+C ile durur.
- SQL sorgusu `;` ile biter. Enter'dan sonra imleç yeni satıra geçiyorsa sorgunun sonuna `;` yazıp Enter'a basıyorsunuz.

## Ödev Kontrolü

Çarşamba ödevinin kontrolü hazırlıktan önce, terminalde ve DuckDB açılmadan yapılır:

```
make odev-kontrol N=02
```

Kontrol önce yapılır, çünkü hazırlık dosyası silver tablosunu herkes için aynı hale getirir; kontrol ödevdeki hali ölçer. Üç adım TAMAM yazarsa son satır kanıt kodunu verir. Kanıt kodu ve depo bağlantısı Airtable'a yüklenir. HATA yazan satırın açıklaması eksik adımı gösterir; o satırı sohbete kopyalıyorsunuz.

## Hazırlık

Terminalde:

```
make oturum N=03
make sql
```

DuckDB'de:

```
.read oturumlar/03/hazirlik.sql
```

Son satır `HAZIR: silver tablosu 16.779.679 satır, 421.347.288 yolculuk` yazar. Silver tablosu doğruysa dosya birkaç saniyede biter. Tablo yoksa ya da sayıları farklıysa dosya onu bronze tablosundan yeniden kurar ve bir dakika kadar sürer. Dosya ödev dosyalarına dokunmaz. Son satırda `EKSİK` ya da bir hata görürseniz o satırı sohbete kopyalıyorsunuz.

## Blok 1 | Tablolar Ve Anahtarlar

Amaç: hat bilgisini tek bir tabloda tutmak ve toplamı bozmadan bağlamak. Silver tablosu güzergah adını her satırda yeniden yazar: 54E'nin adı iki farklı yazımla 11.547 satırda geçer. Normalizasyon tekrar eden bilgiyi her hattın tek satır olduğu bir tabloya alır; tablolar anahtarla, `JOIN` ile bağlanır. Anahtar tekil olmalıdır: bir hat iki satırla gelirse `JOIN` o hattın yolculuğunu iki kez sayar.

Örnekler: `.read oturumlar/03/b1_ornekler.sql`

**Uygulama 1: her hat için tek satır (15 dakika)**

- Dosya: `oturumlar/03/u3_1_hat_tablosu.sql`
- ① Her hattın tek satır olması için satırların gruplanacağı kolonu yazıyorsunuz.
- ② İki tabloyu bağlayan koşulu yazıyorsunuz: iki tablonun hat kodu eşit.
- ③ Sonuçta her yol türünün bir satır olması için gruplanacak kolonu yazıyorsunuz.
- Çalıştırma: `.read oturumlar/03/u3_1_hat_tablosu.sql`
- Kontrol: Adım 2'nin iki sayısı aynı olmalı; Adım 4'ün toplam testi 922 hat ve 208.447.924 yolculuk vermeli.
- Sohbete: üç yol türünün yolculuğu.
- İleri görev: Şubat'ta çalışıp Ocak'ın hat tablosunda olmayan hatlar. `/*` ve `*/` satırlarını silip ④ numaralı boşluğu dolduruyorsunuz.

## Blok 2 | Boyutsal Model

Amaç: raporun sorularını küçük ve doğru tablolardan cevaplamak. Grain, bir satırın neyi anlattığıdır: silver tablosunda bir saatte bir durakta bir kart türüyle yapılan yolculuklar, raporun fact tablosunda bir hattın bir günü. Ortalama bu tanıma göre alınır: M2'nin silver satırlarının ortalaması 59,3, günlük ortalaması 461.637. Fact tablosu sayıları, boyut tabloları hat ve tarih bilgisini tutar. Metriğin tanımı bir görünümde (VIEW) tek yerde durur.

Örnekler: `.read oturumlar/03/b2_ornekler.sql`

**Uygulama 2: raporun tabloları (15 dakika)**

- Dosya: `oturumlar/03/u3_2_rapor_tablolari.sql`
- ① Fact tablosunun bir satırı bir hattın bir günü olsun diye gruplanacak iki kolonu yazıyorsunuz.
- ② Fact tablosunu tarih boyutuna bağlayan koşulu yazıyorsunuz.
- ③ Tarih boyutunda hafta sonunu gösteren kolonun adını yazıyorsunuz.
- Çalıştırma: `.read oturumlar/03/u3_2_rapor_tablolari.sql`
- Kontrol: toplam testinin iki sayısı da 208.447.924 olmalı.
- Sohbete: en üstteki hat ve ortalaması.
- İleri görev: Ocak yolculuğunun yüzde kaçını en kalabalık 10 hat taşıyor? `/*` ve `*/` satırlarını silip ④ numaralı boşluğu dolduruyorsunuz.

## Blok 3 | Değişen Hat Bilgisi

Amaç: hat bilgisi değişince geçmiş raporları bozmadan boyutu güncellemek. Yazım düzeltmesi üzerine yazılır (SCD Tip 1). Gerçek bir değişiklik yeni sürüm açar ve eski sürüm kapanır (SCD Tip 2); Ocak raporu Ocak'ın bilgisini göstermeye devam eder. `MERGE` iki tabloyu tek komutta karşılaştırır: eşleşen satırı günceller, eşleşmeyeni ekler. 500T'nin güzergah değişikliği eğitim için eklenmiş bir örnektir.

Örnekler: `.read oturumlar/03/b3_ornekler.sql`

**Uygulama 3: Şubat geldi (20 dakika)**

- Dosya: `oturumlar/03/u3_3_subat.sql`
- ① `MERGE` komutunda boyut satırı ile Şubat satırının eşleştiği koşulu yazıyorsunuz.
- ② Güzergahı değişen hattın eski sürümünün sona erdiği günü yazıyorsunuz.
- ③ Fact tablosunun gününün, boyut sürümünün geçerlilik aralığında olduğunu söyleyen koşulu yazıyorsunuz.
- Çalıştırma: `.read oturumlar/03/u3_3_subat.sql`
- Kontrol: boyut 936 satır, 935 hat ve 935 güncel satır; toplam testi 1.845 satır ve 421.347.288 yolculuk.
- Sohbete: 500T'nin iki satırı.
- İleri görev: Ocak'ta çalışıp Şubat listesinde olmayan hatlar. `/*` ve `*/` satırlarını silip ④ numaralı boşluğu dolduruyorsunuz; bu hatların sürümü için ne yapılması gerektiğini sohbete yazıyorsunuz.

## Blok 4 | Sorgu Maliyeti

Amaç: raporun sorgularının okuduğu veriyi ölçmek ve azaltmak. Bulut veri ambarı sorgunun okuduğu veri kadar ücret alır. `EXPLAIN ANALYZE` sorguyu çalıştırır ve okunan veriyi, dosyaları ve satır gruplarını gösterir. Okunan veri dört yolla azalır: yalnızca gereken kolonu seçmek, partition pruning, clustering ve küçük bir fact tablosundan okumak.

Örnekler: `.read oturumlar/03/b4_ornekler.sql`

Her planda üç satıra bakılır: Summary kutusunda `Data Read`, Table Scan kutusunda `Total Files Read` ve `Row Groups Scanned`. Örnek 5 fact tablosunu okur; tablo Uygulama 2 ya da 3 çalıştıktan sonra vardır.

**Uygulama 4: hatta göre sıralı tablo (15 dakika)**

- Dosya: `oturumlar/03/u3_4_hat_sirasi.sql`
- ① Satırların sıralanacağı kolonu yazıyorsunuz: hat kodu.
- ② Adım 1'de kurulan, hatta göre sıralı kopyanın adını yazıyorsunuz.
- ③ Yalnızca Ocak'ı seçen koşulu yazıyorsunuz: örnek dosyasının üçüncü örneğindeki koşul.
- Çalıştırma: `.read oturumlar/03/u3_4_hat_sirasi.sql`. Adım 1 15-20 saniye sürer.
- Sohbete: üç planın `Data Read` ve `Row Groups Scanned` değerleri.
- İleri görev: aya göre bölünmüş ve her ayın içinde hatta göre sıralı tablo. `/*` ve `*/` satırlarını silip ④ numaralı boşluğu dolduruyorsunuz.

## Ödev

Bugün ödev verilmez. Ödev çarşamba günü verilir ve bir sonraki pazartesiye kadar sürer.

## Ortam Çalışmazsa

Uygulamalar eğitmen ekranından izlenir ve aynı dosyalar oturumdan sonra çalıştırılır.
