// 📁 lib/src/repositories/iot_repository.dart

import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import '../mappers/iot_mapper.dart';
import 'firebase_repository.dart';

// 📡 REPOSITORY: Persistência específica de dados IoT
class IoTRepository {
  static final _logger = Logger('IoTRepository');
  
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  
  // Coleções Firebase para dados IoT
  static const String _healthCollection = 'health_data';
  static const String _locationCollection = 'location_data';
  static const String _alertsCollection = 'alerts';
  
  // 💓 HEALTH DATA OPERATIONS
  
  // Salvar dados de saúde
  Future<HealthData> saveHealthData(HealthData healthData) async {
    try {
      _logger.info('💓 Salvando dados de saúde: ${healthData.employeeId}');
      
      // Gerar ID único para o registro IoT
      final docId = _generateIoTDocumentId('health', healthData);
      
      // Converter para formato Firebase
      final firebaseData = IoTMapper.healthDataToFirebase(healthData);
      
      // Salvar no Firebase
      await _firebaseRepository.saveDocument(_healthCollection, docId, firebaseData);
      
      // Marcar como processado
      healthData.markAsProcessed();
      
      _logger.info('✅ Dados de saúde salvos: $docId');
      return healthData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar dados de saúde: $e');
      rethrow;
    }
  }
  
  // Buscar dados de saúde por funcionário
  Future<List<HealthData>> getHealthDataByEmployee(String employeeId, {int limit = 10}) async {
    try {
      _logger.info('🔍 Buscando dados de saúde para: $employeeId');
      
      // Buscar todos os documentos da coleção
      final firebaseDocs = await _firebaseRepository.getCollection(_healthCollection);
      
      // Filtrar por employee_id e ordenar por timestamp (mais recente primeiro)
      final employeeHealthData = <HealthData>[];
      
      for (final doc in firebaseDocs) {
        try {
          final healthData = IoTMapper.healthDataFromFirebase(doc);
          if (healthData.employeeId == employeeId) {
            employeeHealthData.add(healthData);
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de saúde: $e');
        }
      }
      
      // Ordenar por timestamp (mais recente primeiro) e limitar
      employeeHealthData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final result = employeeHealthData.take(limit).toList();
      _logger.info('✅ ${result.length} registros de saúde encontrados');
      
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde: $e');
      rethrow;
    }
  }
  
  // Estatísticas de dados de saúde
  Future<Map<String, int>> getHealthDataStats() async {
    try {
      final firebaseDocs = await _firebaseRepository.getCollection(_healthCollection);
      
      int total = 0;
      int alertsCritical = 0;
      int batteryLow = 0;
      int last24h = 0;
      
      final yesterday = DateTime.now().subtract(Duration(hours: 24));
      
      for (final doc in firebaseDocs) {
        try {
          final healthData = IoTMapper.healthDataFromFirebase(doc);
          total++;
          
          if (healthData.isCriticalAlert) alertsCritical++;
          if (healthData.isLowBattery) batteryLow++;
          if (healthData.timestamp.isAfter(yesterday)) last24h++;
        } catch (e) {
          // Continua processando outros documentos
        }
      }
      
      return {
        'total_readings': total,
        'critical_alerts': alertsCritical,
        'low_battery_devices': batteryLow,
        'readings_24h': last24h,
      };
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas de saúde: $e');
      rethrow;
    }
  }
  
  // Contar registros de saúde por período
  Future<int> getHealthDataCount({int hours = 24}) async {
    try {
      final firebaseDocs = await _firebaseRepository.getCollection(_healthCollection);
      final cutoff = DateTime.now().subtract(Duration(hours: hours));
      
      int count = 0;
      for (final doc in firebaseDocs) {
        try {
          final healthData = IoTMapper.healthDataFromFirebase(doc);
          if (healthData.timestamp.isAfter(cutoff)) {
            count++;
          }
        } catch (e) {
          // Continua contando
        }
      }
      
      return count;
    } catch (e) {
      _logger.warning('⚠️ Erro ao contar dados de saúde: $e');
      return 0;
    }
  }
  
  // 🗺️ LOCATION DATA OPERATIONS
  
  // Salvar dados de localização
  Future<LocationData> saveLocationData(LocationData locationData) async {
    try {
      _logger.info('🗺️ Salvando dados de localização: ${locationData.employeeId}');
      
      // Gerar ID único para o registro IoT
      final docId = _generateIoTDocumentId('location', locationData);
      
      // Converter para formato Firebase
      final firebaseData = IoTMapper.locationDataToFirebase(locationData);
      
      // Salvar no Firebase
      await _firebaseRepository.saveDocument(_locationCollection, docId, firebaseData);
      
      // Marcar como processado
      locationData.markAsProcessed();
      
      _logger.info('✅ Dados de localização salvos: $docId');
      return locationData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar dados de localização: $e');
      rethrow;
    }
  }
  
  // Buscar dados de localização por funcionário
  Future<List<LocationData>> getLocationDataByEmployee(String employeeId, {int limit = 10}) async {
    try {
      _logger.info('🔍 Buscando dados de localização para: $employeeId');
      
      // Buscar todos os documentos da coleção
      final firebaseDocs = await _firebaseRepository.getCollection(_locationCollection);
      
      // Filtrar por employee_id
      final employeeLocationData = <LocationData>[];
      
      for (final doc in firebaseDocs) {
        try {
          final locationData = IoTMapper.locationDataFromFirebase(doc);
          if (locationData.employeeId == employeeId) {
            employeeLocationData.add(locationData);
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de localização: $e');
        }
      }
      
      // Ordenar por timestamp (mais recente primeiro) e limitar
      employeeLocationData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final result = employeeLocationData.take(limit).toList();
      _logger.info('✅ ${result.length} registros de localização encontrados');
      
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de localização: $e');
      rethrow;
    }
  }
  
  // Estatísticas de dados de localização
  Future<Map<String, int>> getLocationDataStats() async {
    try {
      final firebaseDocs = await _firebaseRepository.getCollection(_locationCollection);
      
      int total = 0;
      int withCoordinates = 0;
      int last24h = 0;
      final Map<String, int> zoneDistribution = {};
      
      final yesterday = DateTime.now().subtract(Duration(hours: 24));
      
      for (final doc in firebaseDocs) {
        try {
          final locationData = IoTMapper.locationDataFromFirebase(doc);
          total++;
          
          if (locationData.hasValidCoordinates) withCoordinates++;
          if (locationData.timestamp.isAfter(yesterday)) last24h++;
          
          // Contar distribuição por zona
          final zone = locationData.processedZone ?? 'unknown';
          zoneDistribution[zone] = (zoneDistribution[zone] ?? 0) + 1;
        } catch (e) {
          // Continua processando
        }
      }
      
      return {
        'total_readings': total,
        'with_coordinates': withCoordinates,
        'readings_24h': last24h,
        'zones': zoneDistribution.length,
      };
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas de localização: $e');
      rethrow;
    }
  }
  
  // Contar registros de localização por período
  Future<int> getLocationDataCount({int hours = 24}) async {
    try {
      final firebaseDocs = await _firebaseRepository.getCollection(_locationCollection);
      final cutoff = DateTime.now().subtract(Duration(hours: hours));
      
      int count = 0;
      for (final doc in firebaseDocs) {
        try {
          final locationData = IoTMapper.locationDataFromFirebase(doc);
          if (locationData.timestamp.isAfter(cutoff)) {
            count++;
          }
        } catch (e) {
          // Continua contando
        }
      }
      
      return count;
    } catch (e) {
      _logger.warning('⚠️ Erro ao contar dados de localização: $e');
      return 0;
    }
  }
  
  // 🚨 ALERTS OPERATIONS
  
  // Salvar alerta
  Future<void> saveAlert(Map<String, dynamic> alert) async {
    try {
      _logger.info('🚨 Salvando alerta: ${alert['type']}');
      
      // Gerar ID único para o alerta
      final alertId = '${alert['type']}_${alert['employee_id']}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Converter para formato Firebase
      final firebaseData = IoTMapper.alertToFirebase(alert);
      
      // Salvar no Firebase
      await _firebaseRepository.saveDocument(_alertsCollection, alertId, firebaseData);
      
      _logger.info('✅ Alerta salvo: $alertId');
    } catch (e) {
      _logger.severe('❌ Erro ao salvar alerta: $e');
      rethrow;
    }
  }
  
  // Buscar alertas ativos
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    try {
      _logger.info('🚨 Buscando alertas ativos');
      
      final firebaseDocs = await _firebaseRepository.getCollection(_alertsCollection);
      final activeAlerts = <Map<String, dynamic>>[];
      
      for (final doc in firebaseDocs) {
        try {
          final alert = IoTMapper.alertFromFirebase(doc);
          if (alert['status'] == 'active') {
            activeAlerts.add(alert);
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter alerta: $e');
        }
      }
      
      // Ordenar por timestamp (mais recente primeiro)
      activeAlerts.sort((a, b) {
        final timestampA = DateTime.parse(a['timestamp']);
        final timestampB = DateTime.parse(b['timestamp']);
        return timestampB.compareTo(timestampA);
      });
      
      _logger.info('✅ ${activeAlerts.length} alertas ativos encontrados');
      return activeAlerts;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar alertas ativos: $e');
      rethrow;
    }
  }
  
  // Contar alertas ativos
  Future<int> getActiveAlertsCount() async {
    try {
      final alerts = await getActiveAlerts();
      return alerts.length;
    } catch (e) {
      _logger.warning('⚠️ Erro ao contar alertas ativos: $e');
      return 0;
    }
  }
  
  // 📱 DEVICE OPERATIONS
  
  // Contar devices ativos (que enviaram dados nas últimas 2 horas)
  Future<int> getActiveDevicesCount() async {
    try {
      final cutoff = DateTime.now().subtract(Duration(hours: 2));
      final activeDevices = <String>{};
      
      // Verificar devices de saúde
      final healthDocs = await _firebaseRepository.getCollection(_healthCollection);
      for (final doc in healthDocs) {
        try {
          final healthData = IoTMapper.healthDataFromFirebase(doc);
          if (healthData.timestamp.isAfter(cutoff)) {
            activeDevices.add(healthData.deviceId);
          }
        } catch (e) {
          // Continua processando
        }
      }
      
      // Verificar devices de localização
      final locationDocs = await _firebaseRepository.getCollection(_locationCollection);
      for (final doc in locationDocs) {
        try {
          final locationData = IoTMapper.locationDataFromFirebase(doc);
          if (locationData.timestamp.isAfter(cutoff)) {
            activeDevices.add(locationData.deviceId);
          }
        } catch (e) {
          // Continua processando
        }
      }
      
      return activeDevices.length;
    } catch (e) {
      _logger.warning('⚠️ Erro ao contar devices ativos: $e');
      return 0;
    }
  }
  
  // 🔧 UTILITY METHODS
  
  // Gerar ID único para documentos IoT
  String _generateIoTDocumentId(String type, dynamic data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    if (data is HealthData) {
      return '${type}_${data.employeeId}_${data.deviceId}_$timestamp';
    } else if (data is LocationData) {
      return '${type}_${data.employeeId}_${data.deviceId}_$timestamp';
    }
    
    return '${type}_$timestamp';
  }
  
  // 🧹 CLEANUP
  void dispose() {
    _firebaseRepository.dispose();
    _logger.info('🧹 IoTRepository disposed');
  }
}

/*
🎓 CONCEITOS DO IOT REPOSITORY:

1. 📡 **IoT-Specific Collections**
   - health_data: dados de saúde
   - location_data: dados de localização  
   - alerts: sistema de alertas

2. 🔍 **Efficient Filtering**
   - Filtragem por employeeId
   - Ordenação por timestamp
   - Limitação de resultados

3. 📊 **Real-time Statistics**
   - Contadores por período
   - Distribuição por zonas
   - Devices ativos

4. 🚨 **Alert Management**
   - Persistência de alertas
   - Status tracking
   - Recuperação de alertas ativos

5. 🏷️ **Document ID Strategy**
   - IDs únicos com timestamp
   - Identificação por tipo
   - Rastreabilidade completa

6. 🛡️ **Error Resilience**
   - Continua processando mesmo com erros
   - Logs detalhados
   - Fallbacks para contadores
*/