"""Lab veri setlerini İBB Açık Veri Portalı'ndan hazırlar.

Yalnızca eğitmenin çalıştırdığı "Veri hazırla" iş akışında çalışır; katılımcı bu betiği kullanmaz.
Adımlar:
  1. CKAN API'sinden veri setlerinin kaynak listesini alır.
  2. Seçilen ayların CSV dosyalarını indirir ve her dosyanın profilini çıkarır.
  3. Dosyaları gzip ile sıkıştırır, sağlama toplamlarını lab/veri_listesi.json dosyasına yazar.
"""
import gzip
import hashlib
import json
import os
import re
import shutil
import sys
import time
import unicodedata
import urllib.request
from pathlib import Path

import duckdb

PORTAL = "https://data.ibb.gov.tr"
KOK = Path(__file__).resolve().parents[1]
CIKTI = KOK / "veri_hazir"
GECICI = KOK / "veri_ham"
SURUM = os.environ.get("VERI_SURUMU", "veri-v1")
DEPO = os.environ.get("GITHUB_REPOSITORY", "")
TOHUM = os.environ.get("KUSUR_TOHUMU") or "lab-2026"

AYLAR = ["ocak", "şubat", "mart", "nisan", "mayıs", "haziran", "temmuz", "ağustos", "eylül", "ekim", "kasım", "aralık"]
SECIM = {
    "hourly-public-transport-data-set": {"kisa": "toplu_ulasim", "yil": "2024", "aylar": [1, 2, 3], "kusur": True},
    "hourly-traffic-density-data-set": {"kisa": "trafik", "yil": "2024", "aylar": list(range(1, 13)), "kusur": False},
}


def kucuk(metin):
    return unicodedata.normalize("NFC", metin).replace("I", "ı").replace("İ", "i").lower()


def api(eylem, **parametreler):
    sorgu = "&".join(f"{k}={v}" for k, v in parametreler.items())
    with urllib.request.urlopen(f"{PORTAL}/api/3/action/{eylem}?{sorgu}", timeout=60) as yanit:
        return json.load(yanit)["result"]


def ay_bul(ad, yil, adres=""):
    """Kaynağın ayını önce adındaki ay adından, bulamazsa dosya adındaki YYYYAA kalıbından çıkarır."""
    ad = kucuk(ad)
    if yil in ad:
        for sira, ay in enumerate(AYLAR, 1):
            if re.search(rf"\b{ay}\b", ad):
                return sira
    eslesme = re.search(rf"{yil}(\d\d)", adres.rsplit("/", 1)[-1])
    if eslesme and 1 <= int(eslesme.group(1)) <= 12:
        return int(eslesme.group(1))
    return None


def indir(adres, hedef):
    for deneme in range(1, 6):
        try:
            with urllib.request.urlopen(adres, timeout=120) as yanit, hedef.open("wb") as cikis:
                shutil.copyfileobj(yanit, cikis, length=1 << 22)
            return
        except Exception as hata:
            print(f"  deneme {deneme} başarısız: {hata}")
            time.sleep(10 * deneme)
    raise RuntimeError(f"indirilemedi: {adres}")


def profil(baglanti, yol):
    tespit = baglanti.execute(f"SELECT Delimiter, HasHeader, Columns FROM sniff_csv('{yol}', sample_size = 200000)").fetchall()[0]
    satir = baglanti.execute(f"SELECT count(*) FROM read_csv('{yol}', all_varchar = true)").fetchall()[0][0]
    ornek = baglanti.execute(f"SELECT * FROM read_csv('{yol}', all_varchar = true) LIMIT 3").fetchall()
    return {"ayirici": tespit[0], "baslik": tespit[1], "kolonlar": tespit[2], "satir": satir,
            "ornek": [list(map(str, s)) for s in ornek]}


def bozuk_kodlama(metin):
    """UTF-8 metni Windows-1252 ile okunmuş gibi bozar: "ŞİŞLİ" -> "ÅžÄ°ÅžLÄ°"."""
    if metin is None:
        return None
    return metin.encode("utf-8").decode("cp1252", errors="replace")


def kusur_yerlestir(baglanti, yol, cikti, ayirici):
    if not baglanti.execute("SELECT count(*) FROM duckdb_functions() WHERE function_name = 'bozuk_kodlama'").fetchall()[0][0]:
        baglanti.create_function("bozuk_kodlama", bozuk_kodlama, ["VARCHAR"], "VARCHAR", null_handling="special")
    baglanti.execute("SET preserve_insertion_order = true")
    baglanti.execute(f"CREATE OR REPLACE TABLE ham AS SELECT * FROM read_csv('{yol}', all_varchar = true, header = true)")
    kolonlar = {k[0] for k in baglanti.execute("SELECT * FROM ham LIMIT 0").description}
    eksik = {"number_of_passenger", "town", "line_name"} - kolonlar
    if eksik:
        raise RuntimeError(f"beklenen kolonlar bulunamadı: {sorted(eksik)}; dosyadaki kolonlar: {sorted(kolonlar)}")
    baglanti.execute("ALTER TABLE ham ADD COLUMN _sira BIGINT")
    baglanti.execute("UPDATE ham SET _sira = rowid")
    secim = f"hash(_sira::VARCHAR || '{TOHUM}')"
    baglanti.execute(f"UPDATE ham SET number_of_passenger = NULL WHERE {secim} % 2000 = 7")
    baglanti.execute(f"""UPDATE ham SET town = bozuk_kodlama(town), line_name = bozuk_kodlama(line_name)
                         WHERE {secim} % 500 = 11 AND regexp_matches(coalesce(town, '') || coalesce(line_name, ''), '[çğıöşüÇĞİÖŞÜ]')""")
    baglanti.execute(f"INSERT INTO ham SELECT * FROM ham WHERE {secim} % 1000 = 3")
    kolonlar = [k for k in baglanti.execute("SELECT * FROM ham LIMIT 0").description if k[0] != "_sira"]
    secilen = ", ".join(f'"{k[0]}"' for k in kolonlar)
    baglanti.execute(f"COPY (SELECT {secilen} FROM ham ORDER BY _sira) TO '{cikti}' "
                     f"(HEADER, DELIMITER '{ayirici}', QUOTE '\"', COMPRESSION gzip)")
    baglanti.execute("DROP TABLE ham")


def sikistir(yol, cikti):
    with yol.open("rb") as giris, gzip.open(cikti, "wb", compresslevel=6) as cikis:
        shutil.copyfileobj(giris, cikis, length=1 << 22)


def ozet(yol):
    h = hashlib.sha256()
    with yol.open("rb") as akis:
        for parca in iter(lambda: akis.read(1 << 22), b""):
            h.update(parca)
    return h.hexdigest()


def main():
    CIKTI.mkdir(exist_ok=True)
    GECICI.mkdir(exist_ok=True)
    baglanti = duckdb.connect()
    dosyalar, profiller = [], {}
    for paket, ayar in SECIM.items():
        kaynaklar = api("package_show", id=paket)["resources"]
        print(f"{paket}: {len(kaynaklar)} kaynak")
        for kaynak in kaynaklar:
            ay = ay_bul(kaynak.get("name", ""), ayar["yil"], kaynak.get("url", ""))
            if ay not in ayar["aylar"] or (kaynak.get("format") or "").upper() != "CSV":
                continue
            ad = f"{ayar['kisa']}_{ayar['yil']}_{ay:02d}.csv.gz"
            ham = GECICI / f"{ayar['kisa']}_{ayar['yil']}_{ay:02d}.csv"
            print(f"  {kaynak['name']} -> {ad}")
            indir(kaynak["url"], ham)
            bilgi = profil(baglanti, str(ham))
            bilgi.update({"kaynak_adi": kaynak["name"], "kaynak_adresi": kaynak["url"],
                          "kaynak_dosya_adi": kaynak["url"].rsplit("/", 1)[-1], "kaynak_kimligi": kaynak["id"]})
            profiller[ad] = bilgi
            if ayar["kusur"]:
                kusur_yerlestir(baglanti, str(ham), str(CIKTI / ad), bilgi["ayirici"])
            else:
                sikistir(ham, CIKTI / ad)
            ham.unlink()
            yol = CIKTI / ad
            dosyalar.append({"ad": ad, "sha256": ozet(yol), "boyut": yol.stat().st_size,
                             "kaynak": kaynak["name"], "lisans": "İBB Açık Veri Lisansı"})
    beklenen = sum(len(a["aylar"]) for a in SECIM.values())
    if len(dosyalar) != beklenen:
        print(f"Beklenen {beklenen} dosya, hazırlanan {len(dosyalar)}", file=sys.stderr)
        sys.exit(1)
    liste = {"surum": SURUM, "taban_adres": f"https://github.com/{DEPO}/releases/download/{SURUM}",
             "dosyalar": sorted(dosyalar, key=lambda d: d["ad"])}
    (KOK / "lab" / "veri_listesi.json").write_text(json.dumps(liste, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (KOK / "lab" / "veri_profili.json").write_text(json.dumps(profiller, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{len(dosyalar)} dosya hazır: {sum(d['boyut'] for d in dosyalar) / 1024 / 1024:.0f} MB")


if __name__ == "__main__":
    main()
