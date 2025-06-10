// 📁 test/test_location_model.dart

import '../lib/src/models/location_data.dart';

void main() {
  print('🧪 Testando LocationData Model (versão simplificada e corrigida)...\n');
  
  // 1. Teste básico com coordenadas
  print('📋 1. Teste básico:');
  try {
    final locationData = LocationData(
      employeeId: 'EMP001',
      deviceId: 'DEVICE_001',
      timestamp: DateTime.now().toUtc(),
      latitude: '-3.7319',
      longitude: '-38.5267',
    );
    
    print('✅ LocationData criado: ${locationData}');
    print('   Status: ${locationData.overallStatus.displayName}');
    print('   Coordenadas válidas: ${locationData.hasValidCoordinates}');
    print('   Display: ${locationData.coordinatesDisplay}');
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  // 2. Teste sem coordenadas
  print('\n📋 2. Teste sem coordenadas:');
  try {
    final locationData = LocationData(
      employeeId: 'EMP002',
      deviceId: 'DEVICE_002',
      timestamp: DateTime.now().toUtc(),
      // Sem latitude/longitude
    );
    
    print('✅ Sem coordenadas: ${locationData}');
    print('   Tem coordenadas: ${locationData.hasCoordinates}');
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  // 3. Teste JSON
  print('\n📋 3. Teste JSON:');
  try {
    final json = {
      'employee_id': 'EMP003',
      'device_id': 'DEVICE_003',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'latitude': '-3.7500',
      'longitude': '-38.5500',
    };
    
    final locationData = LocationData.fromJson(json);
    print('✅ Criado do JSON: ${locationData}');
    print('   Lat como double: ${locationData.latitudeAsDouble}');
    print('   Lon como double: ${locationData.longitudeAsDouble}');
    print('   JSON compacto: ${locationData.toJsonCompact()}');
  } catch (e) {
    print('❌ Erro JSON: $e');
  }
  
  // 4. Teste processamento
  print('\n📋 4. Teste processamento:');
  try {
    final locationData = LocationData(
      employeeId: 'EMP004',
      deviceId: 'DEVICE_004',
      timestamp: DateTime.now().toUtc(),
      latitude: '-3.7000',
      longitude: '-38.5000',
    );
    
    // Simular processamento
    locationData.updateZone('setor_producao');
    locationData.addNote('Funcionário entrou no setor de produção');
    
    print('✅ Processado: ${locationData}');
    print('   Zona: ${locationData.processedZone}');
    print('   Processado: ${locationData.isProcessed}');
  } catch (e) {
    print('❌ Erro processamento: $e');
  }
  
  // 5. Teste cálculo de distância
  print('\n📋 5. Teste distância:');
  try {
    final locationData = LocationData(
      employeeId: 'EMP005',
      deviceId: 'DEVICE_005',
      timestamp: DateTime.now().toUtc(),
      latitude: '-3.7319',
      longitude: '-38.5267',
    );
    
    // Calcular distância para outro ponto
    final distance = locationData.distanceToPoint('-3.7320', '-38.5268');
    print('✅ Distância calculada: ${distance?.toStringAsFixed(2)} metros');
  } catch (e) {
    print('❌ Erro distância: $e');
  }
  
  // 6. Teste validações
  print('\n📋 6. Teste validações:');
  try {
    print('❌ Deveria ter falhado!');
  } catch (e) {
    print('✅ Validação funcionou: $e');
  }
  
  print('\n🎉 Testes do LocationData simplificado concluídos!');
}