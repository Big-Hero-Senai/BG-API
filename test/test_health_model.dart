// 📁 test/test_health_model.dart

import '../lib/src/models/health_data.dart';

void main() {
  print('🧪 Testando HealthData Model...\n');

  // 1. Teste de criação básica
  print('📋 1. Teste básico:');
  try {
    final healthData = HealthData(
      employeeId: 'EMP001',
      deviceId: 'DEVICE_001',
      timestamp: DateTime.now().toUtc(),
      heartRate: 75,
      bodyTemperature: 36.5,
      batteryLevel: 85,
    );

    print('✅ HealthData criado: ${healthData}');
    print('   Status: ${healthData.overallStatus.displayName}');
    print('   Crítico: ${healthData.isCriticalAlert}');
  } catch (e) {
    print('❌ Erro: $e');
  }

  // 2. Teste JSON
  print('\n📋 2. Teste JSON:');
  try {
    final json = {
      'employee_id': 'EMP002',
      'device_id': 'DEVICE_002',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'heart_rate': 120,
      'body_temperature': 38.2,
      'oxygen_saturation': 92,
    };

    final healthData = HealthData.fromJson(json);
    print('✅ Criado do JSON: ${healthData}');
    print('   Febre detectada: ${healthData.isFeverDetected}');
    print('   Oxigênio baixo: ${healthData.isLowOxygen}');
    print('   JSON compacto: ${healthData.toJsonCompact()}');
  } catch (e) {
    print('❌ Erro JSON: $e');
  }

  // 3. Teste de validações
  print('\n📋 3. Teste validações:');
  try {
    print('❌ Deveria ter falhado!');
  } catch (e) {
    print('✅ Validação funcionou: $e');
  }

  print('\n🎉 Testes do HealthData concluídos!');
}
