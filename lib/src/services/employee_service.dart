import 'package:logging/logging.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';
import '../services/validation_service.dart';

// 🧠 SERVICE: Regras de negócio de Employee
class EmployeeService {
  static final _logger = Logger('EmployeeService');

  final EmployeeRepository _repository = EmployeeRepository();

  // 📋 LISTAR TODOS - Com regras de negócio
  Future<List<Employee>> getAllEmployees() async {
    try {
      _logger.info('📋 Listando funcionários (com regras de negócio)');

      final employees = await _repository.getAllEmployees();

      // 📊 REGRA: Log estatísticas para monitoramento
      if (employees.isNotEmpty) {
        final ativos = employees.where((e) => e.ativo).length;
        final veteranos = employees.where((e) => e.isVeterano).length;
        _logger.info(
            '📊 Status: $ativos ativos, $veteranos veteranos de ${employees.length} total');
      }

      return employees;
    } catch (e) {
      _logger.severe('❌ Erro no service ao listar funcionários: $e');
      rethrow;
    }
  }

  // 🔍 BUSCAR POR ID - Com validação
  Future<Employee?> getEmployeeById(String id) async {
    try {
      _logger.info('🔍 Buscando funcionário: $id');

      // 🛡️ REGRA: Validar ID antes de buscar
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        throw InvalidEmployeeDataException(
            'ID inválido: ${idValidation.error}');
      }

      return await _repository.getEmployeeById(id);
    } catch (e) {
      _logger.severe('❌ Erro no service ao buscar funcionário $id: $e');
      rethrow;
    }
  }

  // ➕ CRIAR - Com todas as validações de negócio
  Future<Employee> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      _logger.info('➕ Criando funcionário com regras de negócio');

      // 🛡️ REGRA 1: Validar dados de entrada
      final validation =
          ValidationService.validateEmployeeCreation(employeeData);
      if (!validation.isValid) {
        throw InvalidEmployeeDataException(validation.error!,
            details: validation.details);
      }

      // 🛡️ REGRA 2: Criar Employee (com validações internas)
      Employee employee;
      try {
        employee = Employee.fromJson(employeeData);
      } catch (e) {
        throw InvalidEmployeeDataException('Erro ao criar Employee: $e');
      }

      // 🛡️ REGRA 3: Verificar email duplicado
      final existingByEmail =
          await _repository.getEmployeeByEmail(employee.email);
      if (existingByEmail != null) {
        throw DuplicateEmployeeException(
            'Email ${employee.email} já está em uso pelo funcionário ${existingByEmail.id}');
      }

      // 🛡️ REGRA 4: Verificar ID duplicado
      final existsById = await _repository.employeeExists(employee.id);
      if (existsById) {
        throw DuplicateEmployeeException('ID ${employee.id} já existe');
      }

      // 🛡️ REGRA 5: Validações de negócio específicas
      _validateBusinessRules(employee);

      // ✅ Criar no repository
      final created = await _repository.createEmployee(employee);

      _logger.info('✅ Funcionário criado com sucesso: ${created.nome}');
      return created;
    } catch (e) {
      _logger.severe('❌ Erro no service ao criar funcionário: $e');
      rethrow;
    }
  }

  // 🔄 ATUALIZAR - Com validações de negócio
  Future<Employee> updateEmployee(
      String id, Map<String, dynamic> updateData) async {
    try {
      _logger.info('🔄 Atualizando funcionário: $id');

      // 🛡️ REGRA 1: Validar ID
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        throw InvalidEmployeeDataException(
            'ID inválido: ${idValidation.error}');
      }

      // 🛡️ REGRA 2: Buscar funcionário existente
      final existing = await _repository.getEmployeeById(id);
      if (existing == null) {
        throw EmployeeNotFoundException('Funcionário $id não encontrado');
      }

      // 🛡️ REGRA 3: Validar dados de atualização
      final validation = ValidationService.validateEmployeeUpdate(updateData);
      if (!validation.isValid) {
        throw InvalidEmployeeDataException(validation.error!,
            details: validation.details);
      }

      // 🛡️ REGRA 4: Verificar email duplicado (se email está sendo alterado)
      if (updateData.containsKey('email')) {
        final newEmail = updateData['email'].toString();
        if (newEmail != existing.email) {
          final existingByEmail =
              await _repository.getEmployeeByEmail(newEmail);
          if (existingByEmail != null && existingByEmail.id != id) {
            throw DuplicateEmployeeException(
                'Email $newEmail já está em uso pelo funcionário ${existingByEmail.id}');
          }
        }
      }

      // 🔄 Aplicar atualizações usando métodos seguros do Employee
      try {
        if (updateData.containsKey('email')) {
          existing.atualizarEmail(updateData['email'].toString());
        }

        if (updateData.containsKey('setor')) {
          final novoSetor = Setor.fromString(updateData['setor'].toString());
          existing.transferirSetor(novoSetor, motivo: 'atualização via API');
        }

        if (updateData.containsKey('ativo')) {
          if (updateData['ativo'] == true) {
            existing.ativar();
          } else {
            existing.desativar(motivo: 'desativação via API');
          }
        }
      } catch (e) {
        throw InvalidEmployeeDataException('Erro ao aplicar atualizações: $e');
      }

      // 🛡️ REGRA 5: Validar regras de negócio após mudanças
      _validateBusinessRules(existing);

      // ✅ Salvar no repository
      final updated = await _repository.updateEmployee(existing);

      _logger.info('✅ Funcionário atualizado: ${updated.nome}');
      return updated;
    } catch (e) {
      _logger.severe('❌ Erro no service ao atualizar funcionário $id: $e');
      rethrow;
    }
  }

  // 🗑️ DELETAR - Com validações de negócio
  Future<bool> deleteEmployee(String id) async {
    try {
      _logger.info('🗑️ Deletando funcionário: $id');

      // 🛡️ REGRA 1: Validar ID
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        throw InvalidEmployeeDataException(
            'ID inválido: ${idValidation.error}');
      }

      // 🛡️ REGRA 2: Buscar funcionário para validações
      final existing = await _repository.getEmployeeById(id);
      if (existing == null) {
        throw EmployeeNotFoundException('Funcionário $id não encontrado');
      }

      // 🛡️ REGRA 3: Validações específicas de negócio para exclusão
      // Exemplo: não permitir deletar funcionários com dados críticos
      // if (existing.temDadosIoTVinculados) {
      //   throw BusinessRuleException('Não é possível deletar funcionário com dados IoT ativos');
      // }

      // ✅ Deletar do repository
      final deleted = await _repository.deleteEmployee(id);

      if (deleted) {
        _logger.info('✅ Funcionário deletado: $id');
      }

      return deleted;
    } catch (e) {
      _logger.severe('❌ Erro no service ao deletar funcionário $id: $e');
      rethrow;
    }
  }

  // 📊 OBTER ESTATÍSTICAS - Para dashboard
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      _logger.info('📊 Calculando estatísticas de funcionários');

      final stats = await _repository.getEmployeeStats();

      // 📊 REGRA: Adicionar métricas de negócio
      final employees = await _repository.getAllEmployees();

      // Distribuição por setor
      final setorDistribution = <String, int>{};
      for (final emp in employees) {
        final setor = emp.setor.displayName;
        setorDistribution[setor] = (setorDistribution[setor] ?? 0) + 1;
      }

      // ✅ CORREÇÃO: Converter explicitamente para Map<String, dynamic>
      final result = <String, dynamic>{};
      stats.forEach((key, value) {
        result[key] = value;
      });

      // Métricas adicionais
      result['distribuicao_setores'] = setorDistribution;

      // ✅ CORREÇÃO: Usar nullable operator e verificação
      final totalFuncionarios = stats['total'];
      final funcionariosAtivos = stats['ativos'];

      if (totalFuncionarios != null &&
          funcionariosAtivos != null &&
          totalFuncionarios > 0) {
        result['taxa_ativacao'] =
            ((funcionariosAtivos / totalFuncionarios) * 100).round();
      } else {
        result['taxa_ativacao'] = 0;
      }

      _logger.info('📊 Estatísticas calculadas: ${result.length} métricas');
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas: $e');
      rethrow;
    }
  }

  // 🛡️ VALIDAÇÕES DE REGRAS DE NEGÓCIO
  void _validateBusinessRules(Employee employee) {
    // REGRA: Funcionários do setor de segurança devem estar sempre ativos
    if (employee.setor == Setor.seguranca && !employee.ativo) {
      throw BusinessRuleException(
          'Funcionários do setor de Segurança devem estar sempre ativos');
    }

    // REGRA: Funcionários com mais de 10 anos são considerados especiais
    if (employee.tempoEmpresaAnos > 10) {
      _logger.info(
          '⭐ Funcionário especial detectado: ${employee.nome} (${employee.tempoEmpresaAnos} anos)');
    }

    // Adicione mais regras conforme necessário...
  }

  // 🧹 CLEANUP
  void dispose() {
    _repository.dispose();
  }
}

// 🚨 EXCEPTIONS específicas de negócio
class InvalidEmployeeDataException implements Exception {
  final String message;
  final String? details;

  InvalidEmployeeDataException(this.message, {this.details});

  @override
  String toString() =>
      'InvalidEmployeeDataException: $message${details != null ? ' ($details)' : ''}';
}

class DuplicateEmployeeException implements Exception {
  final String message;

  DuplicateEmployeeException(this.message);

  @override
  String toString() => 'DuplicateEmployeeException: $message';
}

class BusinessRuleException implements Exception {
  final String message;

  BusinessRuleException(this.message);

  @override
  String toString() => 'BusinessRuleException: $message';
}

class EmployeeNotFoundException implements Exception {
  final String message;

  EmployeeNotFoundException(this.message);

  @override
  String toString() => 'EmployeeNotFoundException: $message';
}
