// 📁 lib/src/services/iot_service.dart

import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import '../repositories/iot_repository.dart';
import '../services/employee_service.dart';

// 🧠 SERVICE: Regras de negócio para dados IoT
class IoTService {
  static final _logger = Logger('IoTService');
  
  final IoTRepository _iotRepository = IoTRepository();
  final EmployeeService _employeeService = EmployeeService();
  
  // 💓 PROCESSAR DADOS DE SAÚDE
  Future<HealthData> processHealthData(Map<String, dynamic> jsonData) async {
    try {
      _logger.info('💓 Processando dados de saúde IoT');
      
      // 🛡️ REGRA 1: Validar se funcionário existe
      final employeeId = jsonData['employee_id']?.toString();
      if (employeeId != null) {
        final employee = await _employeeService.getEmployeeById(employeeId);
        if (employee == null) {
          throw EmployeeNotFoundException('Funcionário $employeeId não encontrado');
        }
      }
      
      // 🛡️ REGRA 2: Criar e validar HealthData
      final healthData = HealthData.fromJson(jsonData);
      
      // 🛡️ REGRA 3: Verificar alertas críticos
      if (healthData.isCriticalAlert) {
        _logger.warning('🚨 ALERTA CRÍTICO detectado para ${healthData.employeeId}');
        await _processHealthAlert(healthData);
      }
      
      // 🛡️ REGRA 4: Verificar bateria baixa do device
      if (healthData.isLowBattery) {
        _logger.warning('🔋 Bateria baixa no device ${healthData.deviceId}');
        await _processBatteryAlert(healthData);
      }
      
      // ✅ SALVAR no repository
      final saved = await _iotRepository.saveHealthData(healthData);
      
      // 📊 REGRA 5: Atualizar estatísticas em tempo real
      await _updateHealthStatistics(saved);
      
      _logger.info('✅ Dados de saúde processados: ${saved.employeeId}');
      return saved;
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados de saúde: $e');
      rethrow;
    }
  }
  
  // 🗺️ PROCESSAR DADOS DE LOCALIZAÇÃO
  Future<LocationData> processLocationData(Map<String, dynamic> jsonData) async {
    try {
      _logger.info('🗺️ Processando dados de localização IoT');
      
      // 🛡️ REGRA 1: Validar se funcionário existe
      final employeeId = jsonData['employee_id']?.toString();
      if (employeeId != null) {
        final employee = await _employeeService.getEmployeeById(employeeId);
        if (employee == null) {
          throw EmployeeNotFoundException('Funcionário $employeeId não encontrado');
        }
      }
      
      // 🛡️ REGRA 2: Criar e validar LocationData
      final locationData = LocationData.fromJson(jsonData);
      
      // 🛡️ REGRA 3: Processar zona/setor baseado nas coordenadas
      if (locationData.hasValidCoordinates) {
        final zone = await _determineZoneFromCoordinates(locationData);
        if (zone != null) {
          locationData.updateZone(zone);
        }
      }
      
      // 🛡️ REGRA 4: Verificar se está em zona de segurança
      await _checkSafetyZone(locationData);
      
      // ✅ SALVAR no repository
      final saved = await _iotRepository.saveLocationData(locationData);
      
      // 📊 REGRA 5: Atualizar estatísticas de localização
      await _updateLocationStatistics(saved);
      
      _logger.info('✅ Dados de localização processados: ${saved.employeeId}');
      return saved;
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados de localização: $e');
      rethrow;
    }
  }
  
  // 📊 PROCESSAR DADOS EM LOTE
  Future<Map<String, dynamic>> processBatchData(List<dynamic> jsonArray) async {
    try {
      _logger.info('📊 Processando ${jsonArray.length} itens em lote');
      
      int processed = 0;
      int errors = 0;
      final List<String> errorMessages = [];
      
      for (final item in jsonArray) {
        try {
          if (item is! Map<String, dynamic>) {
            throw ArgumentError('Item deve ser um objeto JSON');
          }
          
          final dataType = item['data_type']?.toString();
          
          switch (dataType) {
            case 'health':
              await processHealthData(item);
              break;
            case 'location':
              await processLocationData(item);
              break;
            default:
              // Tentar detectar automaticamente pelo conteúdo
              if (item.containsKey('heart_rate') || item.containsKey('body_temperature')) {
                await processHealthData(item);
              } else if (item.containsKey('latitude') || item.containsKey('longitude')) {
                await processLocationData(item);
              } else {
                throw ArgumentError('Tipo de dados não identificado');
              }
          }
          
          processed++;
        } catch (e) {
          errors++;
          errorMessages.add('Item ${jsonArray.indexOf(item)}: $e');
          _logger.warning('⚠️ Erro no item ${jsonArray.indexOf(item)}: $e');
        }
      }
      
      final result = {
        'total': jsonArray.length,
        'processed': processed,
        'errors': errors,
        'success_rate': processed / jsonArray.length,
        'error_messages': errorMessages,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _logger.info('📊 Lote processado: $processed/$processed+$errors');
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao processar lote: $e');
      rethrow;
    }
  }
  
  // 🔍 BUSCAR ÚLTIMOS DADOS DE SAÚDE
  Future<List<HealthData>> getLatestHealthData(String employeeId, {int limit = 10}) async {
    try {
      return await _iotRepository.getHealthDataByEmployee(employeeId, limit: limit);
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde: $e');
      rethrow;
    }
  }
  
  // 🗺️ BUSCAR ÚLTIMOS DADOS DE LOCALIZAÇÃO
  Future<List<LocationData>> getLatestLocationData(String employeeId, {int limit = 10}) async {
    try {
      return await _iotRepository.getLocationDataByEmployee(employeeId, limit: limit);
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de localização: $e');
      rethrow;
    }
  }
  
  // 📊 ESTATÍSTICAS IoT
  Future<Map<String, dynamic>> getIoTStatistics() async {
    try {
      _logger.info('📊 Calculando estatísticas IoT');
      
      final healthStats = await _iotRepository.getHealthDataStats();
      final locationStats = await _iotRepository.getLocationDataStats();
      final alerts = await _iotRepository.getActiveAlertsCount();
      
      final stats = {
        'health_data': healthStats,
        'location_data': locationStats,
        'active_alerts': alerts,
        'devices_active': await _getActiveDevicesCount(),
        'last_24h': {
          'health_readings': await _iotRepository.getHealthDataCount(hours: 24),
          'location_readings': await _iotRepository.getLocationDataCount(hours: 24),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      return stats;
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas IoT: $e');
      rethrow;
    }
  }
  
  // 🚨 BUSCAR ALERTAS ATIVOS
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    try {
      return await _iotRepository.getActiveAlerts();
    } catch (e) {
      _logger.severe('❌ Erro ao buscar alertas ativos: $e');
      rethrow;
    }
  }
  
  // 🛡️ MÉTODOS PRIVADOS DE REGRAS DE NEGÓCIO
  
  // 🚨 Processar alerta de saúde crítico
  Future<void> _processHealthAlert(HealthData healthData) async {
    final alert = {
      'type': 'health_critical',
      'employee_id': healthData.employeeId,
      'device_id': healthData.deviceId,
      'details': {
        'heart_rate': healthData.heartRate,
        'body_temperature': healthData.bodyTemperature,
        'oxygen_saturation': healthData.oxygenSaturation,
      },
      'severity': 'high',
      'timestamp': healthData.timestamp.toIso8601String(),
      'status': 'active',
    };
    
    await _iotRepository.saveAlert(alert);
    
    // TODO: Enviar notificação para equipe médica
    _logger.warning('🚨 Alerta crítico criado para ${healthData.employeeId}');
  }
  
  // 🔋 Processar alerta de bateria baixa
  Future<void> _processBatteryAlert(HealthData healthData) async {
    final alert = {
      'type': 'battery_low',
      'employee_id': healthData.employeeId,
      'device_id': healthData.deviceId,
      'battery_level': healthData.batteryLevel,
      'severity': 'medium',
      'timestamp': healthData.timestamp.toIso8601String(),
      'status': 'active',
    };
    
    await _iotRepository.saveAlert(alert);
  }
  
  // 🗺️ Determinar zona baseada em coordenadas
  Future<String?> _determineZoneFromCoordinates(LocationData locationData) async {
    // 📍 REGRA DE NEGÓCIO: Mapear coordenadas para setores da fábrica
    // Exemplo simplificado - em produção seria mais complexo
    
    final lat = locationData.latitudeAsDouble;
    final lon = locationData.longitudeAsDouble;
    
    if (lat == null || lon == null) return null;
    
    // Exemplo de zonas da fábrica SENAI (coordenadas fictícias)
    if (lat >= -3.7320 && lat <= -3.7300 && lon >= -38.5270 && lon <= -38.5250) {
      return 'setor_producao';
    } else if (lat >= -3.7340 && lat <= -3.7320 && lon >= -38.5290 && lon <= -38.5270) {
      return 'almoxarifado';
    } else if (lat >= -3.7300 && lat <= -3.7280 && lon >= -38.5250 && lon <= -38.5230) {
      return 'administrativo';
    }
    
    return 'area_externa';
  }
  
  // 🛡️ Verificar zona de segurança
  Future<void> _checkSafetyZone(LocationData locationData) async {
    final zone = locationData.processedZone;
    
    // REGRA: Algumas zonas são restritas ou perigosas
    if (zone != null) {
      if (zone.contains('perigo') || zone.contains('restrito')) {
        locationData.alertLevel = 'danger';
        
        final alert = {
          'type': 'unsafe_zone',
          'employee_id': locationData.employeeId,
          'zone': zone,
          'coordinates': locationData.coordinatesDisplay,
          'severity': 'high',
          'timestamp': locationData.timestamp.toIso8601String(),
          'status': 'active',
        };
        
        await _iotRepository.saveAlert(alert);
      }
    }
  }
  
  // 📊 Atualizar estatísticas de saúde
  Future<void> _updateHealthStatistics(HealthData healthData) async {
    // Aqui poderiamos atualizar métricas em tempo real
    // Por exemplo: média de batimentos por setor, tendências, etc.
  }
  
  // 📊 Atualizar estatísticas de localização
  Future<void> _updateLocationStatistics(LocationData locationData) async {
    // Aqui poderiamos atualizar heat maps, zonas mais visitadas, etc.
  }
  
  // 📱 Contar devices ativos
  Future<int> _getActiveDevicesCount() async {
    try {
      return await _iotRepository.getActiveDevicesCount();
    } catch (e) {
      _logger.warning('⚠️ Erro ao contar devices ativos: $e');
      return 0;
    }
  }
  
  // 🧹 CLEANUP
  void dispose() {
    _iotRepository.dispose();
    _logger.info('🧹 IoTService disposed');
  }
}

// 🚨 EXCEPTIONS específicas de IoT
class EmployeeNotFoundException implements Exception {
  final String message;
  EmployeeNotFoundException(this.message);
  
  @override
  String toString() => 'EmployeeNotFoundException: $message';
}

class DeviceNotFoundException implements Exception {
  final String message;
  DeviceNotFoundException(this.message);
  
  @override
  String toString() => 'DeviceNotFoundException: $message';
}

/*
🎓 CONCEITOS DO IOT SERVICE:

1. 🧠 **Business Rules for IoT**
   - Validação de employee existe
   - Processamento de zonas geográficas
   - Sistema de alertas automático

2. 🛡️ **Real-time Safety**
   - Detecção de alertas críticos
   - Zonas de segurança
   - Notificações automáticas

3. 📊 **Batch Processing**
   - Processamento eficiente em lote
   - Error handling individual
   - Estatísticas de sucesso

4. 🔍 **Data Intelligence**
   - Mapeamento coordenadas → zonas
   - Análise de padrões
   - Métricas em tempo real

5. 🚨 **Alert System**
   - Alertas de saúde críticos
   - Zonas perigosas
   - Bateria baixa

6. 📈 **Analytics Integration**
   - Estatísticas agregadas
   - Contadores em tempo real
   - Historical data analysis
*/