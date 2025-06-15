#!/bin/bash
# 🚁 Quick Deploy V2.1.0 - Com Auto-Sleep
# Baseado no deploy.sh existente

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚁 DEPLOY SENAI MONITORING API V2.1.0${NC}"
echo "🛌 Com configuração auto-sleep habilitada"
echo "========================================"
echo ""

# 1. Verificar login
echo "🔍 1. Verificando login Fly.io..."
if ! flyctl auth whoami > /dev/null 2>&1; then
    echo "❌ Execute: flyctl auth login"
    exit 1
fi
echo -e "${GREEN}✅ Login confirmado${NC}"

# 2. Verificar arquivos
echo ""
echo "📋 2. Verificando arquivos V2.1.0..."
if [ ! -f "Dockerfile" ] || [ ! -f "fly.toml" ] || [ ! -f "bin/server.dart" ]; then
    echo "❌ Arquivos essenciais não encontrados!"
    exit 1
fi
echo -e "${GREEN}✅ Arquivos verificados${NC}"

# 3. Análise de código
echo ""
echo "🧪 3. Análise de código..."
if dart analyze --fatal-infos > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Código limpo${NC}"
else
    echo -e "${YELLOW}⚠️ Aviso: Issues encontrados${NC}"
fi

# 4. Verificar/criar app
echo ""
echo "🔧 4. Configurando aplicação..."
if flyctl apps list | grep -q "senai-monitoring-api"; then
    echo -e "${YELLOW}⚠️ App já existe - fazendo deploy${NC}"
else
    echo "📦 Criando nova aplicação..."
    flyctl launch --no-deploy --name senai-monitoring-api --region gru
fi

# 5. Configurar secrets
echo ""
echo "🔐 5. Configurando secrets..."
flyctl secrets set FIREBASE_PROJECT_ID=senai-monitoring-api > /dev/null 2>&1
echo -e "${GREEN}✅ Secrets configurados${NC}"

# 6. Deploy
echo ""
echo "🚀 6. Executando deploy..."
echo "   🛌 Auto-sleep: HABILITADO"
echo "   💾 Memória: 256MB (economia)"
echo "   ⏱️ Sleep após: 5min sem tráfego"
echo ""

if flyctl deploy --no-cache; then
    echo -e "${GREEN}✅ Deploy concluído!${NC}"
else
    echo "❌ Erro no deploy"
    exit 1
fi

# 7. Aguardar e testar
echo ""
echo "⏳ 7. Aguardando inicialização..."
sleep 15

echo ""
echo "🧪 8. Testando API..."
URL="https://senai-monitoring-api.fly.dev"

if curl -f "$URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API online!${NC}"
    echo "📡 Health: $URL/health"
    echo "📊 Stats: $URL/api/iot/stats"
    echo "📖 Docs: $URL/"
else
    echo -e "${YELLOW}⚠️ API iniciando... (normal)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 DEPLOY V2.1.0 CONCLUÍDO!${NC}"
echo "==============================="
echo "🛌 Auto-sleep: Máquina hiberna após 5min"
echo "⚡ Auto-start: Acorda automaticamente com requests"
echo "💰 Custo: Mínimo (só paga quando ativa)"
echo ""
echo "🔗 URL: $URL"
echo "💤 Status: flyctl status"
echo "📊 Logs: flyctl logs"