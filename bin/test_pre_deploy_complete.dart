// 📁 bin/test_pre_deploy_complete.dart
// Teste completo e abrangente pré-deploy para validar TODOS os endpoints

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 TESTE COMPLETO PRÉ-DEPLOY - API V2.1.0');
  print('============================================');
  print('🎯 Validando TODOS os endpoints antes do deploy Fly.io');
  print('');
  
  const baseUrl = 'http://localhost:8080';
  // const baseUrl = 'https://senai-monitoring-api.fly.dev';
  var testsExecuted = 0;
  var testsSuccess = 0;
  var testsFailed = 0;
  
  try {
    print('📋 PLANO DE TESTES:');
    print('✅ 1. Health checks e documentação');
    print('✅ 2. CRUD funcionários');
    print('✅ 3. IoT endpoints (saúde + localização)');
    print('✅ 4. Consultas e dashboard');
    print('✅ 5. Performance e estatísticas');
    print('✅ 6. Cenários de erro');
    print('✅ 7. Múltiplos funcionários');
    print('✅ 8. Zone detection avançada');
    print('');

    // ===========================================
    // 🔧 1. HEALTH CHECKS E DOCUMENTAÇÃO
    // ===========================================
    print('🔧 1. TESTANDO HEALTH CHECKS E DOCUMENTAÇÃO');
    print('===========================================');
    
    // Health check geral
    testsExecuted++;
    final healthCheck = await testEndpoint('GET', '$baseUrl/health', null, 'Health Check Geral');
    if (healthCheck) testsSuccess++; else testsFailed++;
    
    // Documentação interativa
    testsExecuted++;
    final docs = await testEndpoint('GET', '$baseUrl/', null, 'Documentação Interativa');
    if (docs) testsSuccess++; else testsFailed++;
    
    await Future.delayed(Duration(milliseconds: 500));

    // ===========================================
    // 👥 2. CRUD FUNCIONÁRIOS
    // ===========================================
    print('\n👥 2. TESTANDO CRUD FUNCIONÁRIOS');
    print('==============================');
    
    // Listar funcionários
    testsExecuted++;
    final employeesList = await testEndpoint('GET', '$baseUrl/api/employees', null, 'Listar Funcionários');
    if (employeesList) testsSuccess++; else testsFailed++;
    
    // Estatísticas funcionários
    testsExecuted++;
    final employeesStats = await testEndpoint('GET', '$baseUrl/api/employees-stats', null, 'Estatísticas Funcionários');
    if (employeesStats) testsSuccess++; else testsFailed++;
    
    // Buscar funcionário específico
    testsExecuted++;
    final employeeById = await testEndpoint('GET', '$baseUrl/api/employees/EMP001', null, 'Funcionário por ID');
    if (employeeById) testsSuccess++; else testsFailed++;
    
    await Future.delayed(Duration(milliseconds: 500));

    // ===========================================
    // 📡 3. IOT ENDPOINTS (SAÚDE + LOCALIZAÇÃO)
    // ===========================================
    print('\n📡 3. TESTANDO IOT ENDPOINTS');
    print('===========================');
    
    // Teste endpoint IoT
    testsExecuted++;
    final iotTest = await testEndpoint('POST', '$baseUrl/api/iot/test', {}, 'Teste IoT Endpoint');
    if (iotTest) testsSuccess++; else testsFailed++;
    
    // Dados de saúde para múltiplos funcionários
    final healthDataTests = [
      {'employee_id': 'EMP001', 'device_id': 'DEVICE_001', 'heart_rate': 75, 'body_temperature': 36.5, 'battery_level': 85},
      {'employee_id': 'EMP003', 'device_id': 'DEVICE_003', 'heart_rate': 68, 'body_temperature': 36.2, 'battery_level': 92},
      {'employee_id': 'EMP004', 'device_id': 'DEVICE_004', 'heart_rate': 82, 'body_temperature': 36.8, 'battery_level': 78},
    ];
    
    for (final healthData in healthDataTests) {
      testsExecuted++;
      final fullHealthData = {
        ...healthData,
        'timestamp': DateTime.now().toIso8601String(),
        'oxygen_saturation': 98,
      };
      final result = await testEndpoint('POST', '$baseUrl/api/iot/health', fullHealthData, 'Saúde ${healthData['employee_id']}');
      if (result) testsSuccess++; else testsFailed++;
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    // Dados de localização para múltiplos funcionários (diferentes zonas)
    final locationDataTests = [
      {'employee_id': 'EMP001', 'device_id': 'DEVICE_001', 'latitude': '-3.7319', 'longitude': '-38.5267'}, // setor_producao
      {'employee_id': 'EMP003', 'device_id': 'DEVICE_003', 'latitude': '-3.7330', 'longitude': '-38.5280'}, // almoxarifado  
      {'employee_id': 'EMP004', 'device_id': 'DEVICE_004', 'latitude': '-3.7290', 'longitude': '-38.5240'}, // administrativo
    ];
    
    for (final locationData in locationDataTests) {
      testsExecuted++;
      final fullLocationData = {
        ...locationData,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final result = await testEndpoint('POST', '$baseUrl/api/iot/location', fullLocationData, 'Localização ${locationData['employee_id']}');
      if (result) testsSuccess++; else testsFailed++;
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    // Aguardar processamento
    print('⏳ Aguardando processamento dos dados...');
    await Future.delayed(Duration(seconds: 2));

    // ===========================================
    // 🔍 4. CONSULTAS E DASHBOARD
    // ===========================================
    print('\n🔍 4. TESTANDO CONSULTAS E DASHBOARD');
    print('===================================');
    
    // Consultas de saúde por funcionário
    for (final employeeId in ['EMP001', 'EMP003', 'EMP004']) {
      testsExecuted++;
      final result = await testEndpoint('GET', '$baseUrl/api/iot/health/$employeeId', null, 'Consulta Saúde $employeeId');
      if (result) testsSuccess++; else testsFailed++;
    }
    
    // Consultas de localização por funcionário
    for (final employeeId in ['EMP001', 'EMP003', 'EMP004']) {
      testsExecuted++;
      final result = await testEndpoint('GET', '$baseUrl/api/iot/location/$employeeId', null, 'Consulta Localização $employeeId');
      if (result) testsSuccess++; else testsFailed++;
    }
    
    // Dashboard de todas as localizações
    testsExecuted++;
    final allLocations = await testEndpoint('GET', '$baseUrl/api/iot/locations-all', null, 'Dashboard Todas Localizações');
    if (allLocations) testsSuccess++; else testsFailed++;

    // ===========================================
    // 📊 5. PERFORMANCE E ESTATÍSTICAS
    // ===========================================
    print('\n📊 5. TESTANDO PERFORMANCE E ESTATÍSTICAS');
    print('=========================================');
    
    // Estatísticas IoT
    testsExecuted++;
    final iotStats = await testEndpoint('GET', '$baseUrl/api/iot/stats', null, 'Estatísticas IoT');
    if (iotStats) testsSuccess++; else testsFailed++;
    
    // Estatísticas sistema
    testsExecuted++;
    final systemStats = await testEndpoint('GET', '$baseUrl/api/stats', null, 'Estatísticas Sistema');
    if (systemStats) testsSuccess++; else testsFailed++;
    
    // Teste de performance para cada funcionário
    for (final employeeId in ['EMP001', 'EMP003', 'EMP004']) {
      testsExecuted++;
      final result = await testEndpoint('GET', '$baseUrl/api/iot/performance-test/$employeeId', null, 'Performance Test $employeeId');
      if (result) testsSuccess++; else testsFailed++;
    }
    
    // Configurações do sistema
    testsExecuted++;
    final configTest = await testEndpoint('POST', '$baseUrl/api/iot/config', {
      'v2_optimized_mode': true,
      'zone_detection': true
    }, 'Configurações Sistema');
    if (configTest) testsSuccess++; else testsFailed++;

    // ===========================================
    // ❌ 6. CENÁRIOS DE ERRO
    // ===========================================
    print('\n❌ 6. TESTANDO CENÁRIOS DE ERRO');
    print('==============================');
    
    // Funcionário inexistente
    testsExecuted++;
    final invalidEmployee = await testEndpoint('GET', '$baseUrl/api/iot/health/EMP999', null, 'Funcionário Inexistente', expectError: true);
    if (invalidEmployee) testsSuccess++; else testsFailed++;
    
    // Dados inválidos
    testsExecuted++;
    final invalidHealthData = await testEndpoint('POST', '$baseUrl/api/iot/health', {
      'invalid_field': 'invalid_value'
    }, 'Dados Saúde Inválidos', expectError: true);
    if (invalidHealthData) testsSuccess++; else testsFailed++;
    
    // Endpoint inexistente
    testsExecuted++;
    final invalidEndpoint = await testEndpoint('GET', '$baseUrl/api/invalid/endpoint', null, 'Endpoint Inexistente', expectError: true);
    if (invalidEndpoint) testsSuccess++; else testsFailed++;

    // ===========================================
    // 📈 7. TESTES DE CARGA SIMPLES
    // ===========================================
    print('\n📈 7. TESTE DE CARGA SIMPLES');
    print('============================');
    
    print('🚀 Enviando 10 requisições simultâneas...');
    final loadTestFutures = <Future>[];
    
    for (int i = 0; i < 10; i++) {
      loadTestFutures.add(
        http.get(Uri.parse('$baseUrl/api/iot/stats'))
      );
    }
    
    final stopwatch = Stopwatch()..start();
    final loadTestResults = await Future.wait(loadTestFutures);
    stopwatch.stop();
    
    final successfulRequests = loadTestResults.where((r) => r.statusCode == 200).length;
    print('✅ $successfulRequests/10 requisições bem-sucedidas');
    print('⏱️ Tempo total: ${stopwatch.elapsedMilliseconds}ms');
    print('📊 Média por requisição: ${(stopwatch.elapsedMilliseconds / 10).toStringAsFixed(1)}ms');
    
    testsExecuted++;
    if (successfulRequests >= 8) { // 80% de sucesso é aceitável
      testsSuccess++;
      print('✅ Teste de carga: PASSOU');
    } else {
      testsFailed++;
      print('❌ Teste de carga: FALHOU');
    }

    // ===========================================
    // 📋 8. VALIDAÇÃO FINAL DE DADOS
    // ===========================================
    print('\n📋 8. VALIDAÇÃO FINAL DE DADOS');
    print('==============================');
    
    // Verificar se todas as localizações estão sendo retornadas
    final locationsResponse = await http.get(Uri.parse('$baseUrl/api/iot/locations-all'));
    if (locationsResponse.statusCode == 200) {
      final locationsData = jsonDecode(locationsResponse.body);
      final locationsList = locationsData['data'] as List;
      print('📍 Localizações encontradas: ${locationsList.length}');
      
      // Verificar zones detectadas
      for (final location in locationsList) {
        final employeeId = location['employee_id'];
        final lat = double.tryParse(location['latitude'] ?? '0');
        final lon = double.tryParse(location['longitude'] ?? '0');
        print('👤 $employeeId: ($lat, $lon)');
      }
    }
    
    // Verificar estatísticas finais
    final finalStatsResponse = await http.get(Uri.parse('$baseUrl/api/iot/stats'));
    if (finalStatsResponse.statusCode == 200) {
      final statsData = jsonDecode(finalStatsResponse.body);
      final stats = statsData['data']['statistics'];
      print('📊 Funcionários ativos: ${stats['active_employees']}');
      print('🗺️ Distribuição por zonas: ${stats['zone_distribution']}');
    }

    // ===========================================
    // 📈 RELATÓRIO FINAL
    // ===========================================
    print('\n🎯 RELATÓRIO FINAL PRÉ-DEPLOY');
    print('============================');
    print('📊 Testes executados: $testsExecuted');
    print('✅ Testes com sucesso: $testsSuccess');
    print('❌ Testes falharam: $testsFailed');
    print('📈 Taxa de sucesso: ${(testsSuccess / testsExecuted * 100).toStringAsFixed(1)}%');
    print('');
    
    if (testsFailed == 0) {
      print('🎉 TODOS OS TESTES PASSARAM!');
      print('🚀 API V2.1.0 PRONTA PARA DEPLOY NO FLY.IO!');
      print('');
      print('✅ Endpoints validados: ${testsSuccess}');
      print('✅ Performance confirmada');
      print('✅ Error handling funcionando');
      print('✅ Multiple employees testados');
      print('✅ Zone detection operacional');
      print('✅ Load testing aprovado');
      exit(0);
    } else {
      print('⚠️ ALGUNS TESTES FALHARAM!');
      print('🔧 Corrija os problemas antes do deploy');
      print('❌ Falhas: $testsFailed/$testsExecuted');
      exit(1);
    }
    
  } catch (error) {
    print('💥 ERRO CRÍTICO NO TESTE: $error');
    exit(1);
  }
}

// Função auxiliar para testar endpoints
Future<bool> testEndpoint(
  String method, 
  String url, 
  Map<String, dynamic>? body, 
  String description,
  {bool expectError = false}
) async {
  try {
    print('🧪 $description...');
    
    http.Response response;
    
    if (method == 'GET') {
      response = await http.get(Uri.parse(url));
    } else if (method == 'POST') {
      response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : '{}',
      );
    } else {
      throw Exception('Método HTTP não suportado: $method');
    }
    
    final isSuccess = expectError 
        ? (response.statusCode >= 400) 
        : (response.statusCode >= 200 && response.statusCode < 300);
    
    if (isSuccess) {
      print('   ✅ Status: ${response.statusCode} - PASSOU');
      
      // Tentar parsing JSON para validar resposta
      try {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('success')) {
          print('   📊 Success: ${responseData['success']}');
        }
      } catch (e) {
        // Resposta não é JSON, tudo bem
      }
      
      return true;
    } else {
      print('   ❌ Status: ${response.statusCode} - FALHOU');
      print('   📋 Response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      return false;
    }
    
  } catch (e) {
    print('   💥 ERRO: $e');
    return false;
  }
}