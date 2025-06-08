import 'dart:io';
import 'package:logging/logging.dart';

// 📄 SERVICE: Gerenciamento de templates HTML
class TemplateService {
  static final _logger = Logger('TemplateService');
  static final Map<String, String> _templateCache = {};
  
  // 📖 CONCEITO: Endpoint para documentação
  static const Map<String, EndpointInfo> _endpoints = {
    'GET /api/employees': EndpointInfo('GET', '/api/employees', 'Lista todos os funcionários'),
    'GET /api/employees/:id': EndpointInfo('GET', '/api/employees/:id', 'Busca funcionário específico'),
    'POST /api/employees': EndpointInfo('POST', '/api/employees', 'Cria novo funcionário'),
    'PUT /api/employees/:id': EndpointInfo('PUT', '/api/employees/:id', 'Atualiza funcionário'),
    'DELETE /api/employees/:id': EndpointInfo('DELETE', '/api/employees/:id', 'Remove funcionário'),
    'GET /health': EndpointInfo('GET', '/health', 'Status da API'),
    'GET /api': EndpointInfo('GET', '/api', 'Informações da API'),
    'GET /': EndpointInfo('GET', '/', 'Documentação interativa'),
  };
  
  // 📄 Carregar template do arquivo
  static Future<String> _loadTemplate(String templatePath) async {
    // Cache do template
    if (_templateCache.containsKey(templatePath)) {
      return _templateCache[templatePath]!;
    }
    
    try {
      final file = File(templatePath);
      if (!await file.exists()) {
        _logger.severe('❌ Template não encontrado: $templatePath');
        throw FileSystemException('Template não encontrado', templatePath);
      }
      
      final content = await file.readAsString();
      _templateCache[templatePath] = content;
      
      _logger.info('✅ Template carregado: $templatePath');
      return content;
    } catch (e) {
      _logger.severe('❌ Erro ao carregar template $templatePath: $e');
      rethrow;
    }
  }
  
  // 🧩 Renderizar componente de endpoint
  static Future<String> _renderEndpoint(EndpointInfo endpoint) async {
    try {
      final template = await _loadTemplate('templates/components/endpoint.html');
      
      return template
          .replaceAll('{{METHOD}}', endpoint.method)
          .replaceAll('{{METHOD_CLASS}}', endpoint.method.toLowerCase())
          .replaceAll('{{URL}}', endpoint.url)
          .replaceAll('{{DESCRIPTION}}', endpoint.description);
    } catch (e) {
      _logger.warning('⚠️ Erro ao renderizar endpoint, usando fallback: $e');
      // Fallback simples se template falhar
      return '<div class="endpoint">${endpoint.method} ${endpoint.url} - ${endpoint.description}</div>';
    }
  }
  
  // 📋 Gerar HTML de endpoints por categoria
  static Future<String> _generateEndpointsHtml(List<String> endpointKeys) async {
    final buffer = StringBuffer();
    
    for (final key in endpointKeys) {
      if (_endpoints.containsKey(key)) {
        final endpointHtml = await _renderEndpoint(_endpoints[key]!);
        buffer.writeln(endpointHtml);
      }
    }
    
    return buffer.toString();
  }
  
  // 🎨 Renderizar documentação completa
  static Future<String> renderDocumentation({
    required String apiName,
    required String version,
    required String description,
    required String baseUrl,
  }) async {
    try {
      _logger.info('🎨 Renderizando documentação da API');
      
      // Carregar template principal
      final template = await _loadTemplate('templates/documentation.html');
      
      // Gerar endpoints por categoria
      final employeeEndpoints = await _generateEndpointsHtml([
        'GET /api/employees',
        'GET /api/employees/:id',
        'POST /api/employees',
        'PUT /api/employees/:id',
        'DELETE /api/employees/:id',
      ]);
      
      final systemEndpoints = await _generateEndpointsHtml([
        'GET /health',
        'GET /api',
        'GET /',
      ]);
      
      // Exemplo de funcionário (JSON formatado)
      final employeeExample = _getEmployeeExample();
      
      // Substituir variáveis
      final rendered = template
          .replaceAll('{{API_NAME}}', apiName)
          .replaceAll('{{VERSION}}', version)
          .replaceAll('{{DESCRIPTION}}', description)
          .replaceAll('{{BASE_URL}}', baseUrl)
          .replaceAll('{{ENDPOINT_COUNT}}', _endpoints.length.toString())
          .replaceAll('{{UPTIME}}', _calculateUptime())
          .replaceAll('{{YEAR}}', DateTime.now().year.toString())
          .replaceAll('{{TIMESTAMP}}', DateTime.now().toIso8601String())
          .replaceAll('{{EMPLOYEE_ENDPOINTS}}', employeeEndpoints)
          .replaceAll('{{SYSTEM_ENDPOINTS}}', systemEndpoints)
          .replaceAll('{{EMPLOYEE_EXAMPLE}}', employeeExample);
      
      _logger.info('✅ Documentação renderizada com sucesso');
      return rendered;
    } catch (e) {
      _logger.severe('❌ Erro ao renderizar documentação: $e');
      return _getFallbackDocumentation(apiName, version, baseUrl);
    }
  }
  
  // 📊 Template simples para informações da API (JSON)
  static Map<String, dynamic> getApiInfo({
    required String apiName,
    required String version,
    required String description,
  }) {
    return {
      'api': apiName,
      'version': version,
      'description': description,
      'endpoints': _endpoints.map((key, endpoint) => MapEntry(
        endpoint.url,
        {
          'method': endpoint.method,
          'description': endpoint.description,
        },
      )),
      'example_employee': _getEmployeeExampleObject(),
      'timestamp': DateTime.now().toIso8601String(),
      'uptime': _calculateUptime(),
    };
  }
  
  // 📋 Exemplo de funcionário para documentação
  static String _getEmployeeExample() {
    const example = '''
{
  "id": "EMP001",
  "nome": "João Silva",
  "email": "joao@senai.com",
  "setor": "producao",
  "data_admissao": "2023-01-15T00:00:00.000Z",
  "ativo": true
}''';
    return example;
  }
  
  static Map<String, dynamic> _getEmployeeExampleObject() {
    return {
      'id': 'EMP001',
      'nome': 'João Silva',
      'email': 'joao@senai.com',
      'setor': 'producao',
      'data_admissao': '2023-01-15T00:00:00.000Z',
      'ativo': true,
    };
  }
  
  // ⏰ Calcular uptime simples
  static String _calculateUptime() {
    // Placeholder - pode ser melhorado com timestamp de início real
    return "99.9%";
  }
  
  // 🚨 Fallback se templates falharem
  static String _getFallbackDocumentation(String apiName, String version, String baseUrl) {
    return '''
<!DOCTYPE html>
<html>
<head><title>$apiName</title></head>
<body>
    <h1>$apiName v$version</h1>
    <p>API de monitoramento funcionando!</p>
    <p>Endpoints disponíveis em: $baseUrl/api</p>
</body>
</html>
    ''';
  }
  
  // 🧹 Limpar cache (útil em desenvolvimento)
  static void clearCache() {
    _templateCache.clear();
    _logger.info('🧹 Cache de templates limpo');
  }
}

// 📋 CLASSE: Informações de endpoint
class EndpointInfo {
  final String method;
  final String url;
  final String description;
  
  const EndpointInfo(this.method, this.url, this.description);
}

/*
🎓 CONCEITOS IMPLEMENTADOS:

1. 📄 **Template Loading**
   - Carregamento de arquivos HTML
   - Cache para performance
   - Error handling com fallbacks

2. 🔄 **Variable Substitution**
   - Substituição de {{variáveis}}
   - Dados dinâmicos na renderização
   - Componentes reutilizáveis

3. 🧩 **Component System**
   - Templates modulares
   - Reutilização de código
   - Fácil manutenção

4. 🎯 **Separation of Concerns**
   - HTML separado da lógica
   - Dados vs apresentação
   - Controller só coordena

5. 🚨 **Resilience**
   - Fallbacks se templates falharem
   - Logs estruturados
   - Cache para performance
*/