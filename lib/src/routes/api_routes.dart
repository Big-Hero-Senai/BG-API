import 'dart:convert';  // ✅ Para jsonEncode()
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/employee_controller.dart';

// 🌐 ROUTER: Mapeamento de URLs para Controllers
class ApiRoutes {
  late final Router _router;
  final EmployeeController _employeeController = EmployeeController();
  
  ApiRoutes() {
    _router = Router();
    _setupRoutes();
  }
  
  // 🗺️ CONFIGURAÇÃO DAS ROTAS
  void _setupRoutes() {
    // 📋 ROTAS DE FUNCIONÁRIOS
    _router.get('/api/employees', _employeeController.getAllEmployees);
    _router.get('/api/employees/<id>', _employeeController.getEmployeeById);
    _router.post('/api/employees', _employeeController.createEmployee);
    _router.put('/api/employees/<id>', _employeeController.updateEmployee);
    _router.delete('/api/employees/<id>', _employeeController.deleteEmployee);
    
    // 🏥 ROTA DE HEALTH CHECK
    _router.get('/health', _healthCheck);
    
    // 🏠 ROTA PRINCIPAL - Documentação
    _router.get('/', _apiDocumentation);
    
    // 📋 ROTA DE INFO DA API
    _router.get('/api', _apiInfo);
  }
  
  // 🏥 Health Check - Verifica se API está funcionando
  Response _healthCheck(Request request) {
    final health = {
      'status': 'healthy',
      'service': 'SENAI Monitoring API',
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'uptime': 'Running',
      'database': 'Firebase Firestore',
    };
    
    return Response.ok(
      jsonEncode(health),  // ✅ CORREÇÃO: usar jsonEncode()
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // 📋 Informações da API
  Response _apiInfo(Request request) {
    final info = {
      'api': 'SENAI Monitoring API',
      'version': '1.0.0',
      'description': 'API para monitoramento de funcionários com pulseiras IoT',
      'endpoints': {
        'employees': {
          'GET /api/employees': 'Lista todos os funcionários',
          'GET /api/employees/:id': 'Busca funcionário por ID',
          'POST /api/employees': 'Cria novo funcionário',
          'PUT /api/employees/:id': 'Atualiza funcionário',
          'DELETE /api/employees/:id': 'Remove funcionário',
        },
        'health': {
          'GET /health': 'Status da API',
        }
      },
      'example_employee': {
        'id': 'EMP001',
        'nome': 'João Silva',
        'email': 'joao@senai.com',
        'setor': 'producao',
        'data_admissao': '2023-01-15T00:00:00.000Z',
        'ativo': true,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return Response.ok(
      jsonEncode(info),  // ✅ CORREÇÃO: usar jsonEncode()
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // 🏠 Documentação principal (HTML)
  Response _apiDocumentation(Request request) {
    final html = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SENAI Monitoring API</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        .container { 
            max-width: 1000px; 
            margin: 0 auto; 
            padding: 20px;
        }
        .header {
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .api-title {
            font-size: 2.5em;
            color: #2c3e50;
            margin-bottom: 10px;
            font-weight: bold;
        }
        .subtitle {
            color: #7f8c8d;
            font-size: 1.2em;
        }
        .status {
            display: inline-block;
            background: #2ecc71;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            margin-top: 15px;
        }
        .endpoints {
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .endpoint-group {
            margin-bottom: 25px;
        }
        .endpoint-title {
            font-size: 1.4em;
            color: #2c3e50;
            margin-bottom: 15px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 5px;
        }
        .endpoint {
            display: flex;
            align-items: center;
            padding: 12px;
            margin: 8px 0;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }
        .method {
            font-weight: bold;
            padding: 4px 8px;
            border-radius: 4px;
            margin-right: 15px;
            color: white;
            min-width: 60px;
            text-align: center;
            font-size: 0.9em;
        }
        .get { background: #2ecc71; }
        .post { background: #f39c12; }
        .put { background: #9b59b6; }
        .delete { background: #e74c3c; }
        .url {
            font-family: 'Courier New', monospace;
            background: #ecf0f1;
            padding: 4px 8px;
            border-radius: 4px;
            margin-right: 15px;
            min-width: 200px;
        }
        .description {
            color: #555;
        }
        .example {
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .code {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 20px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            overflow-x: auto;
            margin: 15px 0;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            color: rgba(255,255,255,0.8);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 class="api-title">🏭 SENAI Monitoring API</h1>
            <p class="subtitle">Sistema de Monitoramento de Funcionários com Pulseiras IoT</p>
            <div class="status">🟢 API Online</div>
        </div>
        
        <div class="endpoints">
            <div class="endpoint-group">
                <h2 class="endpoint-title">👥 Funcionários</h2>
                
                <div class="endpoint">
                    <span class="method get">GET</span>
                    <span class="url">/api/employees</span>
                    <span class="description">Lista todos os funcionários</span>
                </div>
                
                <div class="endpoint">
                    <span class="method get">GET</span>
                    <span class="url">/api/employees/:id</span>
                    <span class="description">Busca funcionário específico</span>
                </div>
                
                <div class="endpoint">
                    <span class="method post">POST</span>
                    <span class="url">/api/employees</span>
                    <span class="description">Cria novo funcionário</span>
                </div>
                
                <div class="endpoint">
                    <span class="method put">PUT</span>
                    <span class="url">/api/employees/:id</span>
                    <span class="description">Atualiza funcionário</span>
                </div>
                
                <div class="endpoint">
                    <span class="method delete">DELETE</span>
                    <span class="url">/api/employees/:id</span>
                    <span class="description">Remove funcionário</span>
                </div>
            </div>
            
            <div class="endpoint-group">
                <h2 class="endpoint-title">🔧 Sistema</h2>
                
                <div class="endpoint">
                    <span class="method get">GET</span>
                    <span class="url">/health</span>
                    <span class="description">Status da API</span>
                </div>
                
                <div class="endpoint">
                    <span class="method get">GET</span>
                    <span class="url">/api</span>
                    <span class="description">Informações da API (JSON)</span>
                </div>
            </div>
        </div>
        
        <div class="example">
            <h2 class="endpoint-title">📋 Exemplo de Funcionário</h2>
            <div class="code">{
  "id": "EMP001",
  "nome": "João Silva",
  "email": "joao@senai.com",
  "setor": "producao",
  "data_admissao": "2023-01-15T00:00:00.000Z",
  "ativo": true
}</div>
        </div>
        
        <div class="footer">
            <p>🚀 Desenvolvido com Dart + Shelf + Firebase</p>
            <p>📅 ${DateTime.now().year} - Sistema SENAI</p>
        </div>
    </div>
</body>
</html>
    ''';
    
    return Response.ok(html, headers: {'Content-Type': 'text/html'});
  }
  
  // 🎯 Getter para o router
  Router get router => _router;
}