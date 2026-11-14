# Ön koşul öz değerlendirmesi

Bu klasördeki on iki görev, eğitimin bildiğinizi kabul ettiği konuları ölçer. Görevler; SQL'de JOIN, GROUP BY ve alt sorgu, Python'da fonksiyon yazma, paket kurma ve pandas ile temel veri işleme, komut satırı ve Git'in temel kullanımı konularını kapsar. Sonuç yalnızca sizin ekranınızda görünür ve hiçbir yere gönderilmez.

## Çalıştırma

Cevaplar `cevaplar/` klasöründeki dosyalara yazılır. Her dosyanın başındaki yorum satırları görevi, beklenen kolonları ve sıralamayı tarif eder. Değerlendirme terminalde şu komutla çalışır:

```
make oz-degerlendirme
```

Betik her görev için DOĞRU, YANLIŞ ya da BOŞ yazar. Komut istediğiniz kadar yeniden çalışabilir. İlk çalıştırma Git görevleri için `git-alistirma/` deposunu da hazırlar.

## Görevler

| No | Alan | Görev | Cevap yeri |
|---|---|---|---|
| 1 | SQL | JOIN ile hat bazında toplam yolcu | `cevaplar/sql_1.sql` |
| 2 | SQL | GROUP BY ve HAVING ile ilçe özeti | `cevaplar/sql_2.sql` |
| 3 | SQL | Kaydı olmayan hatlar | `cevaplar/sql_3.sql` |
| 4 | SQL | Ortalamanın üstündeki hatlar | `cevaplar/sql_4.sql` |
| 5 | Python | Doluluk oranı işlevi | `cevaplar/gorevler.py` |
| 6 | Python | pandas ile ilçe özeti | `cevaplar/gorevler.py` |
| 7 | Python | pandas ile en yoğun saat | `cevaplar/gorevler.py` |
| 8 | Python | Sanal ortam ve paket kurulumu | `.venv-deneme/` |
| 9 | Komut satırı | Hata satırlarının sayısı | `cevaplar/komut_9.sh` |
| 10 | Komut satırı | En sık hata veren servisler | `cevaplar/komut_10.sh` |
| 11 | Git | Dal açma ve commit | `git-alistirma/` |
| 12 | Git | Geçmişte commit bulma | `cevaplar/git_12.txt` |

Görev 8: `on-hazirlik/.venv-deneme` adında bir sanal ortam ve bu ortamda `tabulate` paketinin 0.9.0 sürümü beklenir. Lab ortamının Python kurulumu bu görevde değişmez.

Görev 11: `git-alistirma` deposunda `main` dalından açılmış `duzeltme` adlı bir dal beklenir. Bu dalın son commit'i `hatlar.csv` dosyasındaki "Kabatas" yazımını "Kabataş" olarak düzeltir ve "Hat adı düzeltildi" mesajını taşır. `main` dalı değişmeden kalır.

## Sonuç

En az 10 doğru cevap, SQL'de ve Python'da en az üçer doğru cevapla birlikte "hazır" sonucunu verir. Diğer durumlarda betik "tazeleme gerekli" sonucunu ve bakılacak başlıkları yazar. Bu başlıklar ön hazırlık paketindeki tazeleme listesinde kaynaklarıyla birlikte yer alır.

## Alıştırma verisi

`alistirma/` klasöründeki hat, yolculuk ve günlük dosyaları bu değerlendirme için üretilmiş sentetik verilerdir. Hat adları gerçek hatlardan gelir; yolcu sayıları ve günlük kayıtları gerçeği yansıtmaz.
