import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/employee.dart';

// 🔥 SERVICE: Comunicação com Firebase Firestore
class FirebaseService {
  static final _logger = Logger('FirebaseService');
  
  // 🔧 CONFIGURAÇÃO - ALTERE AQUI COM SEU PROJETO!
  static const String projectId = 'senai-monitoring-api';  // ✅ CORRETO!
  static const String baseUrl = 'https://firestore.googleapis.com/v1';
  static const String collection = 'employees';
  
  // 📖 CONCEITO: Singleton Pattern (uma única instância)
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  // 🌐 Cliente HTTP reutilizável
  final http.Client _client = http.Client();
  
  // 🔗 URLs do Firestore REST API
  String get _collectionUrl => '$baseUrl/projects/$projectId/databases/(default)/documents/$collection';
  String _documentUrl(String id) => '$_collectionUrl/$id';
  
  // 📋 Headers padrão
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 📖 CONCEITO: Converter Employee para formato Firebase
  Map<String, dynamic> _employeeToFirebaseFormat(Employee employee) {
    return {
      'fields': {
        'id': {'stringValue': employee.id},
        'nome': {'stringValue': employee.nome},
        'email': {'stringValue': employee.email},
        'setor': {'stringValue': employee.setor.name},
        'data_admissao': {'timestampValue': employee.dataAdmissao.toUtc().toIso8601String()},
        'ativo': {'booleanValue': employee.ativo},
        'created_at': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }
    };
  }
  
  // 📖 CONCEITO: Converter formato Firebase para Employee
  Employee _firebaseFormatToEmployee(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    
    return Employee.fromJson({
      'id': fields['id']?['stringValue'] ?? '',
      'nome': fields['nome']?['stringValue'] ?? '',
      'email': fields['email']?['stringValue'] ?? '',
      'setor': fields['setor']?['stringValue'] ?? '',
      'data_admissao': fields['data_admissao']?['timestampValue'] ?? '',
      'ativo': fields['ativo']?['booleanValue'] ?? true,
    });
  }
  
  // 🔍 LISTAR TODOS OS FUNCIONÁRIOS
  Future<List<Employee>> getAllEmployees() async {
    try {
      _logger.info('📋 Buscando todos os funcionários...');
      
      final response = await _client.get(
        Uri.parse(_collectionUrl),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Employee> employees = [];
        
        if (data['documents'] != null) {
          for (final doc in data['documents']) {
            try {
              final employee = _firebaseFormatToEmployee(doc);
              employees.add(employee);
            } catch (e) {
              _logger.warning('⚠️ Erro ao parsear documento: $e');
            }
          }
        }
        
        _logger.info('✅ ${employees.length} funcionários encontrados');
        return employees;
      } else if (response.statusCode == 404) {
        _logger.info('📋 Nenhum funcionário encontrado (coleção vazia)');
        return [];
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao buscar funcionários: $e');
      rethrow;
    }
  }
  
  // 🔍 BUSCAR FUNCIONÁRIO POR ID
  Future<Employee?> getEmployeeById(String id) async {
    try {
      _logger.info('🔍 Buscando funcionário: $id');
      
      final response = await _client.get(
        Uri.parse(_documentUrl(id)),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final employee = _firebaseFormatToEmployee(data);
        _logger.info('✅ Funcionário encontrado: ${employee.nome}');
        return employee;
      } else if (response.statusCode == 404) {
        _logger.info('❌ Funcionário não encontrado: $id');
        return null;
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao buscar funcionário $id: $e');
      rethrow;
    }
  }
  
  // ➕ CRIAR NOVO FUNCIONÁRIO
  Future<Employee> createEmployee(Employee employee) async {
    try {
      _logger.info('➕ Criando funcionário: ${employee.nome}');
      
      // Verificar se já existe
      final existing = await getEmployeeById(employee.id);
      if (existing != null) {
        throw Exception('Funcionário ${employee.id} já existe');
      }
      
      final firebaseData = _employeeToFirebaseFormat(employee);
      
      final response = await _client.patch(
        Uri.parse(_documentUrl(employee.id)),
        headers: _headers,
        body: jsonEncode(firebaseData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('✅ Funcionário criado: ${employee.nome}');
        return employee;
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao criar funcionário: $e');
      rethrow;
    }
  }
  
  // 🔄 ATUALIZAR FUNCIONÁRIO
  Future<Employee> updateEmployee(Employee employee) async {
    try {
      _logger.info('🔄 Atualizando funcionário: ${employee.nome}');
      
      final firebaseData = _employeeToFirebaseFormat(employee);
      
      final response = await _client.patch(
        Uri.parse(_documentUrl(employee.id)),
        headers: _headers,
        body: jsonEncode(firebaseData),
      );
      
      if (response.statusCode == 200) {
        _logger.info('✅ Funcionário atualizado: ${employee.nome}');
        return employee;
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao atualizar funcionário: $e');
      rethrow;
    }
  }
  
  // 🗑️ DELETAR FUNCIONÁRIO
  Future<bool> deleteEmployee(String id) async {
    try {
      _logger.info('🗑️ Deletando funcionário: $id');
      
      final response = await _client.delete(
        Uri.parse(_documentUrl(id)),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        _logger.info('✅ Funcionário deletado: $id');
        return true;
      } else if (response.statusCode == 404) {
        _logger.warning('⚠️ Funcionário não encontrado para deletar: $id');
        return false;
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao deletar funcionário: $e');
      rethrow;
    }
  }
  
  // 🧪 TESTAR CONEXÃO
  Future<bool> testConnection() async {
    try {
      _logger.info('🧪 Testando conexão com Firebase...');
      
      final response = await _client.get(
        Uri.parse(_collectionUrl),
        headers: _headers,
      );
      
      final success = response.statusCode == 200 || response.statusCode == 404;
      
      if (success) {
        _logger.info('✅ Conexão com Firebase OK!');
      } else {
        _logger.severe('❌ Falha na conexão: ${response.statusCode}');
      }
      
      return success;
    } catch (e) {
      _logger.severe('❌ Erro de conexão: $e');
      return false;
    }
  }
  
  // 🔧 Cleanup
  void dispose() {
    _client.close();
  }
}