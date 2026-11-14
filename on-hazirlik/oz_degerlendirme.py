"""Ön koşul öz değerlendirmesi.

Kullanım: make oz-degerlendirme
Cevaplar on-hazirlik/cevaplar klasöründeki dosyalarda durur. Betik her cevabı alıştırma verisi üzerinde çalıştırır,
sonucun parmak izini beklenen değerle karşılaştırır ve her görev için DOĞRU, YANLIŞ ya da BOŞ yazar.
Beklenen sonuçlar betikte açık halde değil, parmak izi olarak durur.
"""
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
from decimal import Decimal
from pathlib import Path

ON = Path(__file__).resolve().parent
ALISTIRMA = ON / "alistirma"
CEVAP = ON / "cevaplar"
GIT_ALISTIRMA = ON / "git-alistirma"
DENEME_ORTAMI = ON / ".venv-deneme"

BEKLENEN = {
    "sql_1": "6e110745ad5635c9",
    "sql_2": "b8acb0c03864fd94",
    "sql_3": "59cb1ab3bd90de7a",
    "sql_4": "26387b17a31ced1b",
    "py_5": "db1f511ffa7f9e81",
    "py_6": "590ee72d88392e80",
    "py_7": "e0f24e8f66081833",
    "cli_9": "1ee743686e5bd884",
    "cli_10": "051b6001f877f1d8",
}

TAZELEME = {
    1: "SQL: JOIN ve GROUP BY",
    2: "SQL: GROUP BY, HAVING ve COUNT(DISTINCT)",
    3: "SQL: LEFT JOIN ve eşleşmeyen kayıtlar",
    4: "SQL: alt sorgu",
    5: "Python: fonksiyon ve hata yönetimi",
    6: "pandas: CSV okuma ve gruplama",
    7: "pandas: çok kolonlu gruplama ve sıralama",
    8: "Python: sanal ortam ve paket kurulumu",
    9: "Komut satırı: grep ve dosya üzerinde arama",
    10: "Komut satırı: boru (pipe), sort ve uniq",
    11: "Git: dal açma ve commit",
    12: "Git: geçmişte arama (git log)",
}


class Bos(Exception):
    """Cevap dosyası boş ya da yalnızca şablon metnini içeriyor."""


def deger(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return str(v)
    if isinstance(v, (int, float, Decimal)):
        return f"{float(v):.2f}"
    if hasattr(v, "item"):
        return deger(v.item())
    return str(v).strip()


def parmak_izi(satirlar, sirali=True):
    metin = [[deger(v) for v in satir] for satir in satirlar]
    if not sirali:
        metin.sort()
    return hashlib.sha256(json.dumps(metin, ensure_ascii=False).encode("utf-8")).hexdigest()[:16]


def kod_metni(yol, yorum):
    if not yol.exists():
        raise Bos(f"{yol.relative_to(ON)} bulunamadı")
    satirlar = [s for s in yol.read_text(encoding="utf-8").splitlines() if s.strip() and not s.strip().startswith(yorum)]
    if not satirlar:
        raise Bos(f"{yol.relative_to(ON)} boş")
    return "\n".join(satirlar)


# --- SQL ---------------------------------------------------------------------

def sql_baglanti():
    import duckdb
    baglanti = duckdb.connect()
    baglanti.execute(f"""CREATE TABLE hatlar AS SELECT * FROM read_csv('{ALISTIRMA / "hatlar.csv"}',
        columns = {{'hat_kodu': 'VARCHAR', 'hat_adi': 'VARCHAR', 'tur': 'VARCHAR', 'kapasite': 'INTEGER'}}, header = true)""")
    baglanti.execute(f"""CREATE TABLE yolculuk AS SELECT * FROM read_csv('{ALISTIRMA / "yolculuk.csv"}',
        columns = {{'tarih': 'DATE', 'saat': 'INTEGER', 'hat_kodu': 'VARCHAR', 'ilce': 'VARCHAR', 'yolcu': 'INTEGER'}}, header = true)""")
    return baglanti


def sql_gorevi(no, sirali):
    def sina():
        sorgu = kod_metni(CEVAP / f"sql_{no}.sql", "--")
        satirlar = sql_baglanti().execute(sorgu).fetchall()
        return parmak_izi(satirlar, sirali)
    return sina


# --- Python ------------------------------------------------------------------

def gorevler_modulu():
    yol = CEVAP / "gorevler.py"
    if not yol.exists():
        raise Bos("cevaplar/gorevler.py bulunamadı")
    tanim = importlib.util.spec_from_file_location("gorevler", yol)
    modul = importlib.util.module_from_spec(tanim)
    tanim.loader.exec_module(modul)
    return modul


def py_5():
    islev = getattr(gorevler_modulu(), "doluluk_orani")
    sonuclar = []
    for yolcu, kapasite in [(50, 200), (0, 10), (333, 1000), (1, 3), (1200, 1000), (5, 0), (-1, 10)]:
        try:
            cikti = islev(yolcu, kapasite)
            if cikti is None:
                raise Bos("doluluk_orani henüz yazılmadı")
            sonuclar.append([cikti])
        except ValueError:
            sonuclar.append(["ValueError"])
    return parmak_izi(sonuclar)


def tablo_izi(df, kolonlar):
    if df is None:
        raise Bos("işlev henüz yazılmadı")
    return parmak_izi(df[kolonlar].itertuples(index=False, name=None))


def py_6():
    df = gorevler_modulu().ilce_ozeti(str(ALISTIRMA / "yolculuk.csv"))
    return tablo_izi(df, ["ilce", "toplam_yolcu"])


def py_7():
    df = gorevler_modulu().yogun_saatler(str(ALISTIRMA / "yolculuk.csv"))
    return tablo_izi(df, ["hat_kodu", "saat", "toplam_yolcu"])


def py_8():
    python = DENEME_ORTAMI / "bin" / "python"
    if not python.exists():
        raise Bos("on-hazirlik/.venv-deneme sanal ortamı bulunamadı")
    sonuc = subprocess.run([str(python), "-c", "import tabulate; print(tabulate.__version__)"],
                           capture_output=True, text=True, timeout=60)
    return sonuc.returncode == 0 and sonuc.stdout.strip() == "0.9.0"


# --- Komut satırı ---------------------------------------------------------------

def komut_ciktisi(no):
    kod_metni(CEVAP / f"komut_{no}.sh", "#")
    sonuc = subprocess.run(["bash", str(CEVAP / f"komut_{no}.sh")], cwd=ALISTIRMA / "gunluk",
                           capture_output=True, text=True, timeout=60)
    return [s.split() for s in sonuc.stdout.strip().splitlines() if s.strip()]


def cli_9():
    return parmak_izi(komut_ciktisi(9))


def cli_10():
    return parmak_izi([sorted(satir) for satir in komut_ciktisi(10)])


# --- Git ---------------------------------------------------------------------

GIT_GECMISI = [
    ("Hat listesi eklendi", "hat_kodu,hat_adi\nM1A,Yenikapı - Atatürk Havalimanı\nM2,Yenikapı - Hacıosman\n"
                            "T1,Kabatas - Bağcılar\n"),
    ("M4 eklendi", "M4,Kadıköy - Sabiha Gökçen Havalimanı\n"),
    ("Tramvay notu eklendi", None),
    ("TF1 eklendi", "TF1,Maçka - Taksim\n"),
    ("Füniküler eklendi", "F1,Taksim - Kabataş\n"),
    ("Marmaray eklendi", "MARMARAY,Halkalı - Gebze\n"),
]


def git(*argumanlar, ortam=None):
    return subprocess.run(["git", *argumanlar], cwd=GIT_ALISTIRMA, capture_output=True, text=True,
                          env={**os.environ, **(ortam or {})})


def git_alistirmasi_hazirla():
    if (GIT_ALISTIRMA / ".git").exists():
        return
    GIT_ALISTIRMA.mkdir(parents=True, exist_ok=True)
    git("init", "-q", "-b", "main")
    git("config", "user.name", "Alıştırma")
    git("config", "user.email", "alistirma@example.com")
    for sira, (mesaj, ek) in enumerate(GIT_GECMISI):
        if ek is None:
            (GIT_ALISTIRMA / "NOTLAR.md").write_text("T1 hattının adı kaynak sistemde Türkçe karaktersiz yazılmış.\n",
                                                    encoding="utf-8")
        else:
            with (GIT_ALISTIRMA / "hatlar.csv").open("a", encoding="utf-8") as dosya:
                dosya.write(ek)
        git("add", "-A")
        zaman = f"2024-01-0{sira + 1}T09:00:00+03:00"
        git("commit", "-q", "-m", mesaj, ortam={"GIT_AUTHOR_DATE": zaman, "GIT_COMMITTER_DATE": zaman})
    print(f"Git alıştırma deposu hazırlandı: {GIT_ALISTIRMA.relative_to(ON.parent)}\n")


def git_11():
    if git("rev-parse", "--verify", "-q", "duzeltme").returncode != 0:
        raise Bos("duzeltme dalı bulunamadı")
    mesaj = git("log", "-1", "--format=%s", "duzeltme").stdout.strip()
    icerik = git("show", "duzeltme:hatlar.csv").stdout
    degisen = git("diff", "--name-only", "duzeltme~1", "duzeltme").stdout.split()
    main_mesaj = git("log", "-1", "--format=%s", "main").stdout.strip()
    return (mesaj == "Hat adı düzeltildi" and "Kabataş - Bağcılar" in icerik and "Kabatas" not in icerik
            and degisen == ["hatlar.csv"] and main_mesaj == GIT_GECMISI[-1][0])


def git_12():
    cevap = kod_metni(CEVAP / "git_12.txt", "#").strip().split()[0].lower()
    dogru = git("log", "--format=%H", "-S", "TF1", "main", "--", "hatlar.csv").stdout.split()
    return len(cevap) >= 7 and bool(dogru) and dogru[-1].startswith(cevap)


GOREVLER = [
    (1, "SQL", "JOIN ile hat bazında toplam yolcu", sql_gorevi(1, sirali=True), "sql_1"),
    (2, "SQL", "GROUP BY ve HAVING ile ilçe özeti", sql_gorevi(2, sirali=False), "sql_2"),
    (3, "SQL", "Kaydı olmayan hatlar", sql_gorevi(3, sirali=False), "sql_3"),
    (4, "SQL", "Ortalamanın üstündeki hatlar", sql_gorevi(4, sirali=True), "sql_4"),
    (5, "Python", "Doluluk oranı işlevi", py_5, "py_5"),
    (6, "Python", "pandas ile ilçe özeti", py_6, "py_6"),
    (7, "Python", "pandas ile en yoğun saat", py_7, "py_7"),
    (8, "Python", "Sanal ortam ve paket kurulumu", py_8, None),
    (9, "Komut satırı", "Hata satırlarının sayısı", cli_9, "cli_9"),
    (10, "Komut satırı", "En sık hata veren servisler", cli_10, "cli_10"),
    (11, "Git", "Dal açma ve commit", git_11, None),
    (12, "Git", "Geçmişte commit bulma", git_12, None),
]


def main():
    git_alistirmasi_hazirla()
    parmak_izi_modu = os.environ.get("OZD_PARMAK_IZI") == "1"
    print("Ön koşul öz değerlendirmesi\n")
    dogrular, alan_dogru, eksik = 0, {}, []
    for no, alan, baslik, sina, anahtar in GOREVLER:
        try:
            sonuc = sina()
            if parmak_izi_modu and anahtar:
                print(f"    {anahtar}: {sonuc}")
            tamam = sonuc is True or (anahtar is not None and sonuc == BEKLENEN[anahtar])
            durum, aciklama = ("DOĞRU", "") if tamam else ("YANLIŞ", "sonuç beklenenle uyuşmuyor")
        except Bos as neden:
            tamam, durum, aciklama = False, "BOŞ", str(neden)
        except Exception as hata:
            tamam, durum, aciklama = False, "YANLIŞ", f"{type(hata).__name__}: {str(hata).splitlines()[0][:70]}"
        dogrular += tamam
        alan_dogru[alan] = alan_dogru.get(alan, 0) + tamam
        if not tamam:
            eksik.append(no)
        print(f"{no:2d}. {alan:<13}{baslik:<36}{durum:<7}{aciklama}")

    hazir = dogrular >= 10 and alan_dogru.get("SQL", 0) >= 3 and alan_dogru.get("Python", 0) >= 3
    print(f"\n12 görevden {dogrular} tanesi doğru.")
    print(f"Sonuç: {'hazır' if hazir else 'tazeleme gerekli'}")
    if eksik:
        print("Tazeleme listesinde bakılacak başlıklar:")
        for no in eksik:
            print(f"  - {TAZELEME[no]}")
    sys.exit(0)


if __name__ == "__main__":
    main()
