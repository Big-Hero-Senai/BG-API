// 📁 lib/src/services/validation_service.dart

import '../models/employee.dart';

// 🛡️ RESULTADO DE VALIDAÇÃO
class ValidationResult {
  final bool isValid;
  final String? error;
  final String? details;

  ValidationResult.success()
      : isValid = true,
        error = null,
        details = null;
  ValidationResult.error(this.error, [this.details]) : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}

// 🛡️ SERVICE: Validações centralizadas
class ValidationService {
  // 🔍 VALIDAR ID
  static ValidationResult validateEmployeeId(String? id) {
    if (id == null || id.trim().isEmpty) {
      return ValidationResult.error('ID é obrigatório');
    }

    if (id.trim().length < 3) {
      return ValidationResult.error('ID deve ter pelo menos 3 caracteres');
    }

    // Formato: só letras maiúsculas e números
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(id.trim())) {
      return ValidationResult.error(
          'ID deve conter apenas letras maiúsculas e números');
    }

    return ValidationResult.success();
  }

  // 📧 VALIDAR EMAIL
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.error('Email é obrigatório');
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return ValidationResult.error('Formato de email inválido');
    }

    return ValidationResult.success();
  }

  // 👤 VALIDAR NOME
  static ValidationResult validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.error('Nome é obrigatório');
    }

    if (name.trim().length < 2) {
      return ValidationResult.error('Nome deve ter pelo menos 2 caracteres');
    }

    if (name.trim().length > 100) {
      return ValidationResult.error('Nome muito longo (máximo 100 caracteres)');
    }

    return ValidationResult.success();
  }

  // 🏭 VALIDAR SETOR
  static ValidationResult validateSetor(String? setor) {
    if (setor == null || setor.trim().isEmpty) {
      return ValidationResult.error('Setor é obrigatório');
    }

    try {
      Setor.fromString(setor);
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Setor inválido',
          'Valores válidos: producao, manutencao, qualidade, administrativo, seguranca');
    }
  }

  // 📅 VALIDAR DATA DE ADMISSÃO
  static ValidationResult validateDataAdmissao(DateTime? data) {
    if (data == null) {
      return ValidationResult.error('Data de admissão é obrigatória');
    }

    if (data.isAfter(DateTime.now())) {
      return ValidationResult.error('Data de admissão não pode ser no futuro');
    }

    final dataMinima = DateTime.now().subtract(Duration(days: 365 * 50));
    if (data.isBefore(dataMinima)) {
      return ValidationResult.error(
          'Data de admissão muito antiga (mais de 50 anos)');
    }

    return ValidationResult.success();
  }

  // 📋 VALIDAR JSON DE CRIAÇÃO
  static ValidationResult validateEmployeeCreation(Map<String, dynamic> json) {
    final errors = <String>[];

    // Validar cada campo
    final idResult = validateEmployeeId(json['id']?.toString());
    if (!idResult.isValid) errors.add('ID: ${idResult.error}');

    final nameResult = validateName(json['nome']?.toString());
    if (!nameResult.isValid) errors.add('Nome: ${nameResult.error}');

    final emailResult = validateEmail(json['email']?.toString());
    if (!emailResult.isValid) errors.add('Email: ${emailResult.error}');

    final setorResult = validateSetor(json['setor']?.toString());
    if (!setorResult.isValid) errors.add('Setor: ${setorResult.error}');

    // Validar data (se presente)
    if (json['data_admissao'] != null) {
      try {
        final data = DateTime.parse(json['data_admissao'].toString());
        final dataResult = validateDataAdmissao(data);
        if (!dataResult.isValid) errors.add('Data: ${dataResult.error}');
      } catch (e) {
        errors.add('Data: formato inválido (use ISO8601)');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error('Dados inválidos', errors.join('; '));
    }

    return ValidationResult.success();
  }

  // 🔄 VALIDAR JSON DE ATUALIZAÇÃO
  static ValidationResult validateEmployeeUpdate(Map<String, dynamic> json) {
    final errors = <String>[];

    // Só validar campos presentes
    if (json.containsKey('email')) {
      final emailResult = validateEmail(json['email']?.toString());
      if (!emailResult.isValid) errors.add('Email: ${emailResult.error}');
    }

    if (json.containsKey('setor')) {
      final setorResult = validateSetor(json['setor']?.toString());
      if (!setorResult.isValid) errors.add('Setor: ${setorResult.error}');
    }

    if (json.containsKey('nome')) {
      final nameResult = validateName(json['nome']?.toString());
      if (!nameResult.isValid) errors.add('Nome: ${nameResult.error}');
    }

    if (json.containsKey('ativo') && json['ativo'] is! bool) {
      errors.add('Ativo: deve ser true ou false');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(
          'Dados de atualização inválidos', errors.join('; '));
    }

    return ValidationResult.success();
  }
}
