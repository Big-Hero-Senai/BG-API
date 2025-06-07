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
  String email;
  Setor setor;           // 🔄 Agora usa enum em vez de String
  final DateTime dataAdmissao; // 📅 Data de quando entrou na empresa
  bool ativo;
  
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
  
  // 📖 CONCEITO: Métodos para atualizar dados mutáveis
  
  // 📧 Atualizar email
  void atualizarEmail(String novoEmail) {
    if (!_isValidEmail(novoEmail)) {
      throw ArgumentError('❌ Email inválido: $novoEmail');
    }
    
    final emailAntigo = email;
    email = novoEmail;
    print('📧 ${nome}: Email atualizado de $emailAntigo para $novoEmail');
  }
  
  // 🏭 Transferir/promover para outro setor
  void transferirSetor(Setor novoSetor, {String? motivo}) {
    final setorAntigo = setor;
    setor = novoSetor;
    
    final motivoTexto = motivo ?? 'transferência administrativa';
    print('🚀 ${nome}: ${setorAntigo.displayName} → ${novoSetor.displayName} ($motivoTexto)');
  }
  
  // 📱 Gerenciar status da pulseira
  void ativar() {
    if (ativo) {
      print('ℹ️  ${nome} já está ativo');
      return;
    }
    ativo = true;
    print('✅ ${nome}: Pulseira conectada');
  }
  
  void desativar({String? motivo}) {
    if (!ativo) {
      print('ℹ️  ${nome} já está inativo');
      return;
    }
    ativo = false;
    final motivoTexto = motivo ?? 'não especificado';
    print('❌ ${nome}: Pulseira desconectada ($motivoTexto)');
  }
  
  // 📖 CONCEITO: Status e informações detalhadas
  String get statusDetalhado {
    final status = ativo ? '🟢 Conectado' : '🔴 Desconectado';
    return '$status | ${setor.displayName} | ${email}';
  }
  
  // 📋 Histórico de mudanças (simulado)
  String get resumoProfissional {
    return '''
👤 ${nome} (${id})
📧 Email: ${email}
🏭 Setor Atual: ${setor.displayName}
📅 Na empresa há ${tempoEmpresaAnos} anos (desde ${dataAdmissao.year})
📱 Pulseira: ${ativo ? "Conectada" : "Desconectada"}
🏆 ${isVeterano ? "Funcionário Veterano" : "Em desenvolvimento"}
    '''.trim();
  }
  
  @override
  String toString() {
    return 'Employee(${id}: ${nome}, ${setor.displayName}, ${ativo ? "ativo" : "inativo"})';
  }
}
