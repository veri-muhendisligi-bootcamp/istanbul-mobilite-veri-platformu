-- Oturum 1 | U1.1 Ham veri keşfi
-- make sql ile açılan DuckDB oturumunda çalışır: .read oturumlar/01/u1_1_ham_veri_kesfi.sql
CREATE OR REPLACE VIEW ham_ocak AS
SELECT * FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz');

DESCRIBE ham_ocak;
SELECT * FROM ham_ocak LIMIT 10;
SELECT count(*) AS satir FROM ham_ocak;

-- Aday anahtar ve anomali sorgularınız bu satırın altına gelir.
