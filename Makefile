# İstanbul Mobilite Veri Platformu | lab komutları
# Her hedef, lab klasöründeki betiklerden birini çalıştırır.
SHELL := /bin/bash
LAB_KOK := $(CURDIR)
export LAB_KOK
export SPARK_CONF_DIR := $(LAB_KOK)/.lab/spark

.PHONY: yardim ilk-kurulum baslat durdur durum sql spark kafka-baslat kafka-durdur veri kontrol oz-degerlendirme

yardim:
	@echo "make baslat            PostgreSQL ve Polaris'i başlatır"
	@echo "make durdur            Çalışan lab servislerini durdurur"
	@echo "make durum             Servislerin durumunu gösterir"
	@echo "make sql               DuckDB'yi lab kataloğuna bağlı olarak açar"
	@echo "make spark             PySpark kabuğunu lab kataloğuna bağlı olarak açar"
	@echo "make kafka-baslat      Kafka'yı başlatır"
	@echo "make kafka-durdur      Kafka'yı durdurur"
	@echo "make veri              Lab veri setlerini indirir ve doğrular"
	@echo "make kontrol           Ortamı adım adım sınar ve hazırlık kodunu üretir"
	@echo "make oz-degerlendirme  Ön koşul öz değerlendirmesini çalıştırır"

ilk-kurulum:
	@bash lab/servis.sh ilk-kurulum

baslat:
	@bash lab/servis.sh baslat

durdur:
	@bash lab/servis.sh durdur

durum:
	@bash lab/servis.sh durum

sql: baslat
	@duckdb -no-agent -init .lab/baglan.sql .lab/calisma.duckdb

spark: baslat
	@pyspark

kafka-baslat:
	@bash lab/servis.sh kafka-baslat

kafka-durdur:
	@bash lab/servis.sh kafka-durdur

veri:
	@python3 lab/veri_indir.py

kontrol:
	@python3 lab/kontrol.py

oz-degerlendirme:
	@python3 on-hazirlik/oz_degerlendirme.py
