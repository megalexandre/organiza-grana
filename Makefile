IMAGE_NAME = alexandreqrz/organizagrana
TAG = latest

-include .env
export

DART_DEFINES = $(foreach var,$(shell grep -v '^\#' .env | grep -v '^$$' | cut -d= -f1),--dart-define=$(var)=$($(var)))

.PHONY: all run web build push clean

all: web build push

run:
	@echo "Iniciando Flutter em modo debug..."
	flutter run $(DART_DEFINES)

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
