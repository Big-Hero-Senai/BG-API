// 📖 VERSÃO 1: Employee Básico

class Employee {
  // 📋 PROPRIEDADES (características do funcionário)
  final String id;        // Identificação única
  final String nome;      // Nome completo
  final String email;     // Email corporativo
  final String setor;     // Setor de trabalho
  final bool ativo;       // Se está trabalhando
  
  // 📖 CONCEITO: Constructor (como criar um funcionário)
  Employee({
    required this.id,     // ✅ OBRIGATÓRIO - deve ser fornecido
    required this.nome,   // ✅ OBRIGATÓRIO 
    required this.email,  // ✅ OBRIGATÓRIO
    required this.setor,  // ✅ OBRIGATÓRIO
    this.ativo = true,    // ✅ OPCIONAL - padrão é true
  });
  
  // 📖 CONCEITO: toString() para debug
  // Quando você faz print(funcionario), mostra isso:
  @override
  String toString() {
    return 'Employee(id: $id, nome: $nome, setor: $setor, ativo: $ativo)';
  }
}

// 🧪 EXEMPLO DE USO:
void exemploBasico() {
  // ✅ Criando funcionário
  final joao = Employee(
    id: 'EMP001',
    nome: 'João Silva',
    email: 'joao.silva@senai.com',
    setor: 'Produção',
  );
  
  print('👤 Funcionário criado: $joao');
  
  // 🔍 Acessando propriedades
  print('📧 Email: ${joao.email}');
  print('🏭 Setor: ${joao.setor}');
  print('✅ Ativo: ${joao.ativo}');
}
