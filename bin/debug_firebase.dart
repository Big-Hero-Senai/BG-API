import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 === DEBUG FIREBASE CONNECTION ===\n');
  
  // ⚠️ COLE SEU PROJECT ID AQUI:
  const projectId = 'senai-monitoring-api';
  
  print('🎯 Testando Project ID: $projectId');
  
  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/employees';
  
  print('🌐 URL completa: $url');
  print('📡 Fazendo requisição...\n');
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📊 RESULTADO:');
    print('   Status Code: ${response.statusCode}');
    print('   Headers: ${response.headers}');
    print('   Body: ${response.body}');
    
    switch (response.statusCode) {
      case 200:
        print('\n✅ SUCESSO! Conexão funcionando!');
        final data = jsonDecode(response.body);
        if (data['documents'] != null) {
          print('   📋 Documentos encontrados: ${data['documents'].length}');
        } else {
          print('   📭 Coleção vazia (normal para novo projeto)');
        }
        break;
        
      case 403:
        print('\n❌ ERRO 403: Acesso Negado');
        print('💡 Soluções:');
        print('   1. Verificar se o Project ID está correto');
        print('   2. Configurar regras do Firestore para permitir acesso');
        print('   3. Verificar se o Firestore está ativado');
        break;
        
      case 404:
        print('\n❌ ERRO 404: Projeto não encontrado');
        print('💡 Soluções:');
        print('   1. Verificar o Project ID (provavelmente incorreto)');
        print('   2. Verificar se o projeto existe no Firebase Console');
        break;
        
      default:
        print('\n❌ ERRO ${response.statusCode}');
        print('💡 Erro inesperado, verifique a documentação Firebase');
    }
    
  } catch (e) {
    print('❌ ERRO DE CONEXÃO: $e');
    print('💡 Verificar conexão com internet');
  }
  
  print('\n🎯 PRÓXIMOS PASSOS:');
  print('1. Copie o Project ID correto do Firebase Console');
  print('2. Configure as regras do Firestore para modo teste');
  print('3. Execute este debug novamente');
  print('4. Quando der status 200, execute o teste completo');
}