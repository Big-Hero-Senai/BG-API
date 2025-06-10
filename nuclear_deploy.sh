#!/bin/bash

echo "🔥 DEPLOY NUCLEAR - RECRIAÇÃO COMPLETA DA API V2.1.0"
echo "=================================================="

# Verificar se está logado
echo "🔍 1. VERIFICANDO LOGIN FLY.IO..."
if ! flyctl auth whoami > /dev/null 2>&1; then
    echo "❌ Não está logado no Fly.io"
    echo "Execute: flyctl auth login"
    exit 1
fi

echo "✅ Login confirmado"

# Destruir aplicação existente
echo ""
echo "🗑️ 2. DESTRUINDO APLICAÇÃO ANTIGA..."
echo "ATENÇÃO: Isso vai remover a aplicação senai-monitoring-api completamente!"
read -p "Confirma destruição? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    flyctl apps destroy senai-monitoring-api --yes
    echo "✅ Aplicação destruída"
else
    echo "❌ Operação cancelada"
    exit 1
fi

# Aguardar um pouco
echo ""
echo "⏳ 3. AGUARDANDO LIMPEZA..."
sleep 5

# Verificar se código está correto
echo ""
echo "📋 4. VERIFICANDO CÓDIGO V2.1.0..."

# Verificar se arquivos essenciais existem
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile não encontrado!"
    exit 1
fi

if [ ! -f "fly.toml" ]; then
    echo "❌ fly.toml não encontrado!"
    exit 1
fi

if [ ! -f "bin/server.dart" ]; then
    echo "❌ bin/server.dart não encontrado!"
    exit 1
fi

# Verificar versão no código
if grep -q "2.1.0" "bin/server.dart" && grep -q "2.1.0" "fly.toml"; then
    echo "✅ Código V2.1.0 confirmado"
else
    echo "⚠️ AVISO: Versão pode não estar correta nos arquivos"
    echo "Verificar bin/server.dart e fly.toml"
fi

# Listar endpoints IoT no código
echo ""
echo "📡 5. VERIFICANDO ENDPOINTS IOT NO CÓDIGO..."
if grep -q "iot/health" "lib/src/routes/api_routes.dart"; then
    echo "✅ Endpoint /api/iot/health encontrado"
else
    echo "❌ Endpoint /api/iot/health NÃO encontrado!"
fi

if grep -q "iot/location" "lib/src/routes/api_routes.dart"; then
    echo "✅ Endpoint /api/iot/location encontrado"
else
    echo "❌ Endpoint /api/iot/location NÃO encontrado!"
fi

# Criar nova aplicação
echo ""
echo "🚀 6. CRIANDO NOVA APLICAÇÃO..."
flyctl launch --no-deploy --name senai-monitoring-api --copy-config

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar aplicação"
    exit 1
fi

echo "✅ Aplicação criada"

# Configurar secrets
echo ""
echo "🔐 7. CONFIGURANDO SECRETS..."
flyctl secrets set FIREBASE_PROJECT_ID=senai-monitoring-api

if [ $? -ne 0 ]; then
    echo "❌ Erro ao configurar secrets"
    exit 1
fi

echo "✅ Secrets configurados"

# Deploy limpo
echo ""
echo "🚀 8. DEPLOY LIMPO V2.1.0..."
flyctl deploy --no-cache

if [ $? -ne 0 ]; then
    echo "❌ Erro no deploy"
    exit 1
fi

echo "✅ Deploy concluído"

# Aguardar inicialização
echo ""
echo "⏳ 9. AGUARDANDO INICIALIZAÇÃO..."
sleep 10

# Verificar status
echo ""
echo "📊 10. VERIFICANDO STATUS..."
flyctl status

# Testar versão
echo ""
echo "🧪 11. TESTANDO VERSÃO..."
echo "Health check:"
curl -s https://senai-monitoring-api.fly.dev/health | jq '.'

echo ""
echo "Documentação API:"
curl -s https://senai-monitoring-api.fly.dev/api | jq '.endpoints'

echo ""
echo "🎉 DEPLOY NUCLEAR CONCLUÍDO!"
echo "=========================="
echo "🔍 Verificar se versão é 2.1.0"
echo "📡 Verificar se endpoints IoT aparecem"
echo "🧪 Testar população do banco se tudo ok"