# 🏭 SENAI Monitoring API

[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![API Status](https://img.shields.io/badge/API-Operational-brightgreen.svg)](#)

**Sistema de Monitoramento de Funcionários com Pulseiras IoT**

API REST desenvolvida em Dart + Shelf para gerenciar funcionários e receber dados de pulseiras de monitoramento IoT em ambiente industrial.

---

## 🎯 **Sobre o Projeto**

### **Objetivo**
Desenvolver uma API robusta para o sistema de monitoramento de funcionários do SENAI, integrando:
- **Pulseiras IoT** para coleta de dados de saúde e localização
- **Dashboard Web** para visualização em tempo real
- **Banco Firebase** para armazenamento escalável

### **Arquitetura do Sistema**
```
Pulseiras IoT → API REST (Dart) → Firebase Firestore
                     ↓
               Dashboard Web (GitHub Pages)
```

---

## 🚀 **Funcionalidades**

### **✅ Implementado**
- 👥 **CRUD Completo de Funcionários**
- 🔥 **Integração Firebase Firestore**
- 🛡️ **Validações Robustas de Dados**
- 🌐 **CORS Configurado para Frontend**
- 📋 **Documentação Interativa (HTML)**
- 🏥 **Health Checks e Monitoramento**
- 🔒 **Variáveis de Ambiente para Segurança**
- 📊 **Logs Estruturados**

### **🔄 Em Desenvolvimento**
- 📱 Recebimento de dados das pulseiras IoT
- 📊 Dashboard web interativo
- 🔐 Sistema de autenticação
- 📈 Alertas e relatórios automáticos

---

## 📋 **Endpoints da API**

### **👥 Funcionários**
| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/employees` | Lista todos os funcionários |
| `GET` | `/api/employees/:id` | Busca funcionário específico |
| `POST` | `/api/employees` | Cria novo funcionário |
| `PUT` | `/api/employees/:id` | Atualiza funcionário |
| `DELETE` | `/api/employees/:id` | Remove funcionário |

### **🔧 Sistema**
| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/health` | Status da API |
| `GET` | `/api` | Informações da API (JSON) |
| `GET` | `/` | Documentação interativa |

---

## 🛠️ **Tecnologias Utilizadas**

### **Backend**
- **[Dart 3.0+](https://dart.dev)** - Linguagem principal
- **[Shelf](https://pub.dev/packages/shelf)** - Framework web minimalista
- **[Firebase Firestore](https://firebase.google.com)** - Banco NoSQL
- **[dotenv](https://pub.dev/packages/dotenv)** - Gerenciamento de variáveis

### **Ferramentas**
- **Git** - Controle de versão
- **Firebase Console** - Gerenciamento do banco
- **Insomnia/Postman** - Testes de API

---

## ⚙️ **Instalação e Configuração**

### **Pré-requisitos**
- [Dart SDK 3.0+](https://dart.dev/get-dart)
- [Git](https://git-scm.com)
- Conta [Firebase](https://firebase.google.com)

### **1. Clonar o Repositório**
```bash
git clone https://github.com/seu-usuario/senai-monitoring-api.git
cd senai-monitoring-api
```

### **2. Instalar Dependências**
```bash
dart pub get
```

### **3. Configurar Firebase**

#### **3.1 Criar Projeto Firebase**
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar projeto"
3. Nome: `senai-monitoring-api` (ou seu preferido)
4. Ative **Firestore Database**

#### **3.2 Configurar Regras do Firestore**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Para desenvolvimento
    }
  }
}
```

### **4. Configurar Variáveis de Ambiente**

#### **4.1 Criar arquivo .env**
```bash
cp .env.example .env
```

#### **4.2 Editar .env com suas configurações**
```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=seu-project-id-aqui

# Server Configuration  
PORT=8080
HOST=localhost
NODE_ENV=development

# API Configuration
API_VERSION=1.0.0
API_NAME=SENAI Monitoring API

# CORS (URLs permitidas, separadas por vírgula)
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Logging
LOG_LEVEL=INFO
```

### **5. Executar a API**
```bash
dart run bin/server
```

🎉 **API rodando em:** http://localhost:8080

---

## 📖 **Como Usar**

### **Acessar Documentação**
```
http://localhost:8080
```

### **Testar Health Check**
```bash
curl http://localhost:8080/health
```

### **Criar Funcionário**
```bash
curl -X POST http://localhost:8080/api/employees \
  -H "Content-Type: application/json" \
  -d '{
    "id": "EMP001",
    "nome": "João Silva",
    "email": "joao@senai.com",
    "setor": "producao",
    "data_admissao": "2023-01-15T00:00:00.000Z",
    "ativo": true
  }'
```

### **Listar Funcionários**
```bash
curl http://localhost:8080/api/employees
```

---

## 🧪 **Testes**

### **Executar Teste Automatizado**
```bash
dart run bin/test_api_complete
```

### **Testar com Insomnia/Postman**
Importe a coleção de testes disponível em `/docs/insomnia-collection.json`

---

## 📁 **Estrutura do Projeto**

```
senai_monitoring_api/
├── bin/
│   ├── server.dart                 # Servidor principal
│   └── test_api_complete.dart      # Teste automatizado
├── lib/src/
│   ├── models/
│   │   └── employee.dart           # Model Employee
│   ├── services/
│   │   └── firebase_service.dart   # Integração Firebase
│   ├── controllers/
│   │   └── employee_controller.dart # Controller REST
│   └── routes/
│       └── api_routes.dart         # Configuração de rotas
├── .env.example                    # Template de configuração
├── .gitignore                      # Arquivos ignorados
├── pubspec.yaml                    # Dependências
└── README.md                       # Esta documentação
```

---

## 🔒 **Segurança**

### **Variáveis de Ambiente**
- ✅ Dados sensíveis em `.env` (não versionado)
- ✅ Template público em `.env.example`
- ✅ `.gitignore` configurado adequadamente

### **CORS**
- ✅ Origens configuráveis via `.env`
- ✅ Headers de segurança implementados

### **Validações**
- ✅ Validação de entrada de dados
- ✅ Sanitização de parâmetros
- ✅ Error handling robusto

---

## 📊 **Monitoramento**

### **Logs Estruturados**
```bash
# Visualizar logs em tempo real
dart run bin/server

# Configurar nível de log via .env
LOG_LEVEL=INFO  # ALL, INFO, WARNING, SEVERE
```

### **Health Check**
```bash
curl http://localhost:8080/health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "SENAI Monitoring API",
  "version": "1.0.0",
  "timestamp": "2025-06-07T15:30:00.000Z",
  "database": "Firebase Firestore"
}
```

---

## 🚀 **Deploy**

### **Desenvolvimento**
```bash
dart run bin/server
```

### **Produção (Fly.io) - Em Desenvolvimento**
```bash
# Será implementado no próximo sprint
fly deploy
```

---

## 🤝 **Contribuição**

### **Como Contribuir**
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### **Padrão de Commits**
```
feat: nova funcionalidade
fix: correção de bug
docs: documentação
style: formatação
refactor: refatoração
test: testes
chore: manutenção
```

---

## 📝 **Changelog**

### **v1.0.0** - 2025-06-07
- ✅ API REST completa com CRUD de funcionários
- ✅ Integração Firebase Firestore
- ✅ Documentação interativa
- ✅ Sistema de variáveis de ambiente
- ✅ Testes automatizados

---

## 🐛 **Problemas Conhecidos**

- [ ] Implementar rate limiting
- [ ] Adicionar autenticação JWT
- [ ] Melhorar tratamento de erros Firebase

---

## 📞 **Suporte**

### **Issues**
Reporte bugs ou sugira melhorias em: [GitHub Issues](https://github.com/seu-usuario/senai-monitoring-api/issues)

### **Contato**
- 📧 Email: seu-email@senai.com
- 🏢 SENAI - Unidade Fortaleza

---

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🏆 **Agradecimentos**

- **SENAI** - Pela oportunidade e infraestrutura
- **Comunidade Dart** - Pela documentação e suporte
- **Firebase** - Pela plataforma robusta

---

**Desenvolvido com ❤️ para o SENAI**

*Sistema de Monitoramento Industrial - Conectando Tecnologia e Segurança*