// 📁 bin/test_api_complete.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 🧪 TESTE AUTOMATIZADO COMPLETO - API SENAI
void main() async {
  print('🧪 INICIANDO TESTE COMPLETO DA API SENAI');
  print('=' * 50);
  
  final apiTester = ApiTester();
  
  try {
    await apiTester.runAllTests();
    print('\n🎉 TODOS OS TESTES PASSARAM!');
  } catch (e) {
    print('\n❌ TESTE FALHOU: $e');
    exit(1);
  }
}

class ApiTester {
  static const String baseUrl = 'http://localhost:8080';
  final http.Client client = http.Client();
  
  // 🎯 EXECUTAR TODOS OS TESTES
  Future<void> runAllTests() async {
    print('📡 Testando conexão com a API...\n');
    
    // 1. Testar se servidor está rodando
    await _testServerConnection();
    
    // 2. Testar endpoints de sistema
    await _testSystemEndpoints();
    
    // 3. Testar CRUD completo de funcionários
    await _testEmployeeCrud();
    
    // 4. Testar validações e erros
    await _testValidations();
    
    // 5. Testar estatísticas
    await _testStatistics();
    
    print('\n✅ SUITE DE TESTES CONCLUÍDA COM SUCESSO!');
  }
  
  // 🔌 TESTE 1: Conexão com servidor
  Future<void> _testServerConnection() async {
    print('🔌 Teste 1: Conexão com servidor');
    
    try {
      final response = await client.get(Uri.parse('$baseUrl/health'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('   ✅ Servidor online: ${data['service']}');
        print('   ✅ Status: ${data['status']}');
      } else {
        throw Exception('Servidor retornou status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
    
    print('');
  }
  
  // 🏥 TESTE 2: Endpoints de sistema
  Future<void> _testSystemEndpoints() async {
    print('🏥 Teste 2: Endpoints de sistema');
    
    // Health Check
    await _testEndpoint('GET', '/health', expectedStatus: 200);
    
    // API Info
    await _testEndpoint('GET', '/api', expectedStatus: 200);
    
    // Documentação
    final docResponse = await client.get(Uri.parse('$baseUrl/'));
    if (docResponse.statusCode == 200 && docResponse.body.contains('SENAI')) {
      print('   ✅ Documentação HTML funcionando');
    } else {
      throw Exception('Documentação não está funcionando');
    }
    
    // Stats do sistema
    await _testEndpoint('GET', '/api/stats', expectedStatus: 200);
    
    print('');
  }
  
  // 👥 TESTE 3: CRUD completo de funcionários
  Future<void> _testEmployeeCrud() async {
    print('👥 Teste 3: CRUD completo de funcionários');
    
    // Dados de teste
    final testEmployee = {
      'id': 'TEST001',
      'nome': 'João Teste Silva',
      'email': 'joao.teste@senai.com',
      'setor': 'producao',
      'data_admissao': '2024-01-15T00:00:00.000Z',
      'ativo': true,
    };
    
    final updateData = {
      'email': 'joao.atualizado@senai.com',
      'setor': 'qualidade',
      'ativo': true,
    };
    
    try {
      // 1. CREATE - Criar funcionário
      print('   📝 Testando CREATE (POST)...');
      final createResponse = await client.post(
        Uri.parse('$baseUrl/api/employees'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(testEmployee),
      );
      
      if (createResponse.statusCode == 201) {
        print('   ✅ Funcionário criado com sucesso');
      } else {
        throw Exception('Falha ao criar: ${createResponse.statusCode}');
      }
      
      // 2. READ - Buscar funcionário criado
      print('   🔍 Testando READ (GET específico)...');
      await _testEndpoint('GET', '/api/employees/TEST001', expectedStatus: 200);
      
      // 3. READ ALL - Listar todos
      print('   📋 Testando READ ALL (GET lista)...');
      final listResponse = await client.get(Uri.parse('$baseUrl/api/employees'));
      if (listResponse.statusCode == 200) {
        final data = jsonDecode(listResponse.body);
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          print('   ✅ Lista de funcionários retornada');
        } else {
          throw Exception('Lista vazia ou formato inválido');
        }
      }
      
      // 4. UPDATE - Atualizar funcionário
      print('   🔄 Testando UPDATE (PUT)...');
      final updateResponse = await client.put(
        Uri.parse('$baseUrl/api/employees/TEST001'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );
      
      if (updateResponse.statusCode == 200) {
        print('   ✅ Funcionário atualizado com sucesso');
      } else {
        throw Exception('Falha ao atualizar: ${updateResponse.statusCode}');
      }
      
      // 5. DELETE - Remover funcionário
      print('   🗑️ Testando DELETE...');
      final deleteResponse = await client.delete(
        Uri.parse('$baseUrl/api/employees/TEST001'),
      );
      
      if (deleteResponse.statusCode == 200) {
        print('   ✅ Funcionário removido com sucesso');
      } else {
        throw Exception('Falha ao deletar: ${deleteResponse.statusCode}');
      }
      
      // 6. Verificar se foi realmente deletado
      print('   🔍 Verificando remoção...');
      final verifyResponse = await client.get(Uri.parse('$baseUrl/api/employees/TEST001'));
      if (verifyResponse.statusCode == 404) {
        print('   ✅ Funcionário removido confirmado');
      } else {
        throw Exception('Funcionário ainda existe após deleção');
      }
      
    } catch (e) {
      // Cleanup: tentar remover funcionário de teste se algo deu errado
      try {
        await client.delete(Uri.parse('$baseUrl/api/employees/TEST001'));
      } catch (_) {}
      rethrow;
    }
    
    print('');
  }
  
  // 🛡️ TESTE 4: Validações e tratamento de erros
  Future<void> _testValidations() async {
    print('🛡️ Teste 4: Validações e erros');
    
    // JSON inválido
    print('   🔍 Testando JSON inválido...');
    final invalidJsonResponse = await client.post(
      Uri.parse('$baseUrl/api/employees'),
      headers: {'Content-Type': 'application/json'},
      body: 'invalid json',
    );
    if (invalidJsonResponse.statusCode == 400) {
      print('   ✅ JSON inválido rejeitado corretamente');
    } else {
      throw Exception('JSON inválido deveria retornar 400');
    }
    
    // Dados obrigatórios ausentes
    print('   🔍 Testando dados obrigatórios...');
    final incompleteResponse = await client.post(
      Uri.parse('$baseUrl/api/employees'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': 'João'}), // ID ausente
    );
    if (incompleteResponse.statusCode == 400 || incompleteResponse.statusCode == 422) {
      print('   ✅ Dados incompletos rejeitados');
    } else {
      throw Exception('Dados incompletos deveriam ser rejeitados');
    }
    
    // Funcionário não encontrado
    print('   🔍 Testando funcionário inexistente...');
    await _testEndpoint('GET', '/api/employees/INEXISTENTE', expectedStatus: 404);
    
    // Endpoint não encontrado
    print('   🔍 Testando endpoint inexistente...');
    await _testEndpoint('GET', '/api/inexistente', expectedStatus: 404);
    
    print('');
  }
  
  // 📊 TESTE 5: Estatísticas
  Future<void> _testStatistics() async {
    print('📊 Teste 5: Estatísticas');
    
    // Stats de funcionários - NOVA ROTA
    final employeeStatsResponse = await client.get(
      Uri.parse('$baseUrl/api/employees-stats'),  // ✅ MUDANÇA: employees/stats → employees-stats
    );
    
    if (employeeStatsResponse.statusCode == 200) {
      final data = jsonDecode(employeeStatsResponse.body);
      if (data['data'] != null && data['data']['total'] != null) {
        print('   ✅ Estatísticas de funcionários funcionando');
      } else {
        throw Exception('Formato de estatísticas inválido');
      }
    } else {
      throw Exception('Falha ao obter estatísticas: ${employeeStatsResponse.statusCode}');
    }
    
    print('');
  }
  
  // 🔧 HELPER: Testar endpoint específico
  Future<void> _testEndpoint(String method, String path, {int expectedStatus = 200}) async {
    late http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await client.get(Uri.parse('$baseUrl$path'));
        break;
      case 'POST':
        response = await client.post(Uri.parse('$baseUrl$path'));
        break;
      case 'PUT':
        response = await client.put(Uri.parse('$baseUrl$path'));
        break;
      case 'DELETE':
        response = await client.delete(Uri.parse('$baseUrl$path'));
        break;
      default:
        throw Exception('Método HTTP não suportado: $method');
    }
    
    if (response.statusCode == expectedStatus) {
      print('   ✅ $method $path - Status: ${response.statusCode}');
    } else {
      throw Exception('$method $path falhou - Esperado: $expectedStatus, Recebido: ${response.statusCode}');
    }
  }
  
  // 🧹 Cleanup
  void dispose() {
    client.close();
  }
}