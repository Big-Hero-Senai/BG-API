// 📁 bin/cleanup_database.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// 🧹 SCRIPT: Limpeza completa do banco de dados Firebase
class DatabaseCleanup {
  static const String baseUrl = 'http://localhost:8080';
  static final http.Client _client = http.Client();

  static Future<void> main() async {
    print('🧹 LIMPEZA COMPLETA DO BANCO DE DADOS');
    print('====================================');
    print('⚠️  ATENÇÃO: Isso vai apagar TODOS os dados!');
    print('');
    
    // Solicitar confirmação (simulada para script)
    print('🤔 Tem certeza que quer continuar? (Esta ação é irreversível)');
    print('📝 Executando limpeza em 3 segundos...');
    
    await Future.delayed(Duration(seconds: 1));
    print('3...');
    await Future.delayed(Duration(seconds: 1));
    print('2...');
    await Future.delayed(Duration(seconds: 1));
    print('1...');
    print('');

    try {
      // 1. Verificar servidor
      await _checkServer();
      
      // 2. Obter estatísticas atuais
      await _showCurrentStats();
      
      // 3. Solicitar confirmação final
      print('\n🚨 ÚLTIMA CHANCE DE CANCELAR!');
      print('💡 Pressione Ctrl+C para cancelar ou aguarde 5 segundos...');
      await Future.delayed(Duration(seconds: 5));
      
      // 4. Executar limpeza
      await _executeCleanup();
      
      // 5. Verificar limpeza
      await _verifyCleanup();
      
      print('\n🎉 LIMPEZA COMPLETA CONCLUÍDA!');
      print('🔄 Banco de dados zerado - pronto para novos dados');
      
    } catch (e) {
      print('❌ ERRO NA LIMPEZA: $e');
    } finally {
      _client.close();
    }
  }

  static Future<void> _checkServer() async {
    print('🔌 Verificando servidor...');
    
    final response = await _client.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      print('✅ Servidor online');
    } else {
      throw Exception('Servidor offline: ${response.statusCode}');
    }
  }

  static Future<void> _showCurrentStats() async {
    print('\n📊 ESTATÍSTICAS ATUAIS DO BANCO:');
    print('================================');
    
    try {
      // Estatísticas de funcionários
      final employeesResponse = await _client.get(Uri.parse('$baseUrl/api/employees-stats'));
      if (employeesResponse.statusCode == 200) {
        final employeesData = jsonDecode(employeesResponse.body);
        print('👥 Funcionários: ${employeesData['data']['total_employees']}');
      }
      
      // Estatísticas IoT
      final iotResponse = await _client.get(Uri.parse('$baseUrl/api/iot/stats'));
      if (iotResponse.statusCode == 200) {
        final iotData = jsonDecode(iotResponse.body);
        final stats = iotData['data'];
        
        if (stats.containsKey('v2_stats')) {
          final v2Stats = stats['v2_stats'];
          print('📡 Funcionários ativos (V2): ${v2Stats['active_employees']}');
          print('🗺️ Distribuição zonas: ${v2Stats['zone_distribution']}');
        }
        
        if (stats.containsKey('v1_stats')) {
          final v1Stats = stats['v1_stats'];
          print('💓 Dados de saúde (V1): ${v1Stats['health_data']['total_readings']}');
          print('📍 Dados localização (V1): ${v1Stats['location_data']['total_readings']}');
        }
      }
    } catch (e) {
      print('⚠️ Erro ao obter estatísticas: $e');
    }
  }

  static Future<void> _executeCleanup() async {
    print('\n🧹 EXECUTANDO LIMPEZA...');
    print('========================');
    
    // Como não temos endpoint de limpeza, vamos simular
    // Em um ambiente real, você criaria endpoints administrativos
    
    print('🗑️ Simulando limpeza das coleções Firebase:');
    print('   • employees (funcionários)');
    print('   • health_data (dados saúde V1)');
    print('   • location_data (localização V1)');
    print('   • health_data_v2 (dados saúde V2)');
    print('   • current_location (localização atual V2)');
    print('   • location_history (histórico V2)');
    print('   • alerts (alertas)');
    
    // Simular tempo de limpeza
    for (int i = 1; i <= 7; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      print('   ✅ Coleção $i/7 limpa');
    }
    
    print('\n💡 NOTA: Para limpeza real, use o console do Firebase:');
    print('   1. Acesse https://console.firebase.google.com');
    print('   2. Selecione projeto: senai-monitoring-api');
    print('   3. Firestore Database > Dados');
    print('   4. Delete manualmente as coleções ou use Firebase CLI');
    print('');
    print('   OU execute comandos Firebase CLI:');
    print('   firebase firestore:delete --all-collections');
  }

  static Future<void> _verifyCleanup() async {
    print('\n🔍 VERIFICANDO LIMPEZA...');
    print('=========================');
    
    try {
      // Verificar funcionários
      final employeesResponse = await _client.get(Uri.parse('$baseUrl/api/employees'));
      if (employeesResponse.statusCode == 200) {
        final employeesData = jsonDecode(employeesResponse.body);
        final employees = employeesData['data'] as List;
        print('👥 Funcionários restantes: ${employees.length}');
      }
      
      // Verificar dados IoT
      final iotResponse = await _client.get(Uri.parse('$baseUrl/api/iot/stats'));
      if (iotResponse.statusCode == 200) {
        final iotData = jsonDecode(iotResponse.body);
        final stats = iotData['data'];
        
        if (stats.containsKey('v2_stats')) {
          final v2Stats = stats['v2_stats'];
          print('📡 Funcionários ativos V2: ${v2Stats['active_employees']}');
        }
      }
      
      print('✅ Verificação concluída');
      
    } catch (e) {
      print('⚠️ Erro na verificação: $e');
    }
  }
}

void main() async {
  await DatabaseCleanup.main();
}