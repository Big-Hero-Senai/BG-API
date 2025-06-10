#!/bin/bash
# Ì∫Å Quick Deploy V2.1.0 - Com Auto-Sleep
# Baseado no deploy.sh existente

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Ì∫Å DEPLOY SENAI MONITORING API V2.1.0${NC}"
echo "Ìªå Com configura√ß√£o auto-sleep habilitada"
echo "========================================"
echo ""

# 1. Verificar login
echo "ÔøΩÔøΩ 1. Verificando login Fly.io..."
if ! flyctl auth whoami > /dev/null 2>&1; then
    echo -e "${RED}‚ùå Execute: flyctl auth login${NC}"
    exit 1
fi
echo -e "${GREEN}‚úÖ Login confirmado${NC}"

# 2. Verificar arquivos
echo ""
echo "Ì≥ã 2. Verificando arquivos V2.1.0..."
if [ ! -f "Dockerfile" ] || [ ! -f "fly.toml" ] || [ ! -f "bin/server.dart" ]; then
    echo -e "${RED}‚ùå Arquivos essenciais n√£o encontrados!${NC}"
    exit 1
fi
echo -e "${GREEN}‚úÖ Arquivos verificados${NC}"

# 3. An√°lise de c√≥digo
echo ""
echo "Ì∑™ 3. An√°lise de c√≥digo..."
if dart analyze --fatal-infos > /dev/null 2>&1; then
    echo -e "${GREEN}‚úÖ C√≥digo limpo${NC}"
else
    echo -e "${YELLOW}‚ö†Ô∏è Aviso: Issues encontrados (continuando...)${NC}"
fi

# 4. Verificar/criar app
echo ""
echo "Ì¥ß 4. Configurando aplica√ß√£o..."
if flyctl apps list | grep -q "senai-monitoring-api"; then
    echo -e "${YELLOW}‚ö†Ô∏è App j√° existe - fazendo deploy${NC}"
else
    echo "Ì≥¶ Criando nova aplica√ß√£o..."
    flyctl launch --no-deploy --name senai-monitoring-api --region gru
fi

# 5. Configurar secrets
echo ""
echo "Ì¥ê 5. Configurando secrets..."
flyctl secrets set FIREBASE_PROJECT_ID=senai-monitoring-api > /dev/null 2>&1
echo -e "${GREEN}‚úÖ Secrets configurados${NC}"

# 6. Deploy
echo ""
echo "Ì∫Ä 6. Executando deploy..."
echo "   Ìªå Auto-sleep: HABILITADO"
echo "   Ì≤æ Mem√≥ria: 256MB (economia)"
echo "   ‚è±Ô∏è Sleep ap√≥s: 5min sem tr√°fego"
echo ""

if flyctl deploy --no-cache; then
    echo -e "${GREEN}‚úÖ Deploy conclu√≠do!${NC}"
else
    echo -e "${RED}‚ùå Erro no deploy${NC}"
    exit 1
fi

# 7. Aguardar e testar
echo ""
echo "‚è≥ 7. Aguardando inicializa√ß√£o..."
sleep 15

echo ""
echo "Ì∑™ 8. Testando API..."
URL="https://senai-monitoring-api.fly.dev"

if curl -f "$URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}‚úÖ API online!${NC}"
    echo "Ì≥° Health: $URL/health"
    echo "Ì≥ä Stats: $URL/api/iot/stats"
    echo "Ì≥ñ Docs: $URL/"
else
    echo -e "${YELLOW}‚ö†Ô∏è API iniciando... (teste manual)${NC}"
    echo "Ì¥ó URL para testar: $URL/health"
fi

echo ""
echo -e "${GREEN}Ìæâ DEPLOY V2.1.0 CONCLU√çDO!${NC}"
echo "==============================="
echo "Ìªå Auto-sleep: M√°quina hiberna ap√≥s 5min"
echo "‚ö° Auto-start: Acorda automaticamente com requests"
echo "Ì≤∞ Custo: M√≠nimo (s√≥ paga quando ativa)"
echo ""
echo "Ì¥ó URL: $URL"
echo "ÔøΩÔøΩ Status: flyctl status"
echo "Ì≥ä Logs: flyctl logs"
