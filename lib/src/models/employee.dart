// 🎯 EMPLOYEE MODEL - VERSÃO FINAL
// Sistema de Monitoramento SENAI - Pulseiras IoT

// 📖 ENUM: Setores da empresa
enum Setor {
  producao('Produção'),
  manutencao('Manutenção'), 
  qualidade('Qualidade'),
  administrativo('Administrativo'),
  seguranca('Segurança');
  
  const Setor(this.displayName);
  final String displayName;
  
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

// 👤 CLASSE PRINCIPAL: Funcionário
class Employee {
  // 🔒 DADOS IMUTÁVEIS (identidade)
  final String id;
  final String nome;
  final DateTime dataAdmissao;
  
  // 🔄 DADOS MUTÁVEIS (situação atual)
  String email;
  Setor setor;
  bool ativo;
  
  // 🏗️ CONSTRUCTOR COM VALIDAÇÕES
  Employee({
    required this.id,
    required this.nome,
    required this.dataAdmissao,
    required this.email,
    required this.setor,
    this.ativo = true,
  }) {
    // Validações críticas
    if (id.trim().isEmpty || id.length < 3) {
      throw ArgumentError('❌ ID deve ter pelo menos 3 caracteres');
    }
    if (nome.trim().isEmpty || nome.trim().length < 2) {
      throw ArgumentError('❌ Nome deve ter pelo menos 2 caracteres');
    }
    if (!_isValidEmail(email)) {
      throw ArgumentError('❌ Email inválido: $email');
    }
    if (dataAdmissao.isAfter(DateTime.now())) {
      throw ArgumentError('❌ Data de admissão não pode ser no futuro');
    }
  }
  
  // 🏭 FACTORY: Criar a partir de JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    try {
      return Employee(
        id: json['id']?.toString() ?? '',
        nome: json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        setor: Setor.fromString(json['setor']?.toString() ?? ''),
        dataAdmissao: DateTime.parse(json['data_admissao']?.toString() ?? ''),
        ativo: json['ativo'] == true,
      );
    } catch (e) {
      throw ArgumentError('❌ Erro ao converter JSON: $e');
    }
  }
  
  // 📤 CONVERSÃO PARA JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'setor': setor.name,
      'setor_display': setor.displayName,
      'data_admissao': dataAdmissao.toIso8601String(),
      'ativo': ativo,
      'tempo_empresa_anos': tempoEmpresaAnos,
      'is_veterano': isVeterano,
      'status': statusDetalhado,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  Map<String, dynamic> toJsonCompact() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'setor': setor.name,
      'ativo': ativo,
    };
  }
  
  // 🔧 MÉTODOS DE ATUALIZAÇÃO
  void atualizarEmail(String novoEmail) {
    if (!_isValidEmail(novoEmail)) {
      throw ArgumentError('❌ Email inválido: $novoEmail');
    }
    email = novoEmail;
  }
  
  void transferirSetor(Setor novoSetor, {String? motivo}) {
    setor = novoSetor;
  }
  
  void ativar() => ativo = true;
  void desativar({String? motivo}) => ativo = false;
  
  // 📊 GETTERS CALCULADOS
  int get tempoEmpresaAnos {
    final diferenca = DateTime.now().difference(dataAdmissao);
    return (diferenca.inDays / 365).floor();
  }
  
  bool get isVeterano => tempoEmpresaAnos >= 5;
  
  String get statusDetalhado {
    final status = ativo ? '🟢 Conectado' : '🔴 Desconectado';
    return '$status | ${setor.displayName}';
  }
  
  // 🔍 VALIDAÇÃO PRIVADA
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
  
  // 📋 DEBUG
  @override
  String toString() {
    return 'Employee(${id}: ${nome}, ${setor.displayName}, ${ativo ? "ativo" : "inativo"})';
  }
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is Employee && other.id == id);
  }
  
  @override
  int get hashCode => id.hashCode;
}