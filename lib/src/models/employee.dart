// 📖 VERSÃO 2: Employee com Validações e Enum

// 🎯 ENUM: Valores fixos para Setor (evita typos e inconsistências)
enum Setor {
  producao('Produção'),
  manutencao('Manutenção'), 
  qualidade('Qualidade'),
  administrativo('Administrativo'),
  seguranca('Segurança');
  
  // 📖 CONCEITO: Enum com valor amigável
  const Setor(this.displayName);
  final String displayName;
  
  // 🔄 Converter string para enum
  static Setor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'producao':
      case 'produção':
        return Setor.producao;
      case 'manutencao':
      case 'manutenção':
        return Setor.manutencao;
      case 'qualidade':
        return Setor.qualidade;
      case 'administrativo':
        return Setor.administrativo;
      case 'seguranca':
      case 'segurança':
        return Setor.seguranca;
      default:
        throw ArgumentError('Setor inválido: $value');
    }
  }
}

class Employee {
  final String id;
  final String nome;
  final String email;
  final Setor setor;           // 🔄 Agora usa enum em vez de String
  final DateTime dataAdmissao; // 📅 Data de quando entrou na empresa
  final bool ativo;
  
  // 📖 CONCEITO: Constructor com validação
  Employee({
    required this.id,
    required this.nome,
    required this.email,
    required this.setor,
    required this.dataAdmissao,
    this.ativo = true,
  }) {
    // 🔍 VALIDAÇÕES - Bloqueia dados inválidos
    
    // Validar ID
    if (id.trim().isEmpty) {
      throw ArgumentError('❌ ID não pode estar vazio');
    }
    if (id.length < 3) {
      throw ArgumentError('❌ ID deve ter pelo menos 3 caracteres');
    }
    
    // Validar Nome
    if (nome.trim().isEmpty) {
      throw ArgumentError('❌ Nome não pode estar vazio');
    }
    if (nome.trim().length < 2) {
      throw ArgumentError('❌ Nome deve ter pelo menos 2 caracteres');
    }
    
    // Validar Email
    if (!_isValidEmail(email)) {
      throw ArgumentError('❌ Email inválido: $email');
    }
    
    // Validar Data de Admissão
    if (dataAdmissao.isAfter(DateTime.now())) {
      throw ArgumentError('❌ Data de admissão não pode ser no futuro');
    }
    
    // Data muito antiga (mais de 50 anos atrás)
    final dataMinima = DateTime.now().subtract(Duration(days: 365 * 50));
    if (dataAdmissao.isBefore(dataMinima)) {
      throw ArgumentError('❌ Data de admissão muito antiga');
    }
  }
  
  // 🔍 MÉTODO PRIVADO: Validação de email
  bool _isValidEmail(String email) {
    // Regex simples para email: algo@algo.algo
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email);
  }
  
  // 📖 CONCEITO: Getter calculado (tempo de empresa)
  int get tempoEmpresaAnos {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataAdmissao);
    return (diferenca.inDays / 365).floor();
  }
  
  // 📖 CONCEITO: Método para verificar se é veterano
  bool get isVeterano => tempoEmpresaAnos >= 5;
  
  @override
  String toString() {
    return 'Employee(id: $id, nome: $nome, setor: ${setor.displayName}, '
           'admissão: ${dataAdmissao.year}, ${tempoEmpresaAnos} anos na empresa)';
  }
}

