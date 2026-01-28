.PHONY: build start enter stop


build:
	docker build -t lab-image .

start:
	docker run -d --rm -t --name lab -v $$(pwd)/../dist:/var/www/html/etnz/reserve/releases/download/repo lab-image

enter:
	docker exec -it lab bash

stop:
	docker stop lab
