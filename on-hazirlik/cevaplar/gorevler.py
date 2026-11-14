"""Görev 5, 6 ve 7 | Python

Her işlevin gövdesi sizin kodunuzla dolar; işlev adları ve parametreler aynı kalır.
Veri dosyası: on-hazirlik/alistirma/yolculuk.csv (tarih, saat, hat_kodu, ilce, yolcu)
"""
import pandas as pd


def doluluk_orani(yolcu, kapasite):
    """Görev 5: Yolcu sayısının kapasiteye oranını yüzde olarak, bir ondalık basamağa yuvarlanmış halde döndürür.

    Örnek: doluluk_orani(50, 200) sonucu 25.0 olur.
    Kapasite sıfır ya da negatifse veya yolcu sayısı negatifse işlev ValueError hatası verir.
    """
    return None


def ilce_ozeti(yol):
    """Görev 6: CSV dosyasını okur ve ilçe başına toplam yolcuyu içeren bir DataFrame döndürür.

    DataFrame'in kolonları ilce ve toplam_yolcu olur; satırlar toplam_yolcu değerine göre büyükten küçüğe sıralanır.
    """
    return None


def yogun_saatler(yol):
    """Görev 7: Her hat için haftalık toplam yolcusu en yüksek olan saati bulur.

    DataFrame'in kolonları hat_kodu, saat ve toplam_yolcu olur; satırlar hat_kodu değerine göre küçükten büyüğe sıralanır.
    """
    return None
