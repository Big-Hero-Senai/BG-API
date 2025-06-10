import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../services/template_service.dart';

// 📄 CONTROLLER: Documentação da API
class DocumentationController {
  static final _logger = Logger('DocumentationController');

  // Configurações da API
  static const String _apiName = 'SENAI Monitoring API';
  static const String _version = '2.1.0';
  static const String _description =
      'Sistema de Monitoramento de Funcionários com Pulseiras IoT';

  // 🏠 GET / - Documentação HTML interativa
  static Future<Response> getDocumentation(Request request) async {
    try {
      _logger.info('📄 GET / - Servindo documentação HTML');

      // Obter URL base da requisição
      final baseUrl = _getBaseUrl(request);

      // Renderizar documentação usando templates
      final html = await TemplateService.renderDocumentation(
        apiName: _apiName,
        version: _version,
        description: _description,
        baseUrl: baseUrl,
      );

      _logger.info('✅ Documentação HTML renderizada com sucesso');

      return Response.ok(
        html,
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'Cache-Control': 'public, max-age=300', // Cache por 5 minutos
        },
      );
    } catch (e) {
      _logger.severe('❌ Erro ao servir documentação: $e');

      // Fallback simples se falhar
      return Response.ok(
        _getFallbackHtml(),
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    }
  }

  // 📊 GET /api - Informações da API em JSON
  static Response getApiInfo(Request request) {
    try {
      _logger.info('📊 GET /api - Servindo informações da API');

      final apiInfo = TemplateService.getApiInfo(
        apiName: _apiName,
        version: _version,
        description: _description,
      );

      return Response.ok(
        jsonEncode(apiInfo),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
    } catch (e) {
      _logger.severe('❌ Erro ao servir info da API: $e');

      // Fallback básico
      final fallback = {
        'api': _apiName,
        'version': _version,
        'error': 'Erro ao carregar informações completas',
        'timestamp': DateTime.now().toIso8601String(),
      };

      return Response.ok(
        jsonEncode(fallback),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // 🏥 GET /health - Health check
  static Response healthCheck(Request request) {
    _logger.info('🏥 GET /health - Health check solicitado');

    final health = {
      'status': 'healthy',
      'service': _apiName,
      'version': _version,
      'timestamp': DateTime.now().toIso8601String(),
      'uptime': 'Running',
      'database': 'Firebase Firestore',
      'environment': 'development', // Pode vir de variável de ambiente
    };

    return Response.ok(
      jsonEncode(health),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // 🔧 Helper: Extrair URL base da requisição
  static String _getBaseUrl(Request request) {
    final uri = request.requestedUri;
    final scheme = uri.scheme;
    final host = uri.host;
    final port = uri.port;

    // Se for porta padrão, não incluir na URL
    if ((scheme == 'http' && port == 80) ||
        (scheme == 'https' && port == 443)) {
      return '$scheme://$host';
    } else {
      return '$scheme://$host:$port';
    }
  }

  // 🚨 Fallback HTML se templates falharem
  static String _getFallbackHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>$_apiName</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        .status { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏭 $_apiName</h1>
        <p class="status">✅ API Online e Funcionando!</p>
        <p>$_description</p>
        <p>Versão: $_version</p>
        
        <h3>📋 Endpoints:</h3>
        <ul>
            <li><strong>GET /api/employees</strong> - Listar funcionários</li>
            <li><strong>POST /api/employees</strong> - Criar funcionário</li>
            <li><strong>GET /health</strong> - Status da API</li>
        </ul>
        
        <p><small>Sistema de templates temporariamente indisponível</small></p>
    </div>
</body>
</html>
    ''';
  }
}