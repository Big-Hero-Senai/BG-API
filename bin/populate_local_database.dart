import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🗃️ POPULANDO BANCO LOCAL - API V2.1.0');
  print('=====================================');
  
  final baseUrl = 'http://localhost:8080';
  var successCount = 0;
  var totalOperations = 0;
  
  try {
    // 1. Verificar se servidor está rodando
    print('\n🔍 1. VERIFICANDO SERVIDOR LOCAL...');
    final healthCheck = await http.get(Uri.parse('$baseUrl/health'));
    if (healthCheck.statusCode == 200) {
      final healthData = jsonDecode(healthCheck.body);
      print('   ✅ Servidor online - ${healthData['service']} v${healthData['version']}');
    } else {
      print('   ❌ Servidor offline - Inicie: dart run bin/server.dart');
      return;
    }
    
    // 2. Criar funcionários base
    print('\n👥 2. CRIANDO FUNCIONÁRIOS BASE...');
    final employees = [
      {
        'id': 'EMP001',
        'nome': 'João Silva',
        'setor': 'producao',
        'cargo': 'Operador de Máquina',
        'email': 'joao@senai.com',
        'data_admissao': '2023-01-15T00:00:00.000Z',
        'ativo': true
      },
      {
        'id': 'EMP002', 
        'nome': 'Maria Santos',
        'setor': 'almoxarifado',
        'cargo': 'Assistente de Estoque',
        'email': 'maria@senai.com',
        'data_admissao': '2023-02-10T00:00:00.000Z',
        'ativo': true
      },
      {
        'id': 'EMP003',
        'nome': 'Carlos Oliveira', 
        'setor': 'administrativo',
        'cargo': 'Supervisor de Qualidade',
        'email': 'carlos@senai.com',
        'data_admissao': '2023-01-20T00:00:00.000Z',
        'ativo': true
      },
      {
        'id': 'EMP004',
        'nome': 'Ana Costa',
        'setor': 'producao', 
        'cargo': 'Técnica de Produção',
        'email': 'ana@senai.com',
        'data_admissao': '2023-03-01T00:00:00.000Z',
        'ativo': true
      }
    ];
    
    for (var employee in employees) {
      totalOperations++;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/employees'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(employee),
        );
        
        if (response.statusCode == 201) {
          print('   ✅ ${employee['nome']} - ${employee['setor']} - CRIADO');
          successCount++;
        } else if (response.statusCode == 409) {
          print('   ⚠️ ${employee['nome']} - Já existe (OK)');
          successCount++; // Considera sucesso se já existe
        } else {
          print('   ❌ ${employee['nome']} - Erro ${response.statusCode}');
          print('      ${response.body}');
        }
      } catch (e) {
        print('   ❌ Erro ao criar ${employee['nome']}: $e');
      }
    }
    
    // Aguardar um pouco para garantir criação
    await Future.delayed(Duration(seconds: 2));
    
    // 3. Adicionar dados de saúde
    print('\n💓 3. ADICIONANDO DADOS DE SAÚDE...');
    final healthData = [
      {
        'employee_id': 'EMP001',
        'heart_rate': 75,
        'temperature': 36.5,
        'battery': 85,
        'device_id': 'DEVICE_001'
      },
      {
        'employee_id': 'EMP002', 
        'heart_rate': 72,
        'temperature': 36.3,
        'battery': 92,
        'device_id': 'DEVICE_002'
      },
      {
        'employee_id': 'EMP003',
        'heart_rate': 78,
        'temperature': 36.7,
        'battery': 88,
        'device_id': 'DEVICE_003'  
      },
      {
        'employee_id': 'EMP004',
        'heart_rate': 74,
        'temperature': 36.4,
        'battery': 91,
        'device_id': 'DEVICE_004'
      }
    ];
    
    for (var health in healthData) {
      totalOperations++;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/iot/health'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(health),
        );
        
        if (response.statusCode == 201) {
          print('   ✅ Saúde ${health['employee_id']} - ${health['heart_rate']}bpm - SALVO');
          successCount++;
        } else {
          print('   ❌ Erro saúde ${health['employee_id']}: ${response.statusCode}');
          print('      ${response.body}');
        }
      } catch (e) {
        print('   ❌ Erro ao enviar dados de saúde: $e');
      }
    }
    
    // Aguardar processamento
    await Future.delayed(Duration(seconds: 2));
    
    // 4. Adicionar localizações em diferentes zonas
    print('\n📍 4. ADICIONANDO LOCALIZAÇÕES POR ZONA...');
    final locations = [
      {
        'employee_id': 'EMP001',
        'latitude': -3.7319,  // setor_producao
        'longitude': -38.5267,
        'device_id': 'DEVICE_001'
      },
      {
        'employee_id': 'EMP002',
        'latitude': -3.7330,  // almoxarifado
        'longitude': -38.5280,
        'device_id': 'DEVICE_002'
      },
      {
        'employee_id': 'EMP003',
        'latitude': -3.7290,  // administrativo
        'longitude': -38.5240,
        'device_id': 'DEVICE_003'
      },
      {
        'employee_id': 'EMP004',
        'latitude': -3.7325,  // setor_producao
        'longitude': -38.5275,
        'device_id': 'DEVICE_004'
      }
    ];
    
    for (var location in locations) {
      totalOperations++;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/iot/location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(location),
        );
        
        if (response.statusCode == 201) {
          print('   ✅ Localização ${location['employee_id']} - (${location['latitude']}, ${location['longitude']}) - SALVO');
          successCount++;
        } else {
          print('   ❌ Erro localização ${location['employee_id']}: ${response.statusCode}');
          print('      ${response.body}');
        }
      } catch (e) {
        print('   ❌ Erro ao enviar localização: $e');
      }
    }
    
    // Aguardar processamento final
    await Future.delayed(Duration(seconds: 3));
    
    // 5. Validação final
    print('\n📊 5. VALIDAÇÃO FINAL DOS DADOS...');
    
    // Verificar funcionários
    try {
      final employeesResponse = await http.get(Uri.parse('$baseUrl/api/employees'));
      if (employeesResponse.statusCode == 200) {
        final employeesData = jsonDecode(employeesResponse.body);
        final count = employeesData['data']?.length ?? 0;
        print('   ✅ Funcionários criados: $count');
      }
    } catch (e) {
      print('   ⚠️ Erro ao verificar funcionários: $e');
    }
    
    // Verificar localizações
    try {
      final locationsResponse = await http.get(Uri.parse('$baseUrl/api/iot/locations-all'));
      if (locationsResponse.statusCode == 200) {
        final locationsData = jsonDecode(locationsResponse.body);
        final count = locationsData['data']?.length ?? 0;
        print('   ✅ Localizações ativas: $count');
      }
    } catch (e) {
      print('   ⚠️ Erro ao verificar localizações: $e');
    }
    
    // Verificar estatísticas e zone detection
    try {
      final statsResponse = await http.get(Uri.parse('$baseUrl/api/iot/stats'));
      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        final zones = statsData['data']?['statistics']?['zone_distribution'] ?? {};
        print('   ✅ Zone detection: $zones');
      }
    } catch (e) {
      print('   ⚠️ Erro ao verificar estatísticas: $e');
    }
    
    // Relatório final
    print('\n🎉 RELATÓRIO FINAL DE POPULAÇÃO');
    print('==============================');
    print('📊 Operações executadas: $totalOperations');
    print('✅ Operações bem-sucedidas: $successCount');
    print('📈 Taxa de sucesso: ${((successCount / totalOperations) * 100).toStringAsFixed(1)}%');
    
    if (successCount >= (totalOperations * 0.8)) { // 80% sucesso mínimo
      print('\n🚀 BANCO POPULADO COM SUCESSO!');
      print('✅ Pronto para executar teste completo');
      print('✅ Pronto para deploy no Fly.io');
      print('\n📋 Próximos passos:');
      print('1. dart run bin/test_pre_deploy_complete.dart');
      print('2. Se 100% dos testes passarem → Deploy Fly.io');
    } else {
      print('\n⚠️ Muitas operações falharam - Verificar logs acima');
      print('🔄 Pode tentar novamente ou debug individual');
    }
    
  } catch (e) {
    print('\n❌ ERRO GERAL: $e');
    print('🔧 Verificar se o servidor está rodando: dart run bin/server.dart');
  }
}
