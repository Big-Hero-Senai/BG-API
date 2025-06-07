import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logging/logging.dart';
import '../lib/src/routes/api_routes.dart';
import '../lib/src/services/firebase_service.dart';

// 📖 SERVIDOR PRINCIPAL - API REST COMPLETA
final _logger = Logger('SenaiAPI');

void main() async {
  // 📋 CONFIGURAR LOGS
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info('🚀 Iniciando SENAI Monitoring API...');

  // 🔥 TESTAR CONEXÃO FIREBASE
  final firebaseService = FirebaseService();
  final connected = await firebaseService.testConnection();
  
  if (!connected) {
    _logger.severe('❌ Falha na conexão com Firebase! Abortando...');
    return;
  }
  
  _logger.info('✅ Firebase conectado com sucesso!');

  // 🗺️ CONFIGURAR ROTAS
  final apiRoutes = ApiRoutes();
  final router = apiRoutes.router;

  // 📖 CONCEITO: Middleware Pipeline Completo
  final pipeline = Pipeline()
      .addMiddleware(logRequests())                    // 1️⃣ Log de todas requisições
      .addMiddleware(corsHeaders())                    // 2️⃣ CORS configurado
      .addMiddleware(_errorHandler)                    // 3️⃣ Tratamento de erros global
      .addHandler(router.call);                       // 4️⃣ Processar rotas

  // 🌐 INICIAR SERVIDOR
  const port = 8080;
  final server = await shelf_io.serve(pipeline, 'localhost', port);
  
  _logger.info('🌐 Servidor rodando em http://localhost:$port');
  _logger.info('📋 Endpoints disponíveis:');
  _logger.info('   🏠 GET  /                    - Documentação');
  _logger.info('   📊 GET  /api                 - Info da API');
  _logger.info('   🏥 GET  /health              - Health check');
  _logger.info('   👥 GET  /api/employees       - Listar funcionários');
  _logger.info('   🔍 GET  /api/employees/:id   - Buscar por ID');
  _logger.info('   ➕ POST /api/employees       - Criar funcionário');
  _logger.info('   🔄 PUT  /api/employees/:id   - Atualizar funcionário');
  _logger.info('   🗑️ DELETE /api/employees/:id - Deletar funcionário');
  
  print('');
  print('🎯 SENAI Monitoring API');
  print('📍 http://localhost:$port');
  print('📖 Documentação: http://localhost:$port');
  print('🧪 Health Check: http://localhost:$port/health');
  print('👥 Funcionários: http://localhost:$port/api/employees');
  print('💡 Pressione Ctrl+C para parar');
  print('');
  
  _logger.info('🎉 API iniciada com sucesso!');
}

// 🛡️ MIDDLEWARE: Tratamento de erros global
Middleware _errorHandler = (Handler innerHandler) {
  return (Request request) async {
    try {
      return await innerHandler(request);
    } catch (error, stackTrace) {
      _logger.severe('❌ Erro não tratado: $error');
      _logger.severe('📋 Stack trace: $stackTrace');
      
      final errorResponse = {
        'error': true,
        'message': 'Erro interno do servidor',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      return Response.internalServerError(
        body: '${errorResponse}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  };
};