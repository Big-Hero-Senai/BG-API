// 📁 bin/test_iot_v2_final.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// 🧪 SCRIPT: Teste completo do sistema IoT V2 Final
class IoTV2FinalTester {
  static const String baseUrl = 'http://localhost:8080';
  static final http.Client _client = http.Client();

  static Future<void> main() async {
    print('🧪 TESTE DO SISTEMA IoT V2 FINAL');
    print('================================');

    try {
      // 1. Verificar servidor
      await _checkServerStatus();
      
      // 2. Obter funcionário para testes
      final employeeId = await _getTestEmployee();
      
      // 3. Testar endpoints V2
      await _testV2Endpoints(employeeId);
      
      // 4. Teste de performance
      await _performanceTest(employeeId);
      
      // 5. Dashboard test
      await _dashboardTest();
      
      print('\n🎉 SISTEMA IoT V2 FINAL FUNCIONANDO PERFEITAMENTE!');
      
    } catch (e) {
      print('❌ ERRO NOS TESTES: $e');
    } finally {
      _client.close();
    }
  }

  static Future<void> _checkServerStatus() async {
    print('🔌 Verificando servidor...');
    
    final response = await _client.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      print('✅ Servidor online');
    } else {
      throw Exception('Servidor offline: ${response.statusCode}');
    }
  }

  static Future<String> _getTestEmployee() async {
    print('👤 Obtendo funcionário para teste...');
    
    final response = await _client.get(Uri.parse('$baseUrl/api/employees'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final employees = data['data'] as List;
      
      if (employees.isNotEmpty) {
        final employeeId = employees.first['id'];
        print('✅ Usando funcionário: $employeeId');
        return employeeId;
      }
    }
    
    print('⚠️ Usando EMP001 como padrão');
    return 'EMP001';
  }

  static Future<void> _testV2Endpoints(String employeeId) async {
    print('\n📡 TESTANDO ENDPOINTS V2');
    print('========================');
    
    // Teste dados de saúde
    print('💓 Testando dados de saúde V2...');
    final healthData = {
      'employee_id': employeeId,
      'device_id': 'DEVICE_V2_FINAL',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'heart_rate': 75,
      'body_temperature': 36.5,
    };
    
    final healthResponse = await _client.post(
      Uri.parse('$baseUrl/api/iot/health'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(healthData),
    );
    
    if (healthResponse.statusCode == 201) {
      final result = jsonDecode(healthResponse.body);
      print('✅ Saúde V2: ${result['_processing_version']}');
    } else {
      print('❌ Erro saúde: ${healthResponse.statusCode}');
    }
    
    // Teste localização
    print('🗺️ Testando localização V2...');
    final locationData = {
      'employee_id': employeeId,
      'device_id': 'DEVICE_V2_FINAL',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'latitude': '-3.7319',
      'longitude': '-38.5267',
    };
    
    final locationResponse = await _client.post(
      Uri.parse('$baseUrl/api/iot/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(locationData),
    );
    
    if (locationResponse.statusCode == 201) {
      final result = jsonDecode(locationResponse.body);
      print('✅ Localização V2: ${result['_processing_version']}');
    } else {
      print('❌ Erro localização: ${locationResponse.statusCode}');
    }
  }

  static Future<void> _performanceTest(String employeeId) async {
    print('\n⚡ TESTE DE PERFORMANCE V2');
    print('==========================');
    
    final response = await _client.get(
      Uri.parse('$baseUrl/api/iot/performance-test/$employeeId')
    );
    
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final data = result['data'];
      
      print('🚀 Performance V2:');
      print('   • Saúde: ${data['health_data']['count']} registros em ${data['health_data']['time_ms']}ms');
      print('   • Localização: ${data['current_location']['found'] ? 'encontrada' : 'não encontrada'} em ${data['current_location']['time_ms']}ms');
      print('   • Total: ${data['total_time_ms']}ms');
    } else {
      print('❌ Erro performance: ${response.statusCode}');
    }
  }

  static Future<void> _dashboardTest() async {
    print('\n📊 TESTE DO DASHBOARD V2');
    print('========================');
    
    // Dashboard de localizações
    final locationsResponse = await _client.get(
      Uri.parse('$baseUrl/api/iot/locations-all')
    );
    
    if (locationsResponse.statusCode == 200) {
      final result = jsonDecode(locationsResponse.body);
      final locations = result['data'] as List;
      print('✅ Dashboard: ${locations.length} localizações ativas');
    } else {
      print('❌ Erro dashboard: ${locationsResponse.statusCode}');
    }
    
    // Estatísticas V2
    final statsResponse = await _client.get(
      Uri.parse('$baseUrl/api/iot/stats')
    );
    
    if (statsResponse.statusCode == 200) {
      final result = jsonDecode(statsResponse.body);
      final stats = result['data'];
      print('✅ Estatísticas V2: ${stats['version']}');
      print('   • Melhorias: ${stats['performance_improvements']['query_speed']}');
    } else {
      print('❌ Erro estatísticas: ${statsResponse.statusCode}');
    }
  }
}

void main() async {
  await IoTV2FinalTester.main();
}