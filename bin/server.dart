import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logging/logging.dart';
import 'package:dotenv/dotenv.dart';
import '../lib/src/routes/api_routes.dart';
import '../lib/src/services/firebase_service.dart';

// 📖 SERVIDOR PRINCIPAL - API REST COMPLETA
final _logger = Logger('SenaiAPI');

void main() async {
  // 🔧 CARREGAR CONFIGURAÇÕES DE AMBIENTE
  final env = DotEnv();
  try {
    env.load();
    _logger.info('✅ Variáveis de ambiente carregadas');
  } catch (e) {
    _logger.warning('⚠️ Arquivo .env não encontrado, usando variáveis do sistema');
  }

  // 📋 CONFIGURAR LOGS
  final logLevel = _getLogLevel(env['LOG_LEVEL'] ?? 'INFO');
  Logger.root.level = logLevel;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info('🚀 Iniciando ${env['API_NAME'] ?? 'SENAI Monitoring API'}...');

  // 🔥 TESTAR CONEXÃO FIREBASE
  final firebaseService = FirebaseService();
  final connected = await firebaseService.testConnection();
  
  if (!connected) {
    _logger.severe('❌ Falha na conexão com Firebase! Abortando...');
    exit(1); // Encerrar processo com erro
  }
  
  _logger.info('✅ Firebase conectado com sucesso!');

  // 🗺️ CONFIGURAR ROTAS
  final apiRoutes = ApiRoutes();
  final router = apiRoutes.router;

  // 🌐 CONFIGURAÇÃO CORS SEGURA
  final corsOrigins = env['CORS_ORIGINS']?.split(',') ?? ['*'];
  
  // 📖 CONCEITO: Middleware Pipeline Completo
  final pipeline = Pipeline()
      .addMiddleware(logRequests())                    // 1️⃣ Log de todas requisições
      .addMiddleware(corsHeaders(headers: {            // 2️⃣ CORS configurado
        'Access-Control-Allow-Origin': corsOrigins.join(','),
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }))
      .addMiddleware(_errorHandler)                    // 3️⃣ Tratamento de erros global
      .addHandler(router.call);                       // 4️⃣ Processar rotas

  // 🌐 INICIAR SERVIDOR
  final port = int.parse(env['PORT'] ?? '8080');
  final host = env['HOST'] ?? 'localhost';
  
  final server = await shelf_io.serve(pipeline, host, port);
  
  _logger.info('🌐 Servidor rodando em http://$host:$port');
  _logger.info('🔧 Ambiente: ${env['NODE_ENV'] ?? 'development'}');
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
  print('🎯 ${env['API_NAME'] ?? 'SENAI Monitoring API'} v${env['API_VERSION'] ?? '1.0.0'}');
  print('📍 http://$host:$port');
  print('📖 Documentação: http://$host:$port');
  print('🧪 Health Check: http://$host:$port/health');
  print('👥 Funcionários: http://$host:$port/api/employees');
  print('💡 Pressione Ctrl+C para parar');
  print('');
  
  _logger.info('🎉 API iniciada com sucesso!');
}

// 🔧 Helper: Converter string para Level
Level _getLogLevel(String level) {
  switch (level.toUpperCase()) {
    case 'ALL': return Level.ALL;
    case 'FINEST': return Level.FINEST;
    case 'FINER': return Level.FINER;
    case 'FINE': return Level.FINE;
    case 'CONFIG': return Level.CONFIG;
    case 'INFO': return Level.INFO;
    case 'WARNING': return Level.WARNING;
    case 'SEVERE': return Level.SEVERE;
    case 'SHOUT': return Level.SHOUT;
    case 'OFF': return Level.OFF;
    default: return Level.INFO;
  }
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