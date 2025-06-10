#!/bin/bash
# 🚁 deploy.sh - Script de Deploy Automatizado para Fly.io
# SENAI Monitoring API V2.1.0

set -e  # Exit em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Banner
echo -e "${BLUE}"
echo "🚁 =========================================="
echo "   SENAI MONITORING API V2.1.0 DEPLOY"
echo "   Fly.io Automated Deployment Script"
echo "==========================================${NC}"
echo ""

# ===========================================
# 🔍 PRÉ-VERIFICAÇÕES
# ===========================================
log "Executando pré-verificações..."

# Verificar se flyctl está instalado
if ! command -v flyctl &> /dev/null; then
    error "flyctl não está instalado. Instale em: https://fly.io/docs/hands-on/install-flyctl/"
fi

# Verificar se está logado no Fly.io
if ! flyctl auth whoami &> /dev/null; then
    warning "Não está logado no Fly.io. Execute: flyctl auth login"
    exit 1
fi

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    error "Execute este script no diretório raiz do projeto (onde está pubspec.yaml)"
fi

# Verificar se o servidor local está rodando (para testes)
if curl -s http://localhost:8080/health > /dev/null; then
    warning "Servidor local está rodando. Será usado para validação final."
    LOCAL_SERVER_RUNNING=true
else
    warning "Servidor local não está rodando. Testes locais serão pulados."
    LOCAL_SERVER_RUNNING=false
fi

success "Pré-verificações concluídas"

# ===========================================
# 🧪 TESTES PRÉ-DEPLOY (OPCIONAL)
# ===========================================
if [ "$LOCAL_SERVER_RUNNING" = true ]; then
    read -p "🧪 Executar testes completos pré-deploy? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Executando testes pré-deploy..."
        if dart run bin/test_pre_deploy_complete.dart; then
            success "Todos os testes passaram!"
        else
            error "Testes falharam. Corrija os problemas antes do deploy."
        fi
    fi
fi

# ===========================================
# 🏗️ BUILD E VALIDAÇÃO LOCAL
# ===========================================
log "Validando código Dart..."

# Análise de código
if dart analyze --fatal-infos; then
    success "Análise de código passou"
else
    error "Análise de código falhou"
fi

# Verificar dependências
log "Verificando dependências..."
if dart pub get; then
    success "Dependências atualizadas"
else
    error "Erro ao atualizar dependências"
fi

# Compilação local (teste)
log "Testando compilação..."
if dart compile exe bin/server.dart -o bin/server_test; then
    success "Compilação bem-sucedida"
    rm -f bin/server_test  # Limpar arquivo de teste
else
    error "Erro na compilação"
fi

# ===========================================
# 🔧 CONFIGURAÇÃO FLY.IO
# ===========================================
log "Configurando aplicação no Fly.io..."

# Verificar se a aplicação já existe
if flyctl apps list | grep -q "senai-monitoring-api"; then
    warning "Aplicação 'senai-monitoring-api' já existe"
    read -p "🔄 Fazer deploy em aplicação existente? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        error "Deploy cancelado pelo usuário"
    fi
else
    log "Criando nova aplicação..."
    if flyctl launch --no-deploy --name senai-monitoring-api --region gru --copy-config; then
        success "Aplicação criada no Fly.io"
    else
        error "Erro ao criar aplicação"
    fi
fi

# ===========================================
# 🔐 CONFIGURAÇÃO DE SECRETS
# ===========================================
log "Configurando secrets..."

# Firebase Project ID
read -p "🔥 Digite o FIREBASE_PROJECT_ID (senai-monitoring-api): " FIREBASE_PROJECT_ID
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-senai-monitoring-api}

if flyctl secrets set FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID"; then
    success "FIREBASE_PROJECT_ID configurado"
else
    warning "Erro ao configurar FIREBASE_PROJECT_ID"
fi

# Configurar outros secrets se necessário
read -p "🔐 Configurar secrets adicionais? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Digite outros secrets no formato KEY=VALUE (enter vazio para finalizar):"
    while read -p "Secret: " secret; do
        if [ -z "$secret" ]; then
            break
        fi
        if flyctl secrets set "$secret"; then
            success "Secret configurado: $secret"
        else
            warning "Erro ao configurar secret: $secret"
        fi
    done
fi

# ===========================================
# 🚀 DEPLOY
# ===========================================
log "Iniciando deploy..."

# Mostrar informações do deploy
echo ""
echo "📋 INFORMAÇÕES DO DEPLOY:"
echo "   • Aplicação: senai-monitoring-api"
echo "   • Região: gru (São Paulo)"
echo "   • Versão: V2.1.0"
echo "   • Dockerfile: Otimizado para produção"
echo ""

read -p "🚀 Continuar com o deploy? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    error "Deploy cancelado pelo usuário"
fi

# Executar deploy
log "Executando deploy no Fly.io..."
if flyctl deploy; then
    success "Deploy concluído com sucesso!"
else
    error "Erro durante o deploy"
fi

# ===========================================
# ✅ VALIDAÇÃO PÓS-DEPLOY
# ===========================================
log "Validando deploy..."

# Aguardar um pouco para o serviço inicializar
sleep 10

# Obter URL da aplicação
APP_URL=$(flyctl status --json | grep -o '"hostname":"[^"]*"' | cut -d'"' -f4)
if [ -z "$APP_URL" ]; then
    APP_URL="senai-monitoring-api.fly.dev"
fi

FULL_URL="https://$APP_URL"

# Teste de health check
log "Testando health check..."
if curl -f "$FULL_URL/health" > /dev/null 2>&1; then
    success "Health check passou"
else
    warning "Health check falhou - aplicação pode estar inicializando"
fi

# Teste de endpoint de teste
log "Testando endpoint de teste..."
if curl -f "$FULL_URL/api/iot/test" > /dev/null 2>&1; then
    success "Endpoint de teste funcionando"
else
    warning "Endpoint de teste não respondeu"
fi

# ===========================================
# 📊 RELATÓRIO FINAL
# ===========================================
echo ""
echo -e "${GREEN}🎉 DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo "=========================================="
echo ""
echo "📡 URL da API: $FULL_URL"
echo "🔍 Health Check: $FULL_URL/health"
echo "📊 Documentação: $FULL_URL/"
echo "📈 Stats: $FULL_URL/api/stats"
echo ""
echo "🔧 COMANDOS ÚTEIS:"
echo "   • Ver logs: flyctl logs"
echo "   • Status: flyctl status"
echo "   • Escalar: flyctl scale count 2"
echo "   • SSH: flyctl ssh console"
echo ""
echo "🌐 PRÓXIMO PASSO:"
echo "   • Atualizar dashboard para usar: $FULL_URL"
echo "   • Testar integração completa"
echo ""

# Abrir URLs no navegador (opcional)
read -p "🌐 Abrir URLs no navegador? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then
        open "$FULL_URL"
        open "$FULL_URL/health"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$FULL_URL"
        xdg-open "$FULL_URL/health"
    else
        echo "Abra manualmente: $FULL_URL"
    fi
fi

success "Script de deploy finalizado!"