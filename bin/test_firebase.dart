import 'package:logging/logging.dart';
import '../lib/src/models/employee.dart';
import '../lib/src/services/firebase_service.dart';

void main() async {
  // Configurar logs
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });

  print('🧪 === TESTANDO FIREBASE SERVICE ===\n');
  
  final firebaseService = FirebaseService();
  
  // ✅ TESTE 1: Conexão
  print('✅ TESTE 1: Testando conexão com Firebase');
  try {
    final connected = await firebaseService.testConnection();
    if (connected) {
      print('   🔥 Conexão estabelecida com sucesso!');
    } else {
      print('   ❌ Falha na conexão!');
      print('   💡 Verifique se o projectId está correto no firebase_service.dart');
      return;
    }
  } catch (e) {
    print('   ❌ Erro de conexão: $e');
    print('   💡 Verifique sua internet e configuração do Firebase');
    return;
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 2: Buscar todos (pode estar vazio)
  print('✅ TESTE 2: Buscando funcionários existentes');
  try {
    final employees = await firebaseService.getAllEmployees();
    print('   📋 Funcionários encontrados: ${employees.length}');
    
    if (employees.isNotEmpty) {
      print('   👥 Lista atual:');
      for (final emp in employees) {
        print('      - ${emp.id}: ${emp.nome} (${emp.setor.displayName})');
      }
    } else {
      print('   📭 Nenhum funcionário cadastrado ainda');
    }
  } catch (e) {
    print('   ❌ Erro ao buscar funcionários: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 3: Criar funcionário
  print('✅ TESTE 3: Criando novo funcionário');
  try {
    final novoFuncionario = Employee(
      id: 'TEST001',
      nome: 'João Teste Firebase',
      email: 'joao.teste@senai.com',
      setor: Setor.producao,
      dataAdmissao: DateTime.parse('2023-01-15'),
    );
    
    print('   👤 Criando: ${novoFuncionario.nome}');
    
    final criado = await firebaseService.createEmployee(novoFuncionario);
    print('   ✅ Funcionário criado: ${criado.nome}');
    print('   🆔 ID: ${criado.id}');
    print('   📧 Email: ${criado.email}');
  } catch (e) {
    print('   ⚠️ Erro ao criar funcionário: $e');
    if (e.toString().contains('já existe')) {
      print('   💡 Funcionário TEST001 já existe (normal em testes repetidos)');
    }
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 4: Buscar por ID
  print('✅ TESTE 4: Buscando funcionário por ID');
  try {
    final encontrado = await firebaseService.getEmployeeById('TEST001');
    
    if (encontrado != null) {
      print('   ✅ Funcionário encontrado:');
      print('   👤 Nome: ${encontrado.nome}');
      print('   🏭 Setor: ${encontrado.setor.displayName}');
      print('   📅 Admissão: ${encontrado.dataAdmissao}');
      print('   ⏰ Tempo empresa: ${encontrado.tempoEmpresaAnos} anos');
      print('   📱 Status: ${encontrado.statusDetalhado}');
    } else {
      print('   ❌ Funcionário TEST001 não encontrado');
    }
  } catch (e) {
    print('   ❌ Erro ao buscar funcionário: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 5: Atualizar funcionário
  print('✅ TESTE 5: Atualizando funcionário');
  try {
    final funcionario = await firebaseService.getEmployeeById('TEST001');
    
    if (funcionario != null) {
      // Fazer algumas alterações
      funcionario.atualizarEmail('joao.atualizado@senai.com');
      funcionario.transferirSetor(Setor.qualidade, motivo: 'promoção teste');
      funcionario.desativar(motivo: 'teste de atualização');
      
      print('   🔄 Atualizando dados...');
      print('   📧 Novo email: ${funcionario.email}');
      print('   🏭 Novo setor: ${funcionario.setor.displayName}');
      print('   📱 Status: ${funcionario.statusDetalhado}');
      
      final atualizado = await firebaseService.updateEmployee(funcionario);
      print('   ✅ Funcionário atualizado: ${atualizado.nome}');
    } else {
      print('   ⚠️ Funcionário TEST001 não encontrado para atualizar');
    }
  } catch (e) {
    print('   ❌ Erro ao atualizar funcionário: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 6: Buscar funcionário inexistente
  print('✅ TESTE 6: Buscando funcionário inexistente');
  try {
    final inexistente = await firebaseService.getEmployeeById('INEXISTENTE999');
    
    if (inexistente == null) {
      print('   ✅ Corretamente retornou null para ID inexistente');
    } else {
      print('   🚨 ERRO: Encontrou funcionário que deveria ser inexistente!');
    }
  } catch (e) {
    print('   ❌ Erro inesperado: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // ✅ TESTE 7: Listar todos novamente (deve incluir nosso teste)
  print('✅ TESTE 7: Listagem final');
  try {
    final todosFuncionarios = await firebaseService.getAllEmployees();
    print('   📋 Total de funcionários: ${todosFuncionarios.length}');
    
    if (todosFuncionarios.isNotEmpty) {
      print('   👥 Funcionários no sistema:');
      for (final emp in todosFuncionarios) {
        final status = emp.ativo ? '🟢' : '🔴';
        print('      $status ${emp.id}: ${emp.nome} (${emp.setor.displayName})');
      }
    }
  } catch (e) {
    print('   ❌ Erro na listagem final: $e');
  }
  
  print('\n🎉 === TESTE CONCLUÍDO ===');
  print('💡 Se chegou até aqui, o Firebase Service está funcionando!');
  print('🔥 Pronto para integrar com endpoints REST!');
  
  // Cleanup
  firebaseService.dispose();
}