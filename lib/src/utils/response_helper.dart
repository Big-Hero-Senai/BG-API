// 📁 lib/src/utils/response_helper.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

// 📤 HELPER: Respostas padronizadas da API
class ResponseHelper {
  static final _logger = Logger('ResponseHelper');
  
  // Headers padrão
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
  };
  
  // ✅ SUCESSO GENÉRICO
  static Response success({
    required dynamic data,
    String? message,
    int statusCode = 200,
  }) {
    final responseBody = {
      'success': true,
      'data': data,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return Response(
      statusCode,
      body: jsonEncode(responseBody),
      headers: _jsonHeaders,
    );
  }
  
  // ❌ ERRO GENÉRICO
  static Response error({
    required int statusCode,
    required String message,
    String? details,
  }) {
    final responseBody = {
      'error': true,
      'message': message,
      'details': details,
      'status_code': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _logger.warning('❌ Error $statusCode: $message');
    
    return Response(
      statusCode,
      body: jsonEncode(responseBody),
      headers: _jsonHeaders,
    );
  }
  
  // 📋 MÉTODOS DE CONVENIÊNCIA
  
  // ✅ 200 - OK
  static Response ok(dynamic data, {String? message}) {
    return success(data: data, message: message, statusCode: 200);
  }
  
  // ✅ 201 - Created
  static Response created(dynamic data, {String? message}) {
    return success(
      data: data,
      message: message ?? 'Recurso criado com sucesso',
      statusCode: 201,
    );
  }
  
  // ❌ 400 - Bad Request
  static Response badRequest(String message, {String? details}) {
    return error(statusCode: 400, message: message, details: details);
  }
  
  // ❌ 404 - Not Found
  static Response notFound(String resource, {String? id}) {
    final message = '$resource não encontrado';
    final details = id != null ? 'ID: $id' : null;
    return error(statusCode: 404, message: message, details: details);
  }
  
  // ❌ 409 - Conflict
  static Response conflict(String message, {String? details}) {
    return error(statusCode: 409, message: message, details: details);
  }
  
  // ❌ 422 - Validation Error
  static Response validationError(String message, {String? details}) {
    return error(statusCode: 422, message: message, details: details);
  }
  
  // ❌ 500 - Internal Server Error
  static Response internalError({String? details}) {
    return error(
      statusCode: 500,
      message: 'Erro interno do servidor',
      details: details,
    );
  }
  
  // 📋 HELPERS PARA LISTAS
  static Response listSuccess(List<dynamic> items, {String? message}) {
    final count = items.length;
    final defaultMessage = count == 1 ? '1 item encontrado' : '$count itens encontrados';
    
    return success(data: items, message: message ?? defaultMessage);
  }
  
  // 👥 HELPERS ESPECÍFICOS PARA FUNCIONÁRIOS
  static Response employeeSuccess(dynamic employee, {String? message}) {
    return success(data: employee, message: message ?? 'Funcionário encontrado');
  }
  
  static Response employeeCreated(dynamic employee) {
    return created(employee, message: 'Funcionário criado com sucesso');
  }
  
  static Response employeeUpdated(dynamic employee) {
    return success(data: employee, message: 'Funcionário atualizado com sucesso');
  }
  
  static Response employeeDeleted(String id) {
    return success(
      data: {'id': id, 'deleted': true},
      message: 'Funcionário removido com sucesso',
    );
  }
  
  static Response employeeNotFound(String id) {
    return notFound('Funcionário', id: id);
  }
  
  static Response employeeAlreadyExists(String id) {
    return conflict('Funcionário já existe', details: 'ID: $id');
  }
}