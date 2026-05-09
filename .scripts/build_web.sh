# Configurações
IMAGE_NAME = alexandreqrz/organizagrana
TAG = latest

.PHONY: all build image push clean

# Comando padrão: executa todo o ciclo de deploy
all: build image push

# 1. Compila o Flutter Web usando o seu script existente
build:
	@echo "🚀 Iniciando build Flutter Web..."
	@chmod +x ./scripts/build_web.sh
	./scripts/build_web.sh

# 2. Gera a imagem Docker
image:
	@echo "📦 Criando imagem Docker: $(IMAGE_NAME):$(TAG)"
	docker build -t $(IMAGE_NAME):$(TAG) .

# 3. Sobe para o Docker Hub
push:
	@echo "📤 Fazendo push para o Docker Hub..."
	docker push $(IMAGE_NAME):$(TAG)

# 4. Limpeza opcional de builds antigos
clean:
	@echo "🧹 Limpando artefatos de build..."
	flutter clean