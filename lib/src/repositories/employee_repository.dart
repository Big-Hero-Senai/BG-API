import 'package:logging/logging.dart';
import '../models/employee.dart';
import '../mappers/employee_mapper.dart';
import 'firebase_repository.dart';

// 👥 REPOSITORY: CRUD específico de Employee
class EmployeeRepository {
  static final _logger = Logger('EmployeeRepository');

  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  static const String _collection = 'employees';

  // 📋 LISTAR TODOS - Buscar todos os funcionários
  Future<List<Employee>> getAllEmployees() async {
    try {
      _logger.info('📋 Buscando todos os funcionários');

      // 1. Buscar documentos do Firebase
      final firebaseDocs = await _firebaseRepository.getCollection(_collection);

      // 2. Converter para Employee usando Mapper
      final employees = EmployeeMapper.fromFirebaseList(firebaseDocs);

      _logger.info('✅ ${employees.length} funcionários encontrados');
      return employees;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar funcionários: $e');
      rethrow;
    }
  }

  // 🔍 BUSCAR POR ID - Funcionário específico
  Future<Employee?> getEmployeeById(String id) async {
    try {
      _logger.info('🔍 Buscando funcionário: $id');

      // 1. Buscar documento do Firebase
      final firebaseDoc =
          await _firebaseRepository.getDocument(_collection, id);

      if (firebaseDoc == null) {
        _logger.info('❌ Funcionário não encontrado: $id');
        return null;
      }

      // 2. Converter para Employee usando Mapper
      final employee = EmployeeMapper.fromFirebaseFormat(firebaseDoc);

      _logger.info('✅ Funcionário encontrado: ${employee.nome}');
      return employee;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar funcionário $id: $e');
      rethrow;
    }
  }

  // ➕ CRIAR - Novo funcionário
  Future<Employee> createEmployee(Employee employee) async {
    try {
      _logger.info('➕ Criando funcionário: ${employee.nome}');

      // 1. Verificar se já existe
      final exists =
          await _firebaseRepository.documentExists(_collection, employee.id);
      if (exists) {
        throw EmployeeAlreadyExistsException(
            'Funcionário ${employee.id} já existe');
      }

      // 2. Converter para formato Firebase usando Mapper
      final firebaseData = EmployeeMapper.toFirebaseFormat(employee);

      // 3. Salvar no Firebase
      await _firebaseRepository.saveDocument(
          _collection, employee.id, firebaseData);

      _logger.info('✅ Funcionário criado: ${employee.nome}');
      return employee;
    } catch (e) {
      _logger.severe('❌ Erro ao criar funcionário: $e');
      rethrow;
    }
  }

  // 🔄 ATUALIZAR - Funcionário existente
  Future<Employee> updateEmployee(Employee employee) async {
    try {
      _logger.info('🔄 Atualizando funcionário: ${employee.nome}');

      // 1. Verificar se existe
      final exists =
          await _firebaseRepository.documentExists(_collection, employee.id);
      if (!exists) {
        throw EmployeeNotFoundException(
            'Funcionário ${employee.id} não encontrado');
      }

      // 2. Converter para formato Firebase usando Mapper
      final firebaseData = EmployeeMapper.toFirebaseFormat(employee);

      // 3. Atualizar no Firebase
      await _firebaseRepository.saveDocument(
          _collection, employee.id, firebaseData);

      _logger.info('✅ Funcionário atualizado: ${employee.nome}');
      return employee;
    } catch (e) {
      _logger.severe('❌ Erro ao atualizar funcionário: $e');
      rethrow;
    }
  }

  // 🗑️ DELETAR - Remover funcionário
  Future<bool> deleteEmployee(String id) async {
    try {
      _logger.info('🗑️ Deletando funcionário: $id');

      // 1. Verificar se existe
      final exists = await _firebaseRepository.documentExists(_collection, id);
      if (!exists) {
        _logger.warning('⚠️ Tentativa de deletar funcionário inexistente: $id');
        return false;
      }

      // 2. Deletar do Firebase
      final deleted = await _firebaseRepository.deleteDocument(_collection, id);

      if (deleted) {
        _logger.info('✅ Funcionário deletado: $id');
      }

      return deleted;
    } catch (e) {
      _logger.severe('❌ Erro ao deletar funcionário $id: $e');
      rethrow;
    }
  }

  // 🔍 VERIFICAR EXISTÊNCIA - Se funcionário existe
  Future<bool> employeeExists(String id) async {
    try {
      return await _firebaseRepository.documentExists(_collection, id);
    } catch (e) {
      _logger.warning('⚠️ Erro ao verificar existência de $id: $e');
      return false;
    }
  }

  // 📧 BUSCAR POR EMAIL - Verificar email duplicado
  Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      _logger.info('📧 Buscando funcionário por email: $email');

      // Firebase não suporta queries complexas via REST API facilmente
      // Então buscamos todos e filtramos (não é ideal para produção)
      final allEmployees = await getAllEmployees();

      try {
        final employee = allEmployees.firstWhere(
          (emp) => emp.email.toLowerCase() == email.toLowerCase(),
        );

        _logger.info('✅ Funcionário encontrado por email: ${employee.nome}');
        return employee;
      } catch (e) {
        _logger.info('❌ Nenhum funcionário encontrado com email: $email');
        return null;
      }
    } catch (e) {
      _logger.severe('❌ Erro ao buscar por email $email: $e');
      rethrow;
    }
  }

  // 📊 ESTATÍSTICAS - Contar funcionários ativos/inativos
  Future<Map<String, int>> getEmployeeStats() async {
    try {
      final allEmployees = await getAllEmployees();

      final stats = {
        'total': allEmployees.length,
        'ativos': allEmployees.where((emp) => emp.ativo).length,
        'inativos': allEmployees.where((emp) => !emp.ativo).length,
        'veteranos': allEmployees.where((emp) => emp.isVeterano).length,
      };

      _logger.info('📊 Estatísticas: ${stats}');
      return stats;
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas: $e');
      rethrow;
    }
  }

  // 🧹 CLEANUP - Fechar recursos
  void dispose() {
    _firebaseRepository.dispose();
  }
}

// 🚨 EXCEPTIONS específicas de Employee
class EmployeeNotFoundException implements Exception {
  final String message;
  EmployeeNotFoundException(this.message);

  @override
  String toString() => 'EmployeeNotFoundException: $message';
}

class EmployeeAlreadyExistsException implements Exception {
  final String message;
  EmployeeAlreadyExistsException(this.message);

  @override
  String toString() => 'EmployeeAlreadyExistsException: $message';
}