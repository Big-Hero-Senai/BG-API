# 🐳 Dockerfile - SENAI Monitoring API V2.1.0
# Otimizado para produção no Fly.io

# ===========================================
# 🏗️ STAGE 1: BUILD STAGE
# ===========================================
FROM dart:stable AS build

# Metadata
LABEL maintainer="SENAI Monitoring API V2.1.0"
LABEL description="IoT Monitoring System with Hierarchical Architecture"
LABEL version="2.1.0"

# Configurar diretório de trabalho
WORKDIR /app

# Copiar pubspec files primeiro (para cache das dependências)
COPY pubspec.yaml pubspec.lock ./

# Instalar dependências
RUN dart pub get

# Copiar código fonte
COPY . .

# Verificar código
RUN dart analyze --fatal-infos

# Executar testes (opcional, pode ser removido para deploy mais rápido)
# RUN dart test

# Compilar aplicação para produção
RUN dart compile exe bin/server.dart -o bin/server

# ===========================================
# 🚀 STAGE 2: PRODUCTION STAGE
# ===========================================
FROM debian:bullseye-slim AS production

# Instalar dependências do sistema necessárias
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root para segurança
RUN useradd -r -s /bin/false senaiapp

# Configurar diretório de trabalho
WORKDIR /app

# Copiar executável compilado do stage de build
COPY --from=build /app/bin/server /app/server

# Copiar arquivos necessários em runtime (se houver)
COPY --from=build /app/.env.example /app/.env.example

# Ajustar permissões
RUN chown -R senaiapp:senaiapp /app
RUN chmod +x /app/server

# Configurar usuário
USER senaiapp

# Configurar variáveis de ambiente para produção
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

# Expor porta
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Comando para iniciar a aplicação
CMD ["/app/server"]