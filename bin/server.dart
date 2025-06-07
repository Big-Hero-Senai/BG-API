import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logging/logging.dart';

// 📖 CONCEITO: Logger para debug
final _logger = Logger('SenaiAPI');

void main() async {
  // 📖 CONCEITO: Configurar logs para ver o que está acontecendo
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info('🚀 Iniciando API do SENAI...');

  // 📖 CONCEITO: Router - mapeamento de URLs
  final router = Router();

  // 🎯 ROTA BÁSICA: Verificar se API está funcionando
  router.get('/health', (Request request) {
    _logger.info('✅ Health check solicitado');
    return Response.ok(
      '{"status": "healthy", "service": "SENAI Monitoring API", "timestamp": "${DateTime.now().toIso8601String()}"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  // 🎯 ROTA: Página inicial amigável
  router.get('/', (Request request) {
    return Response.ok('''
<!DOCTYPE html>
<html>
<head>
    <title>SENAI Monitoring API</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        .status { color: #28a745; font-weight: bold; }
        .endpoint { background: #f8f9fa; padding: 10px; margin: 10px 0; border-left: 4px solid #007bff; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏭 SENAI Monitoring API</h1>
        <p class="status">✅ API Online e Funcionando!</p>
        
        <h3>📋 Endpoints Disponíveis:</h3>
        <div class="endpoint"><strong>GET /health</strong> - Status da API</div>
        <div class="endpoint"><strong>GET /api/employees</strong> - Listar funcionários (em breve)</div>
        
        <p><small>Desenvolvido para monitoramento de funcionários com pulseiras IoT</small></p>
    </div>
</body>
</html>
    ''', headers: {'Content-Type': 'text/html'});
  });

  // 📖 CONCEITO: Middleware Pipeline
  // Como uma linha de produção: cada middleware processa a requisição
  final pipeline = Pipeline()
      .addMiddleware(logRequests())     // 1️⃣ Primeiro: logar todas as requisições
      .addMiddleware(corsHeaders())     // 2️⃣ Segundo: adicionar headers CORS
      .addHandler(router.call);         // 3️⃣ Último: processar a rota

  // 📖 CONCEITO: Porta do servidor
  const port = 8080; // Padrão para desenvolvimento
  
  // 🚀 INICIAR SERVIDOR
  final server = await shelf_io.serve(pipeline, 'localhost', port);
  
  _logger.info('🌐 Servidor rodando em http://localhost:$port');
  _logger.info('🔍 Teste: http://localhost:$port/health');
  
  print(''); // Linha em branco para clareza
  print('🎯 SENAI Monitoring API');
  print('📍 http://localhost:$port');
  print('💡 Pressione Ctrl+C para parar');
}

// 📖 CONCEITO: CORS Middleware
// Middleware que adiciona headers CORS em todas as respostas
Middleware corsHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      // ✨ CONCEITO: Interceptar requisição OPTIONS (preflight)
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      
      // ✨ CONCEITO: Processar requisição normal e adicionar headers CORS
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

// 📖 CONCEITO: Headers CORS explicados
const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',           // 🌍 Qualquer origem pode acessar
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS', // 📋 Métodos permitidos
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',      // 📄 Headers permitidos
};