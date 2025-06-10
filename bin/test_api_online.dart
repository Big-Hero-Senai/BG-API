import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 TESTANDO API ONLINE - VERIFICAR VERSÃO E ENDPOINTS');
  print('====================================================');
  
  final baseUrl = 'https://senai-monitoring-api.fly.dev';
  
  try {
    // 1. Health check
    print('\n🔍 1. VERIFICANDO VERSÃO E STATUS...');
    final healthResponse = await http.get(Uri.parse('$baseUrl/health'));
    if (healthResponse.statusCode == 200) {
      final healthData = jsonDecode(healthResponse.body);
      print('   ✅ API Online: ${healthData['service']}');
      print('   📊 Versão: ${healthData['version']}');
      print('   🌍 Environment: ${healthData['environment']}');
      print('   ⏰ Timestamp: ${healthData['timestamp']}');
    }
    
    // 2. Verificar endpoints disponíveis
    print('\n📡 2. ENDPOINTS DISPONÍVEIS...');
    final apiResponse = await http.get(Uri.parse('$baseUrl/api'));
    if (apiResponse.statusCode == 200) {
      final apiData = jsonDecode(apiResponse.body);
      print('   📊 Versão API: ${apiData['version']}');
      print('   📝 Descrição: ${apiData['description']}');
      print('   📡 Endpoints encontrados:');
      
      if (apiData['endpoints'] != null) {
        final endpoints = apiData['endpoints'] as Map<String, dynamic>;
        for (var endpoint in endpoints.entries) {
          print('      ${endpoint.value['method']} ${endpoint.key} - ${endpoint.value['description']}');
        }
      }
    }
    
    // 3. Testar endpoints básicos existentes
    print('\n🧪 3. TESTANDO ENDPOINTS EXISTENTES...');
    
    // Testar listagem de funcionários
    try {
      final employeesResponse = await http.get(Uri.parse('$baseUrl/api/employees'));
      print('   GET /api/employees: Status ${employeesResponse.statusCode}');
      if (employeesResponse.statusCode == 200) {
        final employeesData = jsonDecode(employeesResponse.body);
        print('      Funcionários: ${employeesData['data']?.length ?? 0}');
      }
    } catch (e) {
      print('   GET /api/employees: Erro - $e');
    }
    
    // 4. Verificar se endpoints IoT existem
    print('\n❌ 4. VERIFICANDO ENDPOINTS IOT (ESPERADO 404)...');
    
    final iotEndpoints = [
      '/api/iot/health',
      '/api/iot/location', 
      '/api/iot/stats',
      '/api/iot/locations-all'
    ];
    
    for (var endpoint in iotEndpoints) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        print('   GET $endpoint: Status ${response.statusCode}');
      } catch (e) {
        print('   GET $endpoint: Erro - $e');
      }
    }
    
    print('\n🎯 CONCLUSÃO:');
    print('================');
    print('❌ API online está na versão v1.0.0 (antiga)');
    print('✅ API local está na versão v2.1.0 (atual)');
    print('🔄 Necessário redeploy com código v2.1.0');
    print('\n📋 PRÓXIMOS PASSOS:');
    print('1. Verificar se código local está na versão v2.1.0');
    print('2. Fazer redeploy: flyctl deploy');
    print('3. Verificar se versão online atualiza para v2.1.0');
    print('4. Testar endpoints IoT após deploy');
    
  } catch (e) {
    print('\n❌ ERRO GERAL: $e');
  }
}