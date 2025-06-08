import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../models/employee.dart';
import '../services/firebase_service.dart';
import '../services/validation_service.dart';
import '../utils/response_helper.dart';

// 🎯 CONTROLLER REFATORADO: Simples e focado
class EmployeeController {
  static final _logger = Logger('EmployeeController');
  final FirebaseService _firebaseService = FirebaseService();
  
  // 📋 GET /api/employees - Lista todos os funcionários  
  Future<Response> getAllEmployees(Request request) async {
    try {
      _logger.info('📋 GET /api/employees - Listando funcionários');
      
      final employees = await _firebaseService.getAllEmployees();
      final employeesJson = employees.map((e) => e.toJson()).toList();
      
      _logger.info('✅ ${employees.length} funcionários encontrados');
      
      return ResponseHelper.listSuccess(employeesJson);
    } catch (e) {
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🔍 GET /api/employees/:id - Busca funcionário por ID
  Future<Response> getEmployeeById(Request request, String id) async {
    try {
      _logger.info('🔍 GET /api/employees/$id - Buscando funcionário');
      
      // Validar ID usando ValidationService
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        return ResponseHelper.badRequest(idValidation.error!, details: idValidation.details);
      }
      
      final employee = await _firebaseService.getEmployeeById(id);
      
      if (employee == null) {
        return ResponseHelper.employeeNotFound(id);
      }
      
      _logger.info('✅ Funcionário encontrado: ${employee.nome}');
      return ResponseHelper.employeeSuccess(employee.toJson());
    } catch (e) {
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
        return ResponseHelper.badRequest('JSON inválido', details: e.toString());
      }
      
      // Validar dados usando ValidationService
      final validation = ValidationService.validateEmployeeCreation(json);
      if (!validation.isValid) {
        return ResponseHelper.validationError(validation.error!, details: validation.details);
      }
      
      // Criar Employee
      Employee employee;
      try {
        employee = Employee.fromJson(json);
      } catch (e) {
        return ResponseHelper.badRequest('Dados de funcionário inválidos', details: e.toString());
      }
      
      // Verificar se já existe
      final existing = await _firebaseService.getEmployeeById(employee.id);
      if (existing != null) {
        return ResponseHelper.employeeAlreadyExists(employee.id);
      }
      
      // Criar no Firebase
      final created = await _firebaseService.createEmployee(employee);
      
      _logger.info('✅ Funcionário criado: ${created.nome}');
      return ResponseHelper.employeeCreated(created.toJson());
    } catch (e) {
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🔄 PUT /api/employees/:id - Atualiza funcionário
  Future<Response> updateEmployee(Request request, String id) async {
    try {
      _logger.info('🔄 PUT /api/employees/$id - Atualizando funcionário');
      
      // Validar ID
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        return ResponseHelper.badRequest(idValidation.error!, details: idValidation.details);
      }
      
      // Verificar se existe
      final existing = await _firebaseService.getEmployeeById(id);
      if (existing == null) {
        return ResponseHelper.employeeNotFound(id);
      }
      
      // Ler e validar JSON
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Corpo da requisição vazio');
      }
      
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON inválido', details: e.toString());
      }
      
      // Validar dados de atualização
      final validation = ValidationService.validateEmployeeUpdate(json);
      if (!validation.isValid) {
        return ResponseHelper.validationError(validation.error!, details: validation.details);
      }
      
      // Aplicar atualizações
      try {
        if (json.containsKey('email')) {
          existing.atualizarEmail(json['email'].toString());
        }
        
        if (json.containsKey('setor')) {
          final novoSetor = Setor.fromString(json['setor'].toString());
          existing.transferirSetor(novoSetor, motivo: 'atualização via API');
        }
        
        if (json.containsKey('ativo')) {
          if (json['ativo'] == true) {
            existing.ativar();
          } else {
            existing.desativar(motivo: 'desativação via API');
          }
        }
      } catch (e) {
        return ResponseHelper.badRequest('Erro ao aplicar atualizações', details: e.toString());
      }
      
      // Salvar no Firebase
      final updated = await _firebaseService.updateEmployee(existing);
      
      _logger.info('✅ Funcionário atualizado: ${updated.nome}');
      return ResponseHelper.employeeUpdated(updated.toJson());
    } catch (e) {
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🗑️ DELETE /api/employees/:id - Remove funcionário
  Future<Response> deleteEmployee(Request request, String id) async {
    try {
      _logger.info('🗑️ DELETE /api/employees/$id - Removendo funcionário');
      
      // Validar ID
      final idValidation = ValidationService.validateEmployeeId(id);
      if (!idValidation.isValid) {
        return ResponseHelper.badRequest(idValidation.error!, details: idValidation.details);
      }
      
      // Verificar se existe
      final existing = await _firebaseService.getEmployeeById(id);
      if (existing == null) {
        return ResponseHelper.employeeNotFound(id);
      }
      
      // Deletar do Firebase
      final deleted = await _firebaseService.deleteEmployee(id);
      
      if (deleted) {
        _logger.info('✅ Funcionário removido: $id');
        return ResponseHelper.employeeDeleted(id);
      } else {
        return ResponseHelper.internalError(details: 'Falha ao remover funcionário');
      }
    } catch (e) {
      return ResponseHelper.internalError(details: e.toString());
    }
  }
}