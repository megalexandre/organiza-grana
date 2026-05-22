IMAGE_NAME = alexandreqrz/organizagrana
TAG = latest

-include .env
export

DART_DEFINES = $(foreach var,$(shell grep -v '^\#' .env | grep -v '^$$' | cut -d= -f1),--dart-define=$(var)=$($(var)))

.PHONY: all publish run chrome linux web build push clean

all: web build push

publish: web build push
	@echo "Publicação concluída: $(IMAGE_NAME):$(TAG)"

run:
	@echo "Iniciando Flutter em modo debug..."
	flutter run $(DART_DEFINES)

chrome:
	@echo "Iniciando Flutter no Chrome (CORS desabilitado)..."
	flutter run -d chrome --web-browser-flag="--disable-web-security"

linux:
	@echo "Iniciando Flutter no Linux..."
	flutter run -d linux

web:
	@echo "Gerando build Flutter Web..."
	flutter build web $(DART_DEFINES)

build:
	@echo "Criando imagem Docker: $(IMAGE_NAME):$(TAG)"
	docker build -t $(IMAGE_NAME):$(TAG) .

push:
	@echo "Fazendo push para o Docker Hub..."
	docker push $(IMAGE_NAME):$(TAG)

clean:
	@echo "Limpando artefatos de build..."
	flutter clean
