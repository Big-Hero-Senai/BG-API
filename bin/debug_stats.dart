// 📁 bin/debug_stats.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 🔍 TESTE ESPECÍFICO PARA DEBUG DO ENDPOINT DE ESTATÍSTICAS
void main() async {
  print('🔍 DEBUG: Testando endpoint de estatísticas');
  print('=' * 50);
  
  final client = http.Client();
  const baseUrl = 'http://localhost:8080';
  
  try {
    // 1. Verificar se servidor está online
    print('🔌 Verificando conexão...');
    final healthResponse = await client.get(Uri.parse('$baseUrl/health'));
    if (healthResponse.statusCode != 200) {
      throw Exception('Servidor não está respondendo');
    }
    print('✅ Servidor online\n');
    
    // 2. Testar rota de stats com detalhes - NOVA ROTA
    print('📊 Testando /api/employees-stats...');
    final statsResponse = await client.get(
      Uri.parse('$baseUrl/api/employees-stats'),  // ✅ NOVA ROTA
    );
    
    print('📋 Status Code: ${statsResponse.statusCode}');
    print('📋 Headers: ${statsResponse.headers}');
    print('📋 Body: ${statsResponse.body}');
    
    if (statsResponse.statusCode == 200) {
      try {
        final data = jsonDecode(statsResponse.body);
        print('✅ JSON válido recebido');
        print('📊 Dados: $data');
      } catch (e) {
        print('❌ Erro ao decodificar JSON: $e');
      }
    } else {
      print('❌ Erro HTTP: ${statsResponse.statusCode}');
      
      // Tentar decodificar o erro
      try {
        final errorData = jsonDecode(statsResponse.body);
        print('📋 Detalhes do erro: $errorData');
      } catch (e) {
        print('📋 Corpo da resposta (raw): ${statsResponse.body}');
      }
    }
    
    // 3. Testar outras rotas para comparar
    print('\n🔍 Testando outras rotas para comparação:');
    
    // Testar /api/employees (lista)
    final employeesResponse = await client.get(Uri.parse('$baseUrl/api/employees'));
    print('📋 GET /api/employees: ${employeesResponse.statusCode}');
    
    // Testar /api/stats (sistema)
    final systemStatsResponse = await client.get(Uri.parse('$baseUrl/api/stats'));
    print('📋 GET /api/stats: ${systemStatsResponse.statusCode}');
    
    // 4. Verificar se é problema de roteamento
    print('\n🗺️ Verificando roteamento:');
    
    // Testar com ID fictício para ver se vai para a rota correta
    final fakeIdResponse = await client.get(Uri.parse('$baseUrl/api/employees/FAKE123'));
    print('📋 GET /api/employees/FAKE123: ${fakeIdResponse.statusCode}');
    
  } catch (e) {
    print('❌ Erro durante teste: $e');
  } finally {
    client.close();
  }
}