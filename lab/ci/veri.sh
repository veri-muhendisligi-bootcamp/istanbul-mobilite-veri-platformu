#!/usr/bin/env bash
# İBB verisini indirir ve hazırlar, sürüm eki olarak yayımlar, lab/veri_listesi.json dosyasını main dalına işler.
set -euo pipefail
source lab/ci/ortak.sh

case "${ETIKET:-}" in
  veri-v*) SURUM="${ETIKET}" ;;
  *) SURUM="veri-v1" ;;
esac
export VERI_SURUMU="${SURUM}" GITHUB_REPOSITORY="${DEPO}"

python3 -m pip install --quiet duckdb==2.0.0 numpy
python3 lab/veri_hazirla.py
cp lab/veri_profili.json "${SONUC_DIZIN}/veri_profili.json"

NOT="Kaynak: İstanbul Büyükşehir Belediyesi Açık Veri Portalı (data.ibb.gov.tr). Lisans: İBB Açık Veri Lisansı. Dosyalar eğitim için yeniden düzenlenmiştir."
if gh release view "${SURUM}" -R "${DEPO}" >/dev/null 2>&1; then
  gh release upload "${SURUM}" veri_hazir/*.csv.gz -R "${DEPO}" --clobber
else
  gh release create "${SURUM}" veri_hazir/*.csv.gz -R "${DEPO}" --title "Lab verisi (${SURUM})" --notes "${NOT}"
fi
ls -l veri_hazir

main_dalina_isle "Veri listesi: ${SURUM}" lab/veri_listesi.json
