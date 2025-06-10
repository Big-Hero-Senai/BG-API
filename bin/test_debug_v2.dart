// 📁 bin/test_debug_v2.dart
// Teste específico para diagnosticar problema das collections V2

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 DIAGNÓSTICO ESPECÍFICO - API V2.0');
  print('====================================');
  
  const baseUrl = 'http://localhost:8080';
  
  try {
    // 1. Verificar se servidor está rodando
    print('\n1️⃣ VERIFICANDO SERVIDOR...');
    final healthCheck = await http.get(Uri.parse('$baseUrl/health'));
    if (healthCheck.statusCode == 200) {
      print('✅ Servidor online');
    } else {
      print('❌ Servidor offline');
      return;
    }
    
    // 2. Testar endpoint de saúde V2
    print('\n2️⃣ TESTANDO ENDPOINT DE SAÚDE V2...');
    final healthData = {
      'employee_id': 'EMP001',
      'device_id': 'DEVICE_001',
      'timestamp': DateTime.now().toIso8601String(),
      'heart_rate': 75,
      'body_temperature': 36.5,
      'blood_oxygen': 98,
      'battery_level': 85
    };
    
    final healthResponse = await http.post(
      Uri.parse('$baseUrl/api/iot/health'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(healthData),
    );
    
    print('📤 Enviando dados de saúde...');
    print('📊 Status: ${healthResponse.statusCode}');
    print('📋 Response: ${healthResponse.body}');
    
    if (healthResponse.statusCode == 200) {
      final responseData = jsonDecode(healthResponse.body);
      print('✅ Saúde processada');
      print('🔧 Versão: ${responseData['_processing_version'] ?? 'N/A'}');
    } else {
      print('❌ Erro ao processar saúde');
    }
    
    // 3. Testar endpoint de localização V2
    print('\n3️⃣ TESTANDO ENDPOINT DE LOCALIZAÇÃO V2...');
    final locationData = {
      'employee_id': 'EMP001',
      'device_id': 'DEVICE_001', 
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': '-3.7319',
      'longitude': '-38.5267'
    };
    
    final locationResponse = await http.post(
      Uri.parse('$baseUrl/api/iot/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(locationData),
    );
    
    print('📤 Enviando dados de localização...');
    print('📊 Status: ${locationResponse.statusCode}');
    print('📋 Response: ${locationResponse.body}');
    
    if (locationResponse.statusCode == 200) {
      final responseData = jsonDecode(locationResponse.body);
      print('✅ Localização processada');
      print('🔧 Versão: ${responseData['_processing_version'] ?? 'N/A'}');
    } else {
      print('❌ Erro ao processar localização');
    }
    
    // 4. Verificar collections criadas
    print('\n4️⃣ AGUARDANDO PROCESSAMENTO...');
    await Future.delayed(Duration(seconds: 2));
    
    // 5. Testar consultas V2
    print('\n5️⃣ TESTANDO CONSULTAS V2...');
    
    // Teste health data V2
    final healthQuery = await http.get(
      Uri.parse('$baseUrl/api/iot/health/EMP001'),
    );
    print('🔍 Consulta saúde EMP001:');
    print('📊 Status: ${healthQuery.statusCode}');
    print('📋 Response: ${healthQuery.body}');
    
    // Teste location atual
    final locationQuery = await http.get(
      Uri.parse('$baseUrl/api/iot/location/EMP001'),
    );
    print('\n🔍 Consulta localização EMP001:');
    print('📊 Status: ${locationQuery.statusCode}');
    print('📋 Response: ${locationQuery.body}');
    
    // 6. Testar estatísticas V2
    print('\n6️⃣ TESTANDO ESTATÍSTICAS V2...');
    final statsResponse = await http.get(
      Uri.parse('$baseUrl/api/iot/stats'),
    );
    print('📊 Stats Status: ${statsResponse.statusCode}');
    print('📋 Stats Response: ${statsResponse.body}');
    
    print('\n🎯 DIAGNÓSTICO COMPLETO!');
    print('👀 Verifique o Firebase Console para ver quais collections foram criadas');
    
  } catch (error) {
    print('❌ ERRO NO TESTE: $error');
  }
}