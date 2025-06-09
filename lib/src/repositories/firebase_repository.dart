import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:dotenv/dotenv.dart';

// 🏪 REPOSITORY: Acesso puro ao Firebase (sem lógica de negócio)
class FirebaseRepository {
  static final _logger = Logger('FirebaseRepository');
  
  // 🔧 CONFIGURAÇÃO
  static String? _projectId;
  static String? _baseUrl;
  
  // 📖 CONCEITO: Lazy initialization
  static String get projectId {
    if (_projectId == null) _initializeConfig();
    return _projectId!;
  }
  
  static String get baseUrl {
    if (_baseUrl == null) _initializeConfig();
    return _baseUrl!;
  }
  
  // 🔧 Inicialização segura de configuração
  static void _initializeConfig() {
    if (_projectId != null && _baseUrl != null) return;
    
    final env = DotEnv();
    try {
      env.load();
    } catch (e) {
      _logger.warning('⚠️ Arquivo .env não encontrado, usando variáveis do sistema');
    }
    
    _projectId = env['FIREBASE_PROJECT_ID'] ?? 
                Platform.environment['FIREBASE_PROJECT_ID'] ?? 
                'senai-monitoring-api';
    
    _baseUrl = 'https://firestore.googleapis.com/v1';
    
    _logger.info('🔧 Firebase Repository configurado: $_projectId');
  }
  
  // 🌐 Cliente HTTP reutilizável
  final http.Client _client = http.Client();
  
  // 📋 Headers padrão
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 🔗 URL builders
  String _getCollectionUrl(String collection) {
    return '$baseUrl/projects/$projectId/databases/(default)/documents/$collection';
  }
  
  String _getDocumentUrl(String collection, String documentId) {
    return '${_getCollectionUrl(collection)}/$documentId';
  }
  
  // 📋 GET COLLECTION - Buscar todos documentos de uma coleção
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      _logger.info('📋 GET collection: $collection');
      
      final response = await _client.get(
        Uri.parse(_getCollectionUrl(collection)),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>? ?? [];
        
        _logger.info('✅ Collection $collection: ${documents.length} documentos');
        return documents.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        _logger.info('📭 Collection $collection vazia');
        return [];
      } else {
        throw FirebaseException(
          'GET collection failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      _logger.severe('❌ Erro ao buscar collection $collection: $e');
      rethrow;
    }
  }
  
  // 📄 GET DOCUMENT - Buscar documento específico
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    try {
      _logger.info('📄 GET document: $collection/$documentId');
      
      final response = await _client.get(
        Uri.parse(_getDocumentUrl(collection, documentId)),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final document = jsonDecode(response.body);
        _logger.info('✅ Document encontrado: $collection/$documentId');
        return document;
      } else if (response.statusCode == 404) {
        _logger.info('❌ Document não encontrado: $collection/$documentId');
        return null;
      } else {
        throw FirebaseException(
          'GET document failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      _logger.severe('❌ Erro ao buscar document $collection/$documentId: $e');
      rethrow;
    }
  }
  
  // ➕ CREATE/UPDATE DOCUMENT - Criar ou atualizar documento
  Future<Map<String, dynamic>> saveDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.info('💾 SAVE document: $collection/$documentId');
      
      final response = await _client.patch(
        Uri.parse(_getDocumentUrl(collection, documentId)),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final document = jsonDecode(response.body);
        _logger.info('✅ Document salvo: $collection/$documentId');
        return document;
      } else {
        throw FirebaseException(
          'SAVE document failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      _logger.severe('❌ Erro ao salvar document $collection/$documentId: $e');
      rethrow;
    }
  }
  
  // 🗑️ DELETE DOCUMENT - Remover documento
  Future<bool> deleteDocument(String collection, String documentId) async {
    try {
      _logger.info('🗑️ DELETE document: $collection/$documentId');
      
      final response = await _client.delete(
        Uri.parse(_getDocumentUrl(collection, documentId)),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        _logger.info('✅ Document deletado: $collection/$documentId');
        return true;
      } else if (response.statusCode == 404) {
        _logger.warning('⚠️ Document não encontrado para deletar: $collection/$documentId');
        return false;
      } else {
        throw FirebaseException(
          'DELETE document failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      _logger.severe('❌ Erro ao deletar document $collection/$documentId: $e');
      rethrow;
    }
  }
  
  // 🔍 CHECK EXISTENCE - Verificar se documento existe
  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final document = await getDocument(collection, documentId);
      return document != null;
    } catch (e) {
      _logger.warning('⚠️ Erro ao verificar existência de $collection/$documentId: $e');
      return false;
    }
  }
  
  // 🧪 TEST CONNECTION - Testar conectividade
  Future<bool> testConnection() async {
    try {
      _logger.info('🧪 Testando conexão Firebase...');
      
      // Tentar acessar qualquer collection (mesmo que não exista)
      final response = await _client.get(
        Uri.parse(_getCollectionUrl('_test')),
        headers: _headers,
      );
      
      // 200 (existe) ou 404 (não existe) = conexão OK
      final connected = response.statusCode == 200 || response.statusCode == 404;
      
      if (connected) {
        _logger.info('✅ Conexão Firebase OK');
      } else {
        _logger.severe('❌ Falha na conexão Firebase: ${response.statusCode}');
      }
      
      return connected;
    } catch (e) {
      _logger.severe('❌ Erro de conexão Firebase: $e');
      return false;
    }
  }
  
  // 🧹 CLEANUP - Fechar recursos
  void dispose() {
    _client.close();
  }
}

// 🚨 EXCEPTION: Erros específicos do Firebase
class FirebaseException implements Exception {
  final String message;
  final int statusCode;
  final String response;
  
  FirebaseException(this.message, this.statusCode, this.response);
  
  @override
  String toString() {
    return 'FirebaseException: $message (HTTP $statusCode)\nResponse: $response';
  }
}

/*
🎓 CONCEITOS DO REPOSITORY PATTERN:

1. 🏪 **Data Access Layer**
   - Só operações de banco/storage
   - Sem lógica de negócio
   - Interface genérica para Firebase

2. 🔄 **CRUD Operations**
   - Create, Read, Update, Delete
   - Operações básicas de persistência
   - Reutilizável para qualquer entidade

3. 🛡️ **Error Handling**
   - Exceptions específicas do Firebase
   - Logs detalhados para debugging
   - Status codes HTTP mapeados

4. 🧪 **Testability**
   - Interface bem definida
   - Mockable para testes
   - Sem dependências externas complexas

5. 🔧 **Configuration**
   - Lazy loading de configurações
   - Environment variables
   - Singleton de configuração

6. 📊 **Performance**
   - Cliente HTTP reutilizável
   - Headers padronizados
   - Connection pooling implícito
*/