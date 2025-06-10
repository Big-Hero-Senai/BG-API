import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🗃️ POPULAÇÃO FINAL - PROBLEMA TIMESTAMP RESOLVIDO');
  print('=================================================');
  
  final baseUrl = 'http://localhost:8080';
  var successCount = 0;
  var totalOperations = 0;
  
  try {
    // Gerar timestamp atual em formato correto
    final now = DateTime.now().toUtc().toIso8601String();
    print('📅 Timestamp ISO: $now');
    
    // 1. Verificar servidor
    print('\n🔍 1. VERIFICANDO SERVIDOR...');
    final healthCheck = await http.get(Uri.parse('$baseUrl/health'));
    if (healthCheck.statusCode == 200) {
      print('   ✅ Servidor online');
    } else {
      print('   ❌ Servidor offline');
      return;
    }
    
    // 2. Dados de saúde COM TODOS OS CAMPOS OBRIGATÓRIOS
    print('\n💓 2. ADICIONANDO DADOS DE SAÚDE...');
    final healthData = [
      {
        'employee_id': 'EMP001',
        'device_id': 'DEVICE_001',
        'timestamp': now,  // ✅ CAMPO OBRIGATÓRIO
        'heart_rate': 75,
        'body_temperature': 36.5,  // ✅ NOME CORRETO DO CAMPO
        'battery_level': 85,  // ✅ NOME CORRETO DO CAMPO
      },
      {
        'employee_id': 'EMP002', 
        'device_id': 'DEVICE_002',
        'timestamp': now,
        'heart_rate': 72,
        'body_temperature': 36.3,
        'battery_level': 92,
      },
      {
        'employee_id': 'EMP003',
        'device_id': 'DEVICE_003',
        'timestamp': now,
        'heart_rate': 78,
        'body_temperature': 36.7,
        'battery_level': 88,
      },
      {
        'employee_id': 'EMP004',
        'device_id': 'DEVICE_004',
        'timestamp': now,
        'heart_rate': 74,
        'body_temperature': 36.4,
        'battery_level': 91,
      }
    ];
    
    for (var health in healthData) {
      totalOperations++;
      try {
        print('   🧪 Testando saúde ${health['employee_id']}...');
        
        final response = await http.post(
          Uri.parse('$baseUrl/api/iot/health'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(health),
        );
        
        if (response.statusCode == 201) {
          print('   ✅ Saúde ${health['employee_id']} - ${health['heart_rate']}bpm - SUCESSO');
          successCount++;
        } else {
          print('   ❌ Erro ${health['employee_id']}: ${response.statusCode}');
          print('      ${response.body}');
          
          // Debug detalhado
          final responseData = jsonDecode(response.body);
          if (responseData['details'] != null) {
            print('      Detalhes: ${responseData['details']}');
          }
        }
      } catch (e) {
        print('   ❌ Exceção ${health['employee_id']}: $e');
      }
      
      // Aguardar entre requisições
      await Future.delayed(Duration(milliseconds: 800));
    }
    
    await Future.delayed(Duration(seconds: 2));
    
    // 3. Localizações COM TODOS OS CAMPOS OBRIGATÓRIOS
    print('\n📍 3. ADICIONANDO LOCALIZAÇÕES...');
    final locations = [
      {
        'employee_id': 'EMP001',
        'device_id': 'DEVICE_001',
        'timestamp': now,  // ✅ CAMPO OBRIGATÓRIO
        'latitude': '-3.7319',  // ✅ COMO STRING (conforme model)
        'longitude': '-38.5267',  // ✅ COMO STRING (conforme model)
      },
      {
        'employee_id': 'EMP002',
        'device_id': 'DEVICE_002',
        'timestamp': now,
        'latitude': '-3.7330',
        'longitude': '-38.5280',
      },
      {
        'employee_id': 'EMP003',
        'device_id': 'DEVICE_003',
        'timestamp': now,
        'latitude': '-3.7290',
        'longitude': '-38.5240',
      },
      {
        'employee_id': 'EMP004',
        'device_id': 'DEVICE_004',
        'timestamp': now,
        'latitude': '-3.7325',
        'longitude': '-38.5275',
      }
    ];
    
    for (var location in locations) {
      totalOperations++;
      try {
        print('   🧪 Testando localização ${location['employee_id']}...');
        
        final response = await http.post(
          Uri.parse('$baseUrl/api/iot/location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(location),
        );
        
        if (response.statusCode == 201) {
          print('   ✅ Localização ${location['employee_id']} - (${location['latitude']}, ${location['longitude']}) - SUCESSO');
          successCount++;
        } else {
          print('   ❌ Erro ${location['employee_id']}: ${response.statusCode}');
          print('      ${response.body}');
          
          // Debug detalhado
          final responseData = jsonDecode(response.body);
          if (responseData['details'] != null) {
            print('      Detalhes: ${responseData['details']}');
          }
        }
      } catch (e) {
        print('   ❌ Exceção ${location['employee_id']}: $e');
      }
      
      // Aguardar entre requisições
      await Future.delayed(Duration(milliseconds: 800));
    }
    
    await Future.delayed(Duration(seconds: 3));
    
    // 4. Validação final
    print('\n📊 4. VALIDAÇÃO FINAL...');
    
    try {
      final employeesResponse = await http.get(Uri.parse('$baseUrl/api/employees'));
      if (employeesResponse.statusCode == 200) {
        final employeesData = jsonDecode(employeesResponse.body);
        final count = employeesData['data']?.length ?? 0;
        print('   ✅ Funcionários: $count');
      }
    } catch (e) {
      print('   ⚠️ Erro funcionários: $e');
    }
    
    try {
      final locationsResponse = await http.get(Uri.parse('$baseUrl/api/iot/locations-all'));
      if (locationsResponse.statusCode == 200) {
        final locationsData = jsonDecode(locationsResponse.body);
        final count = locationsData['data']?.length ?? 0;
        print('   ✅ Localizações ativas: $count');
      }
    } catch (e) {
      print('   ⚠️ Erro localizações: $e');
    }
    
    try {
      final statsResponse = await http.get(Uri.parse('$baseUrl/api/iot/stats'));
      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        final zones = statsData['data']?['statistics']?['zone_distribution'] ?? {};
        print('   ✅ Zone detection: $zones');
      }
    } catch (e) {
      print('   ⚠️ Erro stats: $e');
    }
    
    // Relatório final
    print('\n🎉 RESULTADO FINAL:');
    print('==================');
    print('📊 Total operações: $totalOperations');
    print('✅ Sucessos: $successCount');
    print('📈 Taxa sucesso: ${((successCount / totalOperations) * 100).toStringAsFixed(1)}%');
    
    if (successCount >= (totalOperations * 0.8)) {
      print('\n🚀 SUCESSO! BANCO POPULADO!');
      print('✅ Executar teste completo agora:');
      print('   dart run bin/test_pre_deploy_complete.dart');
      print('\n📋 Se teste 100% → Deploy Fly.io:');
      print('   flyctl deploy --no-cache');
    } else {
      print('\n⚠️ Ainda há falhas. Verificar logs detalhados acima.');
      print('🔧 Possíveis problemas:');
      print('   - Models esperando campos diferentes');
      print('   - Validações específicas nos controllers');
      print('   - Firebase connection issues');
    }
    
  } catch (e) {
    print('\n❌ ERRO GERAL: $e');
  }
}