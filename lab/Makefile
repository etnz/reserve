.PHONY: build start enter stop install-loi hack-sources install-groom check-loi check-groom purge-groom check-purge


build:
	docker build -t lab-image .

start:
	docker run -d --rm -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name lab -v $$(pwd)/../dist:/var/www/html/etnz/reserve/releases/download/repo lab-image

enter:
	docker exec -it lab bash

stop:
	docker stop lab

install-loi:
	docker exec lab bash -c "dpkg -i /var/www/html/etnz/reserve/releases/download/repo/*letter-of-introduction*.deb"

hack-sources:
	docker exec lab bash -c "sed -i 's|https://[^ ]*|file:///var/www/html/etnz/reserve/releases/download/repo|g' /etc/apt/sources.list.d/reserve.sources"
	docker exec lab apt-get update

install-groom:
	docker exec lab apt-get install -y pbc-groom-service

check-loi:
	docker exec -i lab bash < check-loi.sh

check-groom:
	docker exec -i lab bash < check-groom.sh

purge-groom:
	docker exec lab apt-get purge -y "pbc-*"

check-purge:
	docker exec -i lab bash < check-purge.sh
