import '../models/employee.dart';

// 🔄 MAPPER: Conversões Employee ↔ Firebase Format
class EmployeeMapper {
  // 📤 CONVERTER: Employee → Firebase Format
  static Map<String, dynamic> toFirebaseFormat(Employee employee) {
    return {
      'fields': {
        'id': {'stringValue': employee.id},
        'nome': {'stringValue': employee.nome},
        'email': {'stringValue': employee.email},
        'setor': {'stringValue': employee.setor.name},
        'data_admissao': {
          'timestampValue': employee.dataAdmissao.toUtc().toIso8601String()
        },
        'ativo': {'booleanValue': employee.ativo},
        'created_at': {
          'timestampValue': DateTime.now().toUtc().toIso8601String()
        },
        'updated_at': {
          'timestampValue': DateTime.now().toUtc().toIso8601String()
        },
      }
    };
  }

  // 📥 CONVERTER: Firebase Format → Employee
  static Employee fromFirebaseFormat(Map<String, dynamic> firebaseDoc) {
    try {
      final fields = firebaseDoc['fields'] as Map<String, dynamic>;

      // Extrair valores dos campos Firebase
      final employeeData = {
        'id': fields['id']?['stringValue'] ?? '',
        'nome': fields['nome']?['stringValue'] ?? '',
        'email': fields['email']?['stringValue'] ?? '',
        'setor': fields['setor']?['stringValue'] ?? '',
        'data_admissao': fields['data_admissao']?['timestampValue'] ?? '',
        'ativo': fields['ativo']?['booleanValue'] ?? true,
      };

      // Usar o fromJson do Employee (que já tem validações)
      return Employee.fromJson(employeeData);
    } catch (e) {
      throw FormatException(
          'Erro ao converter documento Firebase para Employee: $e');
    }
  }

  // 📋 CONVERTER: Employee → JSON Simples (para outras APIs)
  static Map<String, dynamic> toSimpleJson(Employee employee) {
    return employee.toJson();
  }

  // 📋 CONVERTER: Lista Firebase → Lista Employee
  static List<Employee> fromFirebaseList(List<dynamic> firebaseDocs) {
    final employees = <Employee>[];

    for (final doc in firebaseDocs) {
      try {
        final employee = fromFirebaseFormat(doc as Map<String, dynamic>);
        employees.add(employee);
      } catch (e) {
        // Log erro mas continua processando outros documentos
        print('⚠️ Erro ao converter documento Firebase: $e');
        continue;
      }
    }

    return employees;
  }

  // 📋 CONVERTER: Lista Employee → Lista JSON
  static List<Map<String, dynamic>> toJsonList(List<Employee> employees) {
    return employees.map((e) => e.toJson()).toList();
  }

  // 🔍 EXTRAIR: Document ID de URL Firebase
  static String? extractDocumentId(String? documentPath) {
    if (documentPath == null || documentPath.isEmpty) return null;

    // Firebase document path: "projects/.../documents/employees/EMP001"
    final parts = documentPath.split('/');
    return parts.isNotEmpty ? parts.last : null;
  }

  // 📊 HELPER: Verificar se documento Firebase é válido
  static bool isValidFirebaseDocument(Map<String, dynamic> doc) {
    if (!doc.containsKey('fields')) return false;

    final fields = doc['fields'] as Map<String, dynamic>?;
    if (fields == null) return false;

    // Verificar campos obrigatórios
    final requiredFields = ['id', 'nome', 'email', 'setor'];
    for (final field in requiredFields) {
      if (!fields.containsKey(field)) return false;
    }

    return true;
  }

  // 🛠️ HELPER: Limpar dados antes da conversão
  static Map<String, dynamic> sanitizeFirebaseData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.trim();
      final value = entry.value;

      if (key.isNotEmpty && value != null) {
        // Remover campos de metadados Firebase se existirem
        if (!key.startsWith('_') && !key.contains('metadata')) {
          sanitized[key] = value;
        }
      }
    }

    return sanitized;
  }
}