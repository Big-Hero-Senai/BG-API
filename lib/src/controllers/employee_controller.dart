import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../models/employee.dart';
import '../services/firebase_service.dart';

// 🎯 CONTROLLER: Lógica dos endpoints REST
class EmployeeController {
  static final _logger = Logger('EmployeeController');
  final FirebaseService _firebaseService = FirebaseService();
  
  // 📖 CONCEITO: Headers de resposta JSON padrão
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json; charset=utf-8',
  };
  
  // 📖 CONCEITO: Response helper para erros
  Response _errorResponse(int statusCode, String message, {String? details}) {
    final error = {
      'error': true,
      'message': message,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
      'status_code': statusCode,
    };
    
    _logger.warning('❌ Error $statusCode: $message');
    return Response(statusCode, body: jsonEncode(error), headers: _jsonHeaders);
  }
  
  // 📖 CONCEITO: Response helper para sucesso
  Response _successResponse(dynamic data, {int statusCode = 200, String? message}) {
    final response = {
      'success': true,
      'data': data,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return Response(statusCode, body: jsonEncode(response), headers: _jsonHeaders);
  }
  
  // 📋 GET /api/employees - Lista todos os funcionários
  Future<Response> getAllEmployees(Request request) async {
    try {
      _logger.info('📋 GET /api/employees - Listando funcionários');
      
      final employees = await _firebaseService.getAllEmployees();
      
      _logger.info('✅ ${employees.length} funcionários encontrados');
      
      return _successResponse(
        employees.map((e) => e.toJson()).toList(),
        message: '${employees.length} funcionários encontrados',
      );
    } catch (e) {
      return _errorResponse(500, 'Erro interno do servidor', details: e.toString());
    }
  }
  
  // 🔍 GET /api/employees/:id - Busca funcionário por ID
  Future<Response> getEmployeeById(Request request, String id) async {
    try {
      _logger.info('🔍 GET /api/employees/$id - Buscando funcionário');
      
      // Validar ID
      if (id.trim().isEmpty) {
        return _errorResponse(400, 'ID do funcionário é obrigatório');
      }
      
      final employee = await _firebaseService.getEmployeeById(id);
      
      if (employee == null) {
        return _errorResponse(404, 'Funcionário não encontrado', details: 'ID: $id');
      }
      
      _logger.info('✅ Funcionário encontrado: ${employee.nome}');
      
      return _successResponse(
        employee.toJson(),
        message: 'Funcionário encontrado',
      );
    } catch (e) {
      return _errorResponse(500, 'Erro interno do servidor', details: e.toString());
    }
  }
  
  // ➕ POST /api/employees - Cria novo funcionário
  Future<Response> createEmployee(Request request) async {
    try {
      _logger.info('➕ POST /api/employees - Criando funcionário');
      
      // Ler corpo da requisição
      final body = await request.readAsString();
      if (body.isEmpty) {
        return _errorResponse(400, 'Corpo da requisição vazio');
      }
      
      // Parse JSON
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return _errorResponse(400, 'JSON inválido', details: e.toString());
      }
      
      // Criar Employee a partir do JSON
      Employee employee;
      try {
        employee = Employee.fromJson(json);
      } catch (e) {
        return _errorResponse(400, 'Dados de funcionário inválidos', details: e.toString());
      }
      
      // Verificar se já existe
      final existing = await _firebaseService.getEmployeeById(employee.id);
      if (existing != null) {
        return _errorResponse(409, 'Funcionário já existe', details: 'ID: ${employee.id}');
      }
      
      // Criar no Firebase
      final created = await _firebaseService.createEmployee(employee);
      
      _logger.info('✅ Funcionário criado: ${created.nome}');
      
      return _successResponse(
        created.toJson(),
        statusCode: 201,
        message: 'Funcionário criado com sucesso',
      );
    } catch (e) {
      return _errorResponse(500, 'Erro interno do servidor', details: e.toString());
    }
  }
  
  // 🔄 PUT /api/employees/:id - Atualiza funcionário
  Future<Response> updateEmployee(Request request, String id) async {
    try {
      _logger.info('🔄 PUT /api/employees/$id - Atualizando funcionário');
      
      // Validar ID
      if (id.trim().isEmpty) {
        return _errorResponse(400, 'ID do funcionário é obrigatório');
      }
      
      // Verificar se existe
      final existing = await _firebaseService.getEmployeeById(id);
      if (existing == null) {
        return _errorResponse(404, 'Funcionário não encontrado', details: 'ID: $id');
      }
      
      // Ler corpo da requisição
      final body = await request.readAsString();
      if (body.isEmpty) {
        return _errorResponse(400, 'Corpo da requisição vazio');
      }
      
      // Parse JSON
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return _errorResponse(400, 'JSON inválido', details: e.toString());
      }
      
      // Atualizar campos mutáveis
      try {
        if (json['email'] != null) {
          existing.atualizarEmail(json['email'].toString());
        }
        
        if (json['setor'] != null) {
          final novoSetor = Setor.fromString(json['setor'].toString());
          existing.transferirSetor(novoSetor, motivo: 'atualização via API');
        }
        
        if (json['ativo'] != null) {
          if (json['ativo'] == true) {
            existing.ativar();
          } else {
            existing.desativar(motivo: 'desativação via API');
          }
        }
      } catch (e) {
        return _errorResponse(400, 'Dados de atualização inválidos', details: e.toString());
      }
      
      // Salvar no Firebase
      final updated = await _firebaseService.updateEmployee(existing);
      
      _logger.info('✅ Funcionário atualizado: ${updated.nome}');
      
      return _successResponse(
        updated.toJson(),
        message: 'Funcionário atualizado com sucesso',
      );
    } catch (e) {
      return _errorResponse(500, 'Erro interno do servidor', details: e.toString());
    }
  }
  
  // 🗑️ DELETE /api/employees/:id - Remove funcionário
  Future<Response> deleteEmployee(Request request, String id) async {
    try {
      _logger.info('🗑️ DELETE /api/employees/$id - Removendo funcionário');
      
      // Validar ID
      if (id.trim().isEmpty) {
        return _errorResponse(400, 'ID do funcionário é obrigatório');
      }
      
      // Verificar se existe
      final existing = await _firebaseService.getEmployeeById(id);
      if (existing == null) {
        return _errorResponse(404, 'Funcionário não encontrado', details: 'ID: $id');
      }
      
      // Deletar do Firebase
      final deleted = await _firebaseService.deleteEmployee(id);
      
      if (deleted) {
        _logger.info('✅ Funcionário removido: $id');
        
        return _successResponse(
          {'id': id, 'deleted': true},
          message: 'Funcionário removido com sucesso',
        );
      } else {
        return _errorResponse(500, 'Falha ao remover funcionário');
      }
    } catch (e) {
      return _errorResponse(500, 'Erro interno do servidor', details: e.toString());
    }
  }
}