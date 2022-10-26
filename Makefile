.PHONY: all
all: deploy

.PHONY: deploy
deploy: build serve

.PHONY: setup
setup:
	true

.PHONY: build
build:
	docker-compose build

.PHONY: serve
serve:
	docker-compose up -d

.PHONY: clean
clean:
	docker-compose down
