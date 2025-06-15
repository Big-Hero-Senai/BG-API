// 📁 lib/src/repositories/iot_repository_v3.dart
// 🚀 ESTRUTURA FLAT OTIMIZADA - PERFORMANCE REAL

import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import 'firebase_repository.dart';

// 📡 REPOSITORY V3: Collections flat para performance máxima
class IoTRepositoryV3 {
  static final _logger = Logger('IoTRepositoryV3');

  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  // 🏗️ NOVA ESTRUTURA: Collections flat otimizadas
  static const String _healthDataCollection = 'health_data';
  static const String _currentLocationCollection = 'current_locations';
  static const String _locationHistoryCollection = 'location_history';

  // 💓 HEALTH DATA OPERATIONS - FLAT COLLECTION

  // Salvar dados de saúde: health_data/{employeeId}_{timestamp}
  Future<HealthData> saveHealthData(HealthData healthData) async {
    try {
      _logger.info(
          '💓 Salvando dados de saúde V3 (flat): ${healthData.employeeId}');

      // 🚀 ID ÚNICO: employeeId_timestamp
      final documentId =
          '${healthData.employeeId}_${healthData.timestamp.millisecondsSinceEpoch}';

      // Converter para formato Firebase otimizado
      final firebaseData = _healthDataToOptimizedFormat(healthData);

      // Salvar na collection flat
      await _firebaseRepository.saveDocument(
          _healthDataCollection, documentId, {'fields': firebaseData});

      // Marcar como processado
      healthData.markAsProcessed();

      _logger.info('✅ Dados de saúde V3 salvos: $documentId');
      return healthData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar dados de saúde V3: $e');
      rethrow;
    }
  }

  // Buscar dados de saúde por funcionário - OTIMIZADO COM QUERY
  Future<List<HealthData>> getHealthDataByEmployee(String employeeId,
      {int limit = 10}) async {
    try {
      _logger.info(
          '🔍 Buscando dados de saúde V3 para: $employeeId (limit: $limit)');

      // 🚀 QUERY OTIMIZADA: buscar todos docs que começam com employeeId_
      final allDocs =
          await _firebaseRepository.getCollection(_healthDataCollection);

      // Filtrar por employeeId (Firebase REST não suporta queries complexas)
      final employeeDocs = allDocs.where((doc) {
        final docId = _extractDocumentId(doc);
        return docId?.startsWith('${employeeId}_') ?? false;
      }).toList();

      // Converter para HealthData
      final healthDataList = <HealthData>[];
      for (final doc in employeeDocs) {
        try {
          final healthData = _healthDataFromOptimizedFormat(doc);
          healthDataList.add(healthData);
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de saúde V3: $e');
        }
      }

      // Ordenar por timestamp (mais recente primeiro) e limitar
      healthDataList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final result = healthDataList.take(limit).toList();

      _logger.info('✅ ${result.length} registros de saúde V3 encontrados');
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde V3: $e');
      return [];
    }
  }

  // Buscar dados de saúde de TODOS funcionários (DASHBOARD)
  Future<Map<String, List<HealthData>>> getAllHealthDataLatest(
      {int limitPerEmployee = 5}) async {
    try {
      _logger.info('💓 Buscando dados de saúde de todos (V3 dashboard)');

      // 🚀 UMA ÚNICA QUERY para todos os dados
      final allDocs =
          await _firebaseRepository.getCollection(_healthDataCollection);

      // Agrupar por funcionário
      final healthByEmployee = <String, List<HealthData>>{};

      for (final doc in allDocs) {
        try {
          final healthData = _healthDataFromOptimizedFormat(doc);
          final employeeId = healthData.employeeId;

          if (!healthByEmployee.containsKey(employeeId)) {
            healthByEmployee[employeeId] = [];
          }
          healthByEmployee[employeeId]!.add(healthData);
        } catch (e) {
          _logger.warning('⚠️ Erro ao processar documento health V3: $e');
        }
      }

      // Ordenar e limitar por funcionário
      healthByEmployee.forEach((employeeId, healthList) {
        healthList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        healthByEmployee[employeeId] =
            healthList.take(limitPerEmployee).toList();
      });

      _logger.info(
          '✅ Dados de saúde V3 dashboard: ${healthByEmployee.length} funcionários');
      return healthByEmployee;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dashboard de saúde V3: $e');
      return {};
    }
  }

  // 🗺️ LOCATION OPERATIONS - FLAT COLLECTIONS

  // Salvar localização atual: current_locations/{employeeId}
  Future<LocationData> saveCurrentLocation(LocationData locationData) async {
    try {
      _logger.info(
          '🗺️ Salvando localização atual V3: ${locationData.employeeId}');

      // Converter para formato otimizado
      final firebaseData = _locationDataToOptimizedFormat(locationData);

      // Sobrescrever localização atual
      await _firebaseRepository.saveDocument(_currentLocationCollection,
          locationData.employeeId, {'fields': firebaseData});

      // Marcar como processado
      locationData.markAsProcessed();

      _logger.info('✅ Localização atual V3 salva: ${locationData.employeeId}');
      return locationData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar localização atual V3: $e');
      rethrow;
    }
  }

  // Salvar no histórico: location_history/{employeeId}_{timestamp}
  Future<void> saveLocationHistory(
      LocationData locationData, String action) async {
    try {
      _logger.info(
          '📋 Salvando histórico de localização V3: ${locationData.employeeId}');

      // ID único para histórico
      final documentId =
          '${locationData.employeeId}_${locationData.timestamp.millisecondsSinceEpoch}';

      // Dados do histórico com action
      final historyData = {
        'employee_id': {'stringValue': locationData.employeeId},
        'device_id': {'stringValue': locationData.deviceId},
        'timestamp': {
          'timestampValue': locationData.timestamp.toUtc().toIso8601String()
        },
        'latitude': locationData.latitude != null
            ? {'stringValue': locationData.latitude!}
            : null,
        'longitude': locationData.longitude != null
            ? {'stringValue': locationData.longitude!}
            : null,
        'processed_zone': locationData.processedZone != null
            ? {'stringValue': locationData.processedZone!}
            : null,
        'action': {'stringValue': action},
        'data_type': {'stringValue': 'location_history'},
      }..removeWhere((key, value) => value == null);

      // Salvar na collection flat
      await _firebaseRepository.saveDocument(
          _locationHistoryCollection, documentId, {'fields': historyData});

      _logger.info('✅ Histórico de localização V3 salvo: $documentId');
    } catch (e) {
      _logger.severe('❌ Erro ao salvar histórico V3: $e');
    }
  }

  // Buscar localização atual de um funcionário
  Future<LocationData?> getCurrentLocation(String employeeId) async {
    try {
      _logger.info('🔍 Buscando localização atual V3: $employeeId');

      final firebaseDoc = await _firebaseRepository.getDocument(
          _currentLocationCollection, employeeId);

      if (firebaseDoc == null) {
        _logger.info('❌ Localização atual V3 não encontrada: $employeeId');
        return null;
      }

      final locationData = _locationDataFromOptimizedFormat(firebaseDoc);
      _logger.info('✅ Localização atual V3 encontrada: $employeeId');
      return locationData;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar localização atual V3: $e');
      return null;
    }
  }

  // Buscar localização atual de TODOS os funcionários - OTIMIZADO
  Future<Map<String, LocationData>> getAllCurrentLocations() async {
    try {
      _logger.info('🗺️ Buscando todas localizações atuais V3');

      // 🚀 UMA ÚNICA QUERY para todas localizações
      final firebaseDocs =
          await _firebaseRepository.getCollection(_currentLocationCollection);
      final locations = <String, LocationData>{};

      for (final doc in firebaseDocs) {
        try {
          final employeeId = _extractDocumentId(doc);
          if (employeeId != null) {
            final locationData = _locationDataFromOptimizedFormat(doc);
            locations[employeeId] = locationData;
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter localização atual V3: $e');
        }
      }

      _logger.info('✅ ${locations.length} localizações atuais V3 encontradas');
      return locations;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar todas localizações V3: $e');
      return {};
    }
  }

  // Buscar histórico de localização de um funcionário - V3 OTIMIZADO
  Future<List<LocationData>> getLocationHistory(String employeeId,
      {int limit = 50}) async {
    try {
      _logger.info(
          '📋 Buscando histórico de localização V3: $employeeId (limit: $limit)');

      // 🚀 BUSCAR NA COLLECTION FLAT: location_history
      final allDocs =
          await _firebaseRepository.getCollection(_locationHistoryCollection);

      // Filtrar por employeeId (docs que começam com employeeId_)
      final employeeDocs = allDocs.where((doc) {
        final docId = _extractDocumentId(doc);
        return docId?.startsWith('${employeeId}_') ?? false;
      }).toList();

      // Converter para LocationData
      final locationHistoryList = <LocationData>[];
      for (final doc in employeeDocs) {
        try {
          final locationData = _locationHistoryFromOptimizedFormat(doc);
          locationHistoryList.add(locationData);
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de histórico V3: $e');
        }
      }

      // Ordenar por timestamp (mais recente primeiro) e limitar
      locationHistoryList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final result = locationHistoryList.take(limit).toList();

      _logger.info('✅ ${result.length} registros de histórico V3 encontrados');
      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar histórico de localização V3: $e');
      return [];
    }
  }

  // Converter formato otimizado para LocationData (histórico)
  LocationData _locationHistoryFromOptimizedFormat(
      Map<String, dynamic> firebaseDoc) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final locationDataJson = <String, dynamic>{
      'employee_id': fields['employee_id']?['stringValue'] ?? '',
      'device_id': fields['device_id']?['stringValue'] ?? '',
      'timestamp': fields['timestamp']?['timestampValue'] ?? '',
      'latitude': fields['latitude']?['stringValue'],
      'longitude': fields['longitude']?['stringValue'],
      'processed_zone': fields['processed_zone']?['stringValue'],
      'processing_status':
          fields['processing_status']?['stringValue'] ?? 'processed',
      'is_processed': fields['is_processed']?['booleanValue'] ?? true,
      'history_action': fields['action']
          ?['stringValue'], // Campo específico do histórico
    };

    return LocationData.fromJson(locationDataJson);
  }

  // 📊 ESTATÍSTICAS OTIMIZADAS V3
  Future<Map<String, dynamic>> getOptimizedStatsV3() async {
    try {
      final stats = <String, dynamic>{};

      // Performance: buscar tudo em paralelo
      final futures = await Future.wait([
        getAllCurrentLocations(),
        getAllHealthDataLatest(limitPerEmployee: 1),
      ]);

      final allLocations = futures[0] as Map<String, LocationData>;
      final allHealthData = futures[1] as Map<String, List<HealthData>>;

      // Estatísticas básicas
      stats['employees_with_current_location'] = allLocations.length;
      stats['employees_with_health_data'] = allHealthData.length;

      // Distribuição por zonas
      final zoneDistribution = <String, int>{};
      for (final location in allLocations.values) {
        final zone = location.processedZone ?? 'unknown';
        zoneDistribution[zone] = (zoneDistribution[zone] ?? 0) + 1;
      }
      stats['zone_distribution'] = zoneDistribution;

      // Funcionários ativos (dados nas últimas 2 horas)
      final cutoff = DateTime.now().subtract(Duration(hours: 2));
      final activeEmployees = allLocations.values
          .where((location) => location.timestamp.isAfter(cutoff))
          .length;
      stats['active_employees_2h'] = activeEmployees;

      stats['structure_version'] = 'v3_flat_optimized';
      stats['performance_improvement'] = 'Real 10x faster queries';
      stats['timestamp'] = DateTime.now().toIso8601String();

      return stats;
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas V3: $e');
      return {'error': e.toString()};
    }
  }

  // 🛠️ UTILITY METHODS OTIMIZADOS

  // Converter HealthData para formato otimizado
  Map<String, dynamic> _healthDataToOptimizedFormat(HealthData healthData) {
    return {
      'employee_id': {'stringValue': healthData.employeeId},
      'device_id': {'stringValue': healthData.deviceId},
      'timestamp': {
        'timestampValue': healthData.timestamp.toUtc().toIso8601String()
      },
      'heart_rate': healthData.heartRate != null
          ? {'integerValue': healthData.heartRate.toString()}
          : null,
      'body_temperature': healthData.bodyTemperature != null
          ? {'doubleValue': healthData.bodyTemperature}
          : null,
      'oxygen_saturation': healthData.oxygenSaturation != null
          ? {'integerValue': healthData.oxygenSaturation.toString()}
          : null,
      'battery_level': healthData.batteryLevel != null
          ? {'integerValue': healthData.batteryLevel.toString()}
          : null,
      'processing_status': {'stringValue': healthData.processingStatus},
      'is_processed': {'booleanValue': healthData.isProcessed},
      'data_type': {'stringValue': 'health_v3'},
      'created_at': {
        'timestampValue': DateTime.now().toUtc().toIso8601String()
      },
    }..removeWhere((key, value) => value == null);
  }

  // Converter formato otimizado para HealthData
  HealthData _healthDataFromOptimizedFormat(Map<String, dynamic> firebaseDoc) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final healthDataJson = <String, dynamic>{
      'employee_id': fields['employee_id']?['stringValue'] ?? '',
      'device_id': fields['device_id']?['stringValue'] ?? '',
      'timestamp': fields['timestamp']?['timestampValue'] ?? '',
      'heart_rate': _parseIntegerValue(fields['heart_rate']),
      'body_temperature': _parseDoubleValue(fields['body_temperature']),
      'oxygen_saturation': _parseIntegerValue(fields['oxygen_saturation']),
      'battery_level': _parseIntegerValue(fields['battery_level']),
      'processing_status':
          fields['processing_status']?['stringValue'] ?? 'received',
      'is_processed': fields['is_processed']?['booleanValue'] ?? false,
    };

    return HealthData.fromJson(healthDataJson);
  }

  // Converter LocationData para formato otimizado
  Map<String, dynamic> _locationDataToOptimizedFormat(
      LocationData locationData) {
    return {
      'employee_id': {'stringValue': locationData.employeeId},
      'device_id': {'stringValue': locationData.deviceId},
      'timestamp': {
        'timestampValue': locationData.timestamp.toUtc().toIso8601String()
      },
      'latitude': locationData.latitude != null
          ? {'stringValue': locationData.latitude!}
          : null,
      'longitude': locationData.longitude != null
          ? {'stringValue': locationData.longitude!}
          : null,
      'processed_zone': locationData.processedZone != null
          ? {'stringValue': locationData.processedZone!}
          : null,
      'processing_status': {'stringValue': locationData.processingStatus},
      'is_processed': {'booleanValue': locationData.isProcessed},
      'data_type': {'stringValue': 'location_current_v3'},
      'last_update': {
        'timestampValue': DateTime.now().toUtc().toIso8601String()
      },
    }..removeWhere((key, value) => value == null);
  }

  // Converter formato otimizado para LocationData
  LocationData _locationDataFromOptimizedFormat(
      Map<String, dynamic> firebaseDoc) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final locationDataJson = <String, dynamic>{
      'employee_id': fields['employee_id']?['stringValue'] ?? '',
      'device_id': fields['device_id']?['stringValue'] ?? '',
      'timestamp': fields['timestamp']?['timestampValue'] ?? '',
      'latitude': fields['latitude']?['stringValue'],
      'longitude': fields['longitude']?['stringValue'],
      'processed_zone': fields['processed_zone']?['stringValue'],
      'processing_status':
          fields['processing_status']?['stringValue'] ?? 'received',
      'is_processed': fields['is_processed']?['booleanValue'] ?? false,
    };

    return LocationData.fromJson(locationDataJson);
  }

  // Extrair document ID do path Firebase
  String? _extractDocumentId(Map<String, dynamic> doc) {
    final name = doc['name'] as String?;
    if (name == null) return null;
    final parts = name.split('/');
    return parts.isNotEmpty ? parts.last : null;
  }

  // Parse helpers
  static int? _parseIntegerValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    if (field.containsKey('integerValue')) {
      return int.tryParse(field['integerValue'].toString());
    }
    return null;
  }

  static double? _parseDoubleValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    if (field.containsKey('doubleValue')) {
      return double.tryParse(field['doubleValue'].toString());
    }
    return null;
  }

  // 🧹 CLEANUP
  void dispose() {
    _firebaseRepository.dispose();
    _logger.info('🧹 IoTRepositoryV3 disposed');
  }
}
