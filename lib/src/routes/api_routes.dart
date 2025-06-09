import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../controllers/employee_controller.dart';
import '../controllers/documentation_controller.dart';

// 🌐 ROUTER CORRIGIDO: Funciona com a nova arquitetura
class ApiRoutes {
  static final _logger = Logger('ApiRoutes');
  late final Router _router;
  final EmployeeController _employeeController = EmployeeController();
  
  ApiRoutes() {
    _router = Router();
    _setupRoutes();
    _logger.info('🗺️ Rotas configuradas com sucesso');
  }
  
  // 🗺️ CONFIGURAÇÃO DAS ROTAS
  void _setupRoutes() {
    // 👥 ROTAS DE FUNCIONÁRIOS - CRUD Completo
    _router.get('/api/employees', _employeeController.getAllEmployees);
    
    // ✅ CORREÇÃO: Passar parâmetro ID corretamente
    _router.get('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.getEmployeeById(request, id);
    });
    
    _router.post('/api/employees', _employeeController.createEmployee);
    
    // ✅ CORREÇÃO: Passar parâmetro ID corretamente
    _router.put('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.updateEmployee(request, id);
    });
    
    // ✅ CORREÇÃO: Passar parâmetro ID corretamente
    _router.delete('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.deleteEmployee(request, id);
    });
    
    // 📊 NOVO: Rota de estatísticas
    _router.get('/api/employees/stats', _employeeController.getEmployeeStats);
    
    // 📄 ROTAS DE DOCUMENTAÇÃO
    _router.get('/', DocumentationController.getDocumentation);
    _router.get('/api', DocumentationController.getApiInfo);
    _router.get('/health', DocumentationController.healthCheck);
    
    // 🔧 ROTAS DE SISTEMA
    _router.get('/api/stats', _getSystemStats);
    _router.options('/<path|.*>', _handleCors);
    
    // 🚫 FALLBACK: 404 para rotas não encontradas
    _router.all('/<path|.*>', _handle404);
    
    _logger.info('✅ ${_getRouteCount()} rotas mapeadas');
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
          'employee_stats': '/api/employees/stats',
          'system_stats': '/api/stats',
          'health': '/health',
          'docs': '/',
          'api_info': '/api',
        },
        'features': [
          'CRUD completo de funcionários',
          'Validações robustas',
          'Regras de negócio',
          'Logs estruturados',
          'Error handling',
          'Documentação interativa',
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
        'GET /api/employees/stats',
        'GET /api/employees/:id',
        'POST /api/employees',
        'PUT /api/employees/:id',
        'DELETE /api/employees/:id',
      ],
      'timestamp': DateTime.now().toIso8601String(),
      'tip': 'Acesse / para ver a documentação completa',
    };
    
    _logger.warning('🚫 404 ${request.method} ${request.url.path}');
    
    return Response.notFound(
      '${response}',
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // 🔢 Contar rotas
  int _getRouteCount() => 10; // Atualizado com as novas rotas
  
  // 🎯 Getter para o router
  Router get router => _router;
  
  // 🧹 Cleanup
  void dispose() {
    _employeeController.dispose();
    _logger.info('🧹 ApiRoutes disposed');
  }
}

/*
🎓 MELHORIAS IMPLEMENTADAS:

1. ✅ **Parâmetros Corrigidos**
   - Rotas com <id> passam parâmetros corretamente
   - Async/await implementado adequadamente
   - Type safety mantido

2. ✅ **Novos Endpoints**
   - /api/employees/stats - Estatísticas de funcionários
   - /api/stats - Estatísticas do sistema
   - CORS handling melhorado

3. ✅ **Error Handling**
   - 404 personalizado com rotas disponíveis
   - CORS preflight handling
   - Logs estruturados

4. ✅ **Documentation**
   - Lista de rotas disponíveis
   - Informações da arquitetura
   - Tips úteis nos erros

5. ✅ **Resource Management**
   - Dispose pattern
   - Cleanup adequado
   - Gestão de ciclo de vida
*/