"""Oturum 2'den sonraki görevin kontrolü.

Kullanım: make odev-kontrol N=02
Betik silver tablolarını lab verisinin veri-v1 sürümünden beklenen değerlerle karşılaştırır, sorgu dosyalarının
depoda olduğunu sınar ve bütün adımlar TAMAM olduğunda altı haneli kanıt kodunu yazar. Kod, görev teslimiyle birlikte platforma yüklenir.
"""
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

LAB_KOK = Path(os.environ.get("LAB_KOK", Path(__file__).resolve().parents[2]))
DURUM = LAB_KOK / ".lab"
# İstanbul saatine göre ay: (satır, yolculuk)
TOPLU_BEKLENEN = {"2024-01": (8548331, 208447924), "2024-02": (8229958, 212899364)}
BOYUTLAR = ["zaman", "transport_type_id", "road_type", "line", "transfer_type", "product_kind",
            "transaction_type_desc", "town", "line_name", "station_poi_desc_cd"]
TRAFIK_BEKLENEN = 1014617
DOSYALAR = [("sql/silver/toplu_ulasim.sql", r"CREATE\s+TABLE\s+lake\.silver\.toplu_ulasim"),
            ("sql/silver/trafik.sql", r"MERGE\s+INTO\s+lake\.silver\.trafik")]
TRAFIK_DEGERLER = ["DATE_TIME", "LATITUDE", "LONGITUDE", "GEOHASH", "MINIMUM_SPEED", "MAXIMUM_SPEED",
                   "AVERAGE_SPEED", "NUMBER_OF_VEHICLES"]


def baglanti():
    import duckdb
    b = duckdb.connect()
    b.execute((DURUM / "baglan.sql").read_text(encoding="utf-8"))
    return b


def tek(b, sorgu, *degerler):
    return b.execute(sorgu, list(degerler)).fetchall()[0][0]


def tablo_var(b, sema, tablo):
    return tek(b, "SELECT count(*) FROM duckdb_tables() WHERE database_name = 'lake' AND schema_name = ? "
                  "AND table_name = ?", sema, tablo) > 0


def toplu_ulasim(b):
    if not tablo_var(b, "silver", "toplu_ulasim"):
        return False, "lake.silver.toplu_ulasim bulunamadı", 0
    kolonlar = {k[0]: k[1] for k in b.execute("DESCRIBE lake.silver.toplu_ulasim").fetchall()}
    eksik = [k for k in BOYUTLAR + ["number_of_passage"] if k not in kolonlar]
    if eksik:
        return False, f"eksik kolon: {', '.join(eksik)}", 0
    if kolonlar["zaman"] != "TIMESTAMP WITH TIME ZONE":
        return False, f"zaman kolonunun tipi {kolonlar['zaman']}, TIMESTAMP WITH TIME ZONE bekleniyor", 0
    bozuk = tek(b, "SELECT count(*) FROM lake.silver.toplu_ulasim WHERE regexp_matches(line_name, '[ÃÄÅ]')")
    if bozuk:
        return False, f"{bozuk} satırda bozuk hat kodu var", 0
    ilk = tek(b, "SELECT min(zaman) = TIMESTAMPTZ '2024-01-01 00:00:00+03' FROM lake.silver.toplu_ulasim")
    if not ilk:
        return False, "ilk saat 1 Ocak 00:00 (İstanbul) değil; saat dilimi dönüşümü yanlış", 0
    aylar = dict((a, (s, y)) for a, s, y in b.execute(
        "SELECT strftime(zaman AT TIME ZONE 'Europe/Istanbul', '%Y-%m') AS ay, count(*), "
        "sum(number_of_passage)::BIGINT FROM lake.silver.toplu_ulasim GROUP BY ALL").fetchall())
    for ay, (satir, yolculuk) in TOPLU_BEKLENEN.items():
        gelen = aylar.get(ay, (0, 0))
        if gelen[1] != yolculuk:
            return False, f"{ay}: yolculuk toplamı {gelen[1]}, beklenen {yolculuk}", 0
        if gelen[0] != satir:
            return False, f"{ay}: {gelen[0]} satır, beklenen {satir}; grain farklı", 0
    toplam = sum(s for s, _ in TOPLU_BEKLENEN.values())
    tekil = tek(b, f"SELECT count(DISTINCT ({', '.join(BOYUTLAR)})) FROM lake.silver.toplu_ulasim")
    if tekil != toplam:
        return False, f"grain tekil değil: {toplam} satır, {tekil} tekil boyut kombinasyonu", 0
    return True, f"{toplam} satır, iki ay, bozuk kod yok", toplam


def trafik(b):
    if not tablo_var(b, "silver", "trafik"):
        return False, "lake.silver.trafik bulunamadı", 0
    satir = tek(b, "SELECT count(*) FROM lake.silver.trafik")
    anahtar = tek(b, "SELECT count(DISTINCT (DATE_TIME, GEOHASH)) FROM lake.silver.trafik")
    if anahtar != satir:
        return False, f"anahtar tekil değil: {satir} satır, {anahtar} tekil anahtar", 0
    degerler = ", ".join(TRAFIK_DEGERLER)
    ocak = tek(b, f"SELECT count(*) FROM (SELECT {degerler} FROM lake.silver.trafik "
                  f"WHERE DATE_TIME < TIMESTAMP '2024-02-01' EXCEPT SELECT {degerler} FROM lake.bronze.trafik)")
    subat = tek(b, f"SELECT count(*) FROM (SELECT {degerler} FROM lake.silver.trafik "
                   f"WHERE DATE_TIME >= TIMESTAMP '2024-02-01' AND DATE_TIME < TIMESTAMP '2024-02-02' "
                   f"EXCEPT SELECT * FROM read_csv('{LAB_KOK / 'veri' / 'trafik_2024_02.csv.gz'}') "
                   f"WHERE DATE_TIME < TIMESTAMP '2024-02-02')")
    if ocak or subat:
        return False, f"kaynakla farklı satır: Ocak {ocak}, 1 Şubat {subat}", 0
    if satir != TRAFIK_BEKLENEN:
        return False, f"{satir} satır, beklenen {TRAFIK_BEKLENEN} (Ocak ve 1 Şubat)", 0
    return True, f"{satir} satır, kaynakla fark yok", satir


def sorgu_dosyalari():
    for yol, desen in DOSYALAR:
        dosya = LAB_KOK / yol
        if not dosya.exists():
            return False, f"{yol} bulunamadı"
        metin = "\n".join(s.split("--")[0] for s in dosya.read_text(encoding="utf-8").splitlines())
        if not re.search(desen, metin, re.I):
            return False, f"{yol} dosyasında {'CREATE TABLE' if 'CREATE' in desen else 'MERGE'} sorgusu yok"
    return True, "iki dosya depoda"


def main():
    print("Oturum 2 görevi sınanıyor.\n")
    b = baglanti()
    sonuclar = []
    tamam1, ayrinti1, toplu = toplu_ulasim(b)
    sonuclar.append(("Toplu ulaşım silver tablosu", tamam1, ayrinti1))
    tamam2, ayrinti2, trf = trafik(b)
    sonuclar.append(("Trafik silver tablosu", tamam2, ayrinti2))
    tamam3, ayrinti3 = sorgu_dosyalari()
    sonuclar.append(("Silver sorguları", tamam3, ayrinti3))
    genislik = max(len(a) for a, _, _ in sonuclar)
    for ad, tamam, ayrinti in sonuclar:
        print(f"  {ad:<{genislik}}  {'TAMAM' if tamam else 'HATA ':5}  {ayrinti}")
    print()
    if all(t for _, t, _ in sonuclar):
        kullanici = os.environ.get("GITHUB_USER") or subprocess.run(["git", "config", "user.name"], capture_output=True,
                                                                    text=True).stdout.strip() or "bilinmiyor"
        kod = hashlib.sha256(f"odev-02|{kullanici}|{toplu}|{trf}".encode()).hexdigest()[:6].upper()
        print(f"Görev tamam. Kanıt kodu: {kod} (GitHub kullanıcısı: {kullanici})")
        sys.exit(0)
    print("Görev tamamlanmadı. HATA satırlarındaki açıklama eksik adımı gösterir.")
    sys.exit(1)


if __name__ == "__main__":
    main()
