import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../services/employee_service.dart'; // ✅ MUDANÇA: Usar EmployeeService
import '../utils/response_helper.dart';

// 🎯 CONTROLLER ATUALIZADO: Usando nova arquitetura em camadas
class EmployeeController {
  static final _logger = Logger('EmployeeController');
  final EmployeeService _employeeService =
      EmployeeService(); // ✅ MUDANÇA: Service em vez de FirebaseService

  // 📋 GET /api/employees - Lista todos os funcionários
  Future<Response> getAllEmployees(Request request) async {
    try {
      _logger.info('📋 GET /api/employees - Listando funcionários');

      // ✅ MUDANÇA: Usar EmployeeService (que já tem regras de negócio)
      final employees = await _employeeService.getAllEmployees();
      final employeesJson = employees.map((e) => e.toJson()).toList();

      _logger.info('✅ ${employees.length} funcionários encontrados');

      return ResponseHelper.listSuccess(employeesJson);
    } catch (e) {
      _logger.severe('❌ Erro ao listar funcionários: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // 🔍 GET /api/employees/:id - Busca funcionário por ID
  Future<Response> getEmployeeById(Request request, String id) async {
    try {
      _logger.info('🔍 GET /api/employees/$id - Buscando funcionário');

      // ✅ MUDANÇA: EmployeeService já faz validação do ID internamente
      final employee = await _employeeService.getEmployeeById(id);

      if (employee == null) {
        return ResponseHelper.employeeNotFound(id);
      }

      _logger.info('✅ Funcionário encontrado: ${employee.nome}');
      return ResponseHelper.employeeSuccess(employee.toJson());
    } catch (e) {
      _logger.severe('❌ Erro ao buscar funcionário $id: $e');

      // ✅ MELHORIA: Tratar diferentes tipos de erro
      if (e.toString().contains('InvalidEmployeeDataException')) {
        return ResponseHelper.badRequest(
            e.toString().replaceAll('InvalidEmployeeDataException: ', ''));
      }

      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // ➕ POST /api/employees - Cria novo funcionário
  Future<Response> createEmployee(Request request) async {
    try {
      _logger.info('➕ POST /api/employees - Criando funcionário');

      // Ler e validar JSON
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Corpo da requisição vazio');
      }

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON inválido',
            details: e.toString());
      }

      // ✅ MUDANÇA: EmployeeService já faz todas as validações
      final created = await _employeeService.createEmployee(json);

      _logger.info('✅ Funcionário criado: ${created.nome}');
      return ResponseHelper.employeeCreated(created.toJson());
    } catch (e) {
      _logger.severe('❌ Erro ao criar funcionário: $e');

      // ✅ MELHORIA: Tratamento específico de exceções de negócio
      final errorMessage = e.toString();

      if (errorMessage.contains('InvalidEmployeeDataException')) {
        return ResponseHelper.badRequest(
            errorMessage.replaceAll('InvalidEmployeeDataException: ', ''));
      }

      if (errorMessage.contains('DuplicateEmployeeException')) {
        return ResponseHelper.conflict(
            errorMessage.replaceAll('DuplicateEmployeeException: ', ''));
      }

      if (errorMessage.contains('BusinessRuleException')) {
        return ResponseHelper.validationError(
            errorMessage.replaceAll('BusinessRuleException: ', ''));
      }

      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // 🔄 PUT /api/employees/:id - Atualiza funcionário
  Future<Response> updateEmployee(Request request, String id) async {
    try {
      _logger.info('🔄 PUT /api/employees/$id - Atualizando funcionário');

      // Ler e validar JSON
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Corpo da requisição vazio');
      }

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON inválido',
            details: e.toString());
      }

      // ✅ MUDANÇA: EmployeeService já faz todas as validações e regras de negócio
      final updated = await _employeeService.updateEmployee(id, json);

      _logger.info('✅ Funcionário atualizado: ${updated.nome}');
      return ResponseHelper.employeeUpdated(updated.toJson());
    } catch (e) {
      _logger.severe('❌ Erro ao atualizar funcionário $id: $e');

      // ✅ MELHORIA: Tratamento específico de exceções
      final errorMessage = e.toString();

      if (errorMessage.contains('EmployeeNotFoundException')) {
        return ResponseHelper.employeeNotFound(id);
      }

      if (errorMessage.contains('InvalidEmployeeDataException')) {
        return ResponseHelper.badRequest(
            errorMessage.replaceAll('InvalidEmployeeDataException: ', ''));
      }

      if (errorMessage.contains('DuplicateEmployeeException')) {
        return ResponseHelper.conflict(
            errorMessage.replaceAll('DuplicateEmployeeException: ', ''));
      }

      if (errorMessage.contains('BusinessRuleException')) {
        return ResponseHelper.validationError(
            errorMessage.replaceAll('BusinessRuleException: ', ''));
      }

      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // 🗑️ DELETE /api/employees/:id - Remove funcionário
  Future<Response> deleteEmployee(Request request, String id) async {
    try {
      _logger.info('🗑️ DELETE /api/employees/$id - Removendo funcionário');

      // ✅ MUDANÇA: EmployeeService já faz todas as validações
      final deleted = await _employeeService.deleteEmployee(id);

      if (deleted) {
        _logger.info('✅ Funcionário removido: $id');
        return ResponseHelper.employeeDeleted(id);
      } else {
        return ResponseHelper.internalError(
            details: 'Falha ao remover funcionário');
      }
    } catch (e) {
      _logger.severe('❌ Erro ao deletar funcionário $id: $e');

      // ✅ MELHORIA: Tratamento específico de exceções
      final errorMessage = e.toString();

      if (errorMessage.contains('EmployeeNotFoundException')) {
        return ResponseHelper.employeeNotFound(id);
      }

      if (errorMessage.contains('InvalidEmployeeDataException')) {
        return ResponseHelper.badRequest(
            errorMessage.replaceAll('InvalidEmployeeDataException: ', ''));
      }

      if (errorMessage.contains('BusinessRuleException')) {
        return ResponseHelper.validationError(
            errorMessage.replaceAll('BusinessRuleException: ', ''));
      }

      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // 📊 GET /api/employees/stats - Estatísticas (novo endpoint)
  Future<Response> getEmployeeStats(Request request) async {
    try {
      _logger
          .info('📊 GET /api/employees/stats - Estatísticas de funcionários');

      final stats = await _employeeService.getStatistics();

      _logger.info('✅ Estatísticas calculadas');
      return ResponseHelper.success(
          data: stats, message: 'Estatísticas calculadas com sucesso');
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }

  // 🧹 CLEANUP - Limpeza de recursos
  void dispose() {
    _employeeService.dispose();
    _logger.info('🧹 EmployeeController disposed');
  }
}