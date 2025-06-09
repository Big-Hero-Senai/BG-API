// 📁 lib/src/routes/api_routes.dart
// ADIÇÕES PARA O CAPÍTULO 5: IoT INTEGRATION

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../controllers/employee_controller.dart';
import '../controllers/documentation_controller.dart';
import '../controllers/iot_controller.dart';  // ✅ NOVA IMPORTAÇÃO

// 🌐 ROUTER: Roteamento completo com IoT
class ApiRoutes {
  static final _logger = Logger('ApiRoutes');
  late final Router _router;
  final EmployeeController _employeeController = EmployeeController();
  final IoTController _iotController = IoTController();  // ✅ NOVO CONTROLLER
  
  ApiRoutes() {
    _router = Router();
    _setupRoutes();
    _logger.info('🗺️ Rotas configuradas com sucesso (incluindo IoT)');
  }
  
  // 🗺️ CONFIGURAÇÃO DAS ROTAS - INCLUINDO IoT
  void _setupRoutes() {
    // 👥 ROTAS DE FUNCIONÁRIOS (existentes)
    _router.get('/api/employees', _employeeController.getAllEmployees);
    _router.get('/api/employees-stats', _employeeController.getEmployeeStats);
    _router.post('/api/employees', _employeeController.createEmployee);
    _router.get('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.getEmployeeById(request, id);
    });
    _router.put('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.updateEmployee(request, id);
    });
    _router.delete('/api/employees/<id>', (Request request, String id) async {
      return await _employeeController.deleteEmployee(request, id);
    });
    
    // 📡 NOVAS ROTAS IoT - RECEBER DADOS DAS PULSEIRAS
    _router.post('/api/iot/health', _iotController.receiveHealthData);
    _router.post('/api/iot/location', _iotController.receiveLocationData);
    _router.post('/api/iot/batch', _iotController.receiveBatchData);
    
    // 🔍 ROTAS IoT - CONSULTAR DADOS
    _router.get('/api/iot/health/<employeeId>', (Request request, String employeeId) async {
      return await _iotController.getEmployeeHealthData(request, employeeId);
    });
    _router.get('/api/iot/location/<employeeId>', (Request request, String employeeId) async {
      return await _iotController.getEmployeeLocationData(request, employeeId);
    });
    
    // 📊 ROTAS IoT - ESTATÍSTICAS E ALERTAS
    _router.get('/api/iot/stats', _iotController.getIoTStats);
    _router.get('/api/iot/alerts', _iotController.getActiveAlerts);
    _router.post('/api/iot/test', _iotController.testIoTEndpoint);
    
    // 📄 ROTAS DE DOCUMENTAÇÃO (existentes)
    _router.get('/', DocumentationController.getDocumentation);
    _router.get('/api', DocumentationController.getApiInfo);
    _router.get('/health', DocumentationController.healthCheck);
    
    // 🔧 ROTAS DE SISTEMA (existentes)
    _router.get('/api/stats', _getSystemStats);
    _router.options('/<path|.*>', _handleCors);
    _router.all('/<path|.*>', _handle404);
    
    _logger.info('✅ ${_getRouteCount()} rotas mapeadas (incluindo ${_getIoTRouteCount()} rotas IoT)');
  }
  
  // 📊 ENDPOINT: Estatísticas do sistema (ATUALIZADO com IoT)
  Future<Response> _getSystemStats(Request request) async {
    try {
      _logger.info('📊 GET /api/stats - Estatísticas do sistema (com IoT)');
      
      final stats = {
        'api': 'SENAI Monitoring API',
        'version': '1.1.0',  // ✅ VERSÃO ATUALIZADA para IoT
        'status': 'online',
        'routes_count': _getRouteCount(),
        'iot_routes_count': _getIoTRouteCount(),  // ✅ NOVO
        'timestamp': DateTime.now().toIso8601String(),
        'uptime': 'Running',
        'database': 'Firebase Firestore',
        'architecture': {
          'pattern': 'Layered Architecture',
          'layers': ['Controller', 'Service', 'Repository', 'Mapper'],
          'database': 'Firebase Firestore',
          'framework': 'Dart Shelf',
          'iot_integration': true,  // ✅ NOVO
        },
        'endpoints': {
          // Funcionários
          'employees': '/api/employees',
          'employee_stats': '/api/employees-stats',
          // IoT - Receber dados
          'iot_health': '/api/iot/health',
          'iot_location': '/api/iot/location',
          'iot_batch': '/api/iot/batch',
          // IoT - Consultar dados
          'iot_health_employee': '/api/iot/health/:employeeId',
          'iot_location_employee': '/api/iot/location/:employeeId',
          // IoT - Estatísticas
          'iot_stats': '/api/iot/stats',
          'iot_alerts': '/api/iot/alerts',
          'iot_test': '/api/iot/test',
          // Sistema
          'system_stats': '/api/stats',
          'health': '/health',
          'docs': '/',
          'api_info': '/api',
        },
        'iot_features': [
          'Health data reception',
          'Location tracking',
          'Batch processing',
          'Real-time alerts',
          'Employee data linking',
          'Statistics and analytics'
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
  
  // ✈️ CORS: Para requisições OPTIONS (existente)
  Future<Response> _handleCors(Request request) async {
    _logger.info('✈️ OPTIONS ${request.url.path} - CORS preflight');
    
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400',
    });
  }
  
  // 🚫 404: Endpoint não encontrado (ATUALIZADO com rotas IoT)
  Future<Response> _handle404(Request request) async {
    final response = {
      'error': true,
      'message': 'Endpoint não encontrado',
      'path': request.url.path,
      'method': request.method,
      'available_routes': [
        // Funcionários
        'GET /',
        'GET /api',
        'GET /health',
        'GET /api/stats',
        'GET /api/employees',
        'GET /api/employees-stats',
        'GET /api/employees/:id',
        'POST /api/employees',
        'PUT /api/employees/:id',
        'DELETE /api/employees/:id',
        // IoT
        'POST /api/iot/health',
        'POST /api/iot/location',
        'POST /api/iot/batch',
        'GET /api/iot/health/:employeeId',
        'GET /api/iot/location/:employeeId',
        'GET /api/iot/stats',
        'GET /api/iot/alerts',
        'POST /api/iot/test',
      ],
      'timestamp': DateTime.now().toIso8601String(),
      'tip': 'Acesse / para ver a documentação completa',
      'iot_available': true,  // ✅ NOVO
    };
    
    _logger.warning('🚫 404 ${request.method} ${request.url.path}');
    
    return Response.notFound(
      '${response}',
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  // 🔢 Contar rotas
  int _getRouteCount() => 18;  // ✅ ATUALIZADO: 10 funcionários + 8 IoT
  int _getIoTRouteCount() => 8;  // ✅ NOVO
  
  // 🎯 Getter para o router
  Router get router => _router;
  
  // 🧹 Cleanup
  void dispose() {
    _employeeController.dispose();
    _iotController.dispose();  // ✅ NOVO
    _logger.info('🧹 ApiRoutes disposed (incluindo IoT)');
  }
}

/*
🎓 ROTAS IoT ADICIONADAS:

📡 **Receber Dados das Pulseiras:**
- POST /api/iot/health        - Dados de saúde
- POST /api/iot/location      - Dados de localização  
- POST /api/iot/batch         - Múltiplos dados

🔍 **Consultar Dados IoT:**
- GET /api/iot/health/:id     - Histórico de saúde
- GET /api/iot/location/:id   - Histórico de localização

📊 **Estatísticas e Monitoramento:**
- GET /api/iot/stats          - Estatísticas IoT
- GET /api/iot/alerts         - Alertas ativos
- POST /api/iot/test          - Teste de conectividade

🔄 **Integração Completa:**
- Mantém todas rotas existentes
- Adiciona funcionalidades IoT
- Preserva documentação
- Sistema unificado
*/