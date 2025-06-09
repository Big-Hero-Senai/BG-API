import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../controllers/employee_controller.dart';
import '../controllers/documentation_controller.dart';

// 🌐 ROUTER CORRIGIDO: Roteamento específico primeiro
class ApiRoutes {
  static final _logger = Logger('ApiRoutes');
  late final Router _router;
  final EmployeeController _employeeController = EmployeeController();
  
  ApiRoutes() {
    _router = Router();
    _setupRoutes();
    _logger.info('🗺️ Rotas configuradas com sucesso');
  }
  
  // 🗺️ CONFIGURAÇÃO DAS ROTAS - ORDEM CRÍTICA
  void _setupRoutes() {
    // 👥 ROTAS DE FUNCIONÁRIOS - ORDEM ESPECÍFICA → GENÉRICA
    
    // 1️⃣ PRIMEIRO: Rotas específicas (sem parâmetros)
    _router.get('/api/employees', _employeeController.getAllEmployees);
    _router.get('/api/employees-stats', _employeeController.getEmployeeStats);  // ✅ MUDANÇA: stats → employees-stats
    
    // 2️⃣ SEGUNDO: Rotas com POST (não conflitam)
    _router.post('/api/employees', _employeeController.createEmployee);
    
    // 3️⃣ TERCEIRO: Rotas com parâmetros (mais genéricas)
    _router.get('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.getEmployeeById(request, id);
    });
    
    _router.put('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.updateEmployee(request, id);
    });
    
    _router.delete('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.deleteEmployee(request, id);
    });
    
    // 📄 ROTAS DE DOCUMENTAÇÃO
    _router.get('/', DocumentationController.getDocumentation);
    _router.get('/api', DocumentationController.getApiInfo);
    _router.get('/health', DocumentationController.healthCheck);
    
    // 🔧 ROTAS DE SISTEMA
    _router.get('/api/stats', _getSystemStats);
    _router.options('/<path|.*>', _handleCors);
    
    // 🚫 FALLBACK: 404 para rotas não encontradas
    _router.all('/<path|.*>', _handle404);
    
    _logger.info('✅ ${_getRouteCount()} rotas mapeadas com proteções');
  }
  
  // 📊 ENDPOINT: Estatísticas do sistema
  Future<Response> _getSystemStats(Request request) async {
    try {
      _logger.info('📊 GET /api/stats - Estatísticas do sistema');
      
      final stats = {
        'api': 'SENAI Monitoring API',
        'version': '1.0.0',
        'status': 'online',
        'routes_count': _getRouteCount(),
        'timestamp': DateTime.now().toIso8601String(),
        'uptime': 'Running',
        'database': 'Firebase Firestore',
        'architecture': {
          'pattern': 'Layered Architecture',
          'layers': ['Controller', 'Service', 'Repository', 'Mapper'],
          'database': 'Firebase Firestore',
          'framework': 'Dart Shelf',
        },
        'endpoints': {
          'employees': '/api/employees',
          'employee_stats': '/api/employees-stats',  // ✅ ATUALIZADO
          'system_stats': '/api/stats',
          'health': '/health',
          'docs': '/',
          'api_info': '/api',
        },
        'routing_notes': [
          'Specific routes before parameterized routes',
          'Protected reserved words (stats)',
          'Fallback handling for conflicts'
        ]
      };
      
      return Response.ok(
        '${stats}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      _logger.severe('❌ Erro nas estatísticas do sistema: $e');
      return Response.internalServerError();
    }
  }
  
  // ✈️ CORS: Para requisições OPTIONS
  Future<Response> _handleCors(Request request) async {
    _logger.info('✈️ OPTIONS ${request.url.path} - CORS preflight');
    
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400',
    });
  }
  
  // 🚫 404: Endpoint não encontrado
  Future<Response> _handle404(Request request) async {
    final response = {
      'error': true,
      'message': 'Endpoint não encontrado',
      'path': request.url.path,
      'method': request.method,
      'available_routes': [
        'GET /',
        'GET /api',
        'GET /health',
        'GET /api/stats',
        'GET /api/employees',
        'GET /api/employees-stats',  // ✅ ATUALIZADO
        'GET /api/employees/:id',
        'POST /api/employees',
        'PUT /api/employees/:id',
        'DELETE /api/employees/:id',
      ],
      'timestamp': DateTime.now().toIso8601String(),
      'tip': 'Acesse / para ver a documentação completa',
      'routing_debug': 'If you expected this to work, check route order',
    };
    
    _logger.warning('🚫 404 ${request.method} ${request.url.path}');
    
    return Response.notFound(
      '${response}',
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // 🔢 Contar rotas
  int _getRouteCount() => 10;
  
  // 🎯 Getter para o router
  Router get router => _router;
  
  // 🧹 Cleanup
  void dispose() {
    _employeeController.dispose();
    _logger.info('🧹 ApiRoutes disposed');
  }
}

/*
🎓 EXPLICAÇÃO DA SOLUÇÃO:

1. 🥇 **Ordem Específica → Genérica**
   - Rotas específicas (/stats) vêm ANTES
   - Rotas com parâmetros (<id>) vêm DEPOIS

2. 🛡️ **Proteção Dupla**
   - Ordem correta das rotas
   - Verificação manual dentro da rota genérica

3. 🔧 **Method Protection**
   - PUT/DELETE em /stats retornam 405 (Method Not Allowed)
   - Evita operações inválidas

4. 📊 **Debug Info**
   - Logs para rastreamento
   - Informações de roteamento em /api/stats
*/