default: help

help:
	@cat ~./Makefile

app:
	@docker-compose up -d

app-container:
	@docker-compose build pio_app

build: app-container engine
	@docker-compose run --rm pio_app bash -c 'cd /app/$$PIO_APP_NAME && pio build --verbose'

engine:
	@docker-compose run --rm pio_app bash -c ' \
	if [ ! -d /app/$$PIO_APP_NAME ]; then \
		mkdir -p /tmp/engine && git clone $$PIO_ENGINE /tmp/engine && mv /tmp/engine/ /app/$$PIO_APP_NAME; \
		cd /app/$$PIO_APP_NAME && sed -i "s/INVALID_APP_NAME/$$PIO_APP_NAME/" engine.json; \
	fi;'

bash:
	@docker-compose run --rm pio_app bash

stop:
	@docker-compose down

clean:
	@docker-compose down -v

logs:
	@docker-compose logs -f

sampledata:
	@./data/importdata.sh