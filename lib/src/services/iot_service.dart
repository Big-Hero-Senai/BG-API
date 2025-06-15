// 📁 lib/src/services/iot_service.dart
// 🔧 CORRIGIDO: Imports e classe renomeada

import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import '../repositories/iot_repository_v3.dart';
import '../services/employee_service.dart';

// 🧠 SERVICE V2: Lógica inteligente com estrutura hierárquica otimizada
class IoTServiceV2 {
  static final _logger = Logger('IoTServiceV2');

  final IoTRepositoryV3 _iotRepository = IoTRepositoryV3();
  final EmployeeService _employeeService = EmployeeService();

  // 💓 PROCESSAR DADOS DE SAÚDE - ESTRUTURA OTIMIZADA
  Future<HealthData> processHealthDataV2(Map<String, dynamic> jsonData) async {
    try {
      _logger.info('💓 Processando dados de saúde V2 (otimizado)');

      // 🛡️ REGRA 1: Validar se funcionário existe
      final employeeId = jsonData['employee_id']?.toString();
      if (employeeId != null) {
        final employee = await _employeeService.getEmployeeById(employeeId);
        if (employee == null) {
          throw Exception('Funcionário $employeeId não encontrado');
        }
      }

      // 🛡️ REGRA 2: Criar e validar HealthData
      final healthData = HealthData.fromJson(jsonData);

      // 🛡️ REGRA 3: Verificar alertas críticos
      if (healthData.isCriticalAlert) {
        _logger.warning(
            '🚨 ALERTA CRÍTICO detectado para ${healthData.employeeId}');
        await _processHealthAlert(healthData);
      }

      // 🛡️ REGRA 4: Verificar bateria baixa do device
      if (healthData.batteryLevel != null && healthData.batteryLevel! < 20) {
        _logger.warning('🔋 Bateria baixa no device ${healthData.deviceId}');
        await _processBatteryAlert(healthData);
      }

      // ✅ SALVAR com estrutura V2 otimizada
      final saved = await _iotRepository.saveHealthData(healthData);

      _logger.info('✅ Dados de saúde V2 processados: ${saved.employeeId}');
      return saved;
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados de saúde V2: $e');
      rethrow;
    }
  }

  // 🗺️ PROCESSAR DADOS DE LOCALIZAÇÃO - LÓGICA INTELIGENTE
  Future<LocationData> processLocationDataV2(
      Map<String, dynamic> jsonData) async {
    try {
      _logger.info('🗺️ Processando dados de localização V2 (inteligente)');

      // 🛡️ REGRA 1: Validar se funcionário existe
      final employeeId = jsonData['employee_id']?.toString();
      if (employeeId != null) {
        final employee = await _employeeService.getEmployeeById(employeeId);
        if (employee == null) {
          throw Exception('Funcionário $employeeId não encontrado');
        }
      }

      // 🛡️ REGRA 2: Criar e validar LocationData
      final newLocationData = LocationData.fromJson(jsonData);

      // 🧠 LÓGICA INTELIGENTE: Verificar se deve salvar histórico
      await _processLocationIntelligently(newLocationData);

      // ✅ SEMPRE salvar como localização atual (sobrescreve)
      final saved = await _iotRepository.saveCurrentLocation(newLocationData);

      _logger.info('✅ Localização V2 processada: ${saved.employeeId}');
      return saved;
    } catch (e) {
      _logger.severe('❌ Erro ao processar localização V2: $e');
      rethrow;
    }
  }

  // 🧠 LÓGICA INTELIGENTE: Decidir se salva no histórico
  Future<void> _processLocationIntelligently(LocationData newLocation) async {
    try {
      // Buscar localização anterior
      final previousLocation =
          await _iotRepository.getCurrentLocation(newLocation.employeeId);

      if (previousLocation == null) {
        // Primeira localização - sempre salvar
        await _iotRepository.saveLocationHistory(newLocation, 'first_location');
        _logger.info('📍 Primeira localização salva no histórico');
        return;
      }

      // 🧠 DECISÕES INTELIGENTES:

      // 1. Verificar mudança de zona
      if (_zoneMudou(previousLocation, newLocation)) {
        await _iotRepository.saveLocationHistory(newLocation, 'zone_change');
        _logger.info('🗺️ Mudança de zona detectada - salvo no histórico');
        return;
      }

      // 2. Verificar distância significativa (> 50 metros)
      final distance = _calculateDistance(previousLocation, newLocation);
      if (distance != null && distance > 50.0) {
        await _iotRepository.saveLocationHistory(
            newLocation, 'significant_movement');
        _logger.info(
            '📏 Movimento significativo detectado: ${distance.toStringAsFixed(1)}m');
        return;
      }

      // 3. Verificar tempo desde última atualização (> 30 minutos)
      final timeDiff =
          newLocation.timestamp.difference(previousLocation.timestamp);
      if (timeDiff.inMinutes > 30) {
        await _iotRepository.saveLocationHistory(newLocation, 'time_interval');
        _logger.info(
            '⏰ Intervalo de tempo atingido: ${timeDiff.inMinutes} minutos');
        return;
      }

      // 4. Não salvar - mudança não significativa
      _logger.info('⏭️ Localização não significativa - só atualiza atual');
    } catch (e) {
      _logger.warning('⚠️ Erro na lógica inteligente: $e');
      // Em caso de erro, salvar mesmo assim para não perder dados
      await _iotRepository.saveLocationHistory(newLocation, 'error_fallback');
    }
  }

  // 📏 Calcular distância entre duas localizações
  double? _calculateDistance(LocationData loc1, LocationData loc2) {
    if (!loc1.hasValidCoordinates || !loc2.hasValidCoordinates) {
      return null;
    }

    try {
      final lat2 = double.parse(loc2.latitude!);
      final lon2 = double.parse(loc2.longitude!);

      // Usar método existente do LocationData
      return loc1.distanceToPoint(lat2.toString(), lon2.toString());
    } catch (e) {
      _logger.warning('⚠️ Erro ao calcular distância: $e');
      return null;
    }
  }

  // 🗺️ Verificar se mudou de zona
  bool _zoneMudou(LocationData previous, LocationData current) {
    final previousZone = previous.processedZone ?? _determineZone(previous);
    final currentZone = current.processedZone ?? _determineZone(current);

    if (previousZone != null && currentZone != null) {
      return previousZone != currentZone;
    }

    return false;
  }

  // 🗺️ Determinar zona baseada em coordenadas
  String? _determineZone(LocationData locationData) {
    if (!locationData.hasValidCoordinates) return null;

    try {
      final lat = double.parse(locationData.latitude!);
      final lon = double.parse(locationData.longitude!);

      // Zonas da fábrica SENAI (coordenadas fictícias)
      if (lat >= -3.7320 &&
          lat <= -3.7300 &&
          lon >= -38.5270 &&
          lon <= -38.5250) {
        return 'setor_producao';
      } else if (lat >= -3.7340 &&
          lat <= -3.7320 &&
          lon >= -38.5290 &&
          lon <= -38.5270) {
        return 'almoxarifado';
      } else if (lat >= -3.7300 &&
          lat <= -3.7280 &&
          lon >= -38.5250 &&
          lon <= -38.5230) {
        return 'administrativo';
      }

      return 'area_externa';
    } catch (e) {
      return null;
    }
  }

  // 🔍 BUSCAR DADOS - MÉTODOS OTIMIZADOS V2

  // Buscar últimos dados de saúde (V2 otimizado)
  Future<List<HealthData>> getLatestHealthDataV2(String employeeId,
      {int limit = 10}) async {
    try {
      return await _iotRepository.getHealthDataByEmployee(employeeId,
          limit: limit);
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde V2: $e');
      return [];
    }
  }

  // Buscar localização atual (V2 super rápido)
  Future<LocationData?> getCurrentLocationV2(String employeeId) async {
    try {
      return await _iotRepository.getCurrentLocation(employeeId);
    } catch (e) {
      _logger.severe('❌ Erro ao buscar localização atual V2: $e');
      return null;
    }
  }

  // Buscar todas as localizações atuais (V2 eficiente)
  Future<List<LocationData>> getAllCurrentLocationsV2() async {
    try {
      final locationsMap = await _iotRepository.getAllCurrentLocations();
      return locationsMap.values.toList();
    } catch (e) {
      _logger.severe('❌ Erro ao buscar todas localizações V2: $e');
      return [];
    }
  }

  // Buscar histórico de localização
  Future<List<LocationData>> getLocationHistoryV2(String employeeId,
      {int limit = 50}) async {
    try {
      return await _iotRepository.getLocationHistory(employeeId, limit: limit);
    } catch (e) {
      _logger.severe('❌ Erro ao buscar histórico de localização V2: $e');
      return [];
    }
  }

  // Estatísticas IoT V2 otimizadas
  Future<Map<String, dynamic>> getIoTStatisticsV2() async {
    try {
      _logger.info('📊 Gerando estatísticas IoT V2 (otimizadas)');

      final stats = <String, dynamic>{};

      // Estatísticas básicas
      stats['timestamp'] = DateTime.now().toUtc().toIso8601String();
      stats['version'] = 'V2';

      // Contadores eficientes
      final allLocations = await getAllCurrentLocationsV2();
      stats['active_employees'] = allLocations.length;

      // Distribuição por zonas
      final zoneDistribution = <String, int>{};
      for (final location in allLocations) {
        final zone =
            location.processedZone ?? _determineZone(location) ?? 'unknown';
        zoneDistribution[zone] = (zoneDistribution[zone] ?? 0) + 1;
      }
      stats['zone_distribution'] = zoneDistribution;

      // Alertas ativos (simplificado)
      stats['active_alerts'] = 0; // Implementar se necessário

      _logger.info('✅ Estatísticas V2 geradas');
      return stats;
    } catch (e) {
      _logger.severe('❌ Erro ao gerar estatísticas V2: $e');
      return {'error': e.toString()};
    }
  }

  // Teste de performance V1 vs V2
  Future<Map<String, dynamic>> performanceTest(String employeeId) async {
    try {
      _logger.info('🧪 Iniciando teste de performance V2 para $employeeId');

      final stopwatch = Stopwatch()..start();

      // Teste V2 - buscar dados de saúde
      final healthData = await getLatestHealthDataV2(employeeId, limit: 5);
      final healthTime = stopwatch.elapsedMilliseconds;

      stopwatch.reset();

      // Teste V2 - buscar localização atual
      final currentLocation = await getCurrentLocationV2(employeeId);
      final locationTime = stopwatch.elapsedMilliseconds;

      stopwatch.stop();

      return {
        'employee_id': employeeId,
        'version': 'V2',
        'health_data': {
          'count': healthData.length,
          'time_ms': healthTime,
        },
        'current_location': {
          'found': currentLocation != null,
          'time_ms': locationTime,
        },
        'total_time_ms': healthTime + locationTime,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };
    } catch (e) {
      _logger.severe('❌ Erro no teste de performance V2: $e');
      return {
        'error': e.toString(),
        'employee_id': employeeId,
        'version': 'V2',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };
    }
  }

  // 🚨 MÉTODOS DE ALERTA (implementações básicas)

  Future<void> _processHealthAlert(HealthData healthData) async {
    try {
      _logger.warning(
          '🚨 Processando alerta de saúde para ${healthData.employeeId}');

      // Implementar lógica de alerta de saúde
      // Por exemplo: notificar supervisores, criar registro de alerta, etc.

      _logger.info('✅ Alerta de saúde processado');
    } catch (e) {
      _logger.severe('❌ Erro ao processar alerta de saúde: $e');
    }
  }

  Future<void> _processBatteryAlert(HealthData healthData) async {
    try {
      _logger.warning(
          '🔋 Processando alerta de bateria para device ${healthData.deviceId}');

      // Implementar lógica de alerta de bateria
      // Por exemplo: notificar técnicos, agendar manutenção, etc.

      _logger.info('✅ Alerta de bateria processado');
    } catch (e) {
      _logger.severe('❌ Erro ao processar alerta de bateria: $e');
    }
  }

  // 🧹 LIMPEZA E DISPOSE
  void dispose() {
    _logger.info('🧹 Liberando recursos do IoTServiceV2');
    _iotRepository.dispose();
  }
}
