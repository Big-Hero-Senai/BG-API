// 📁 lib/src/repositories/iot_repository_v2.dart
// 🔧 CORRIGIDO: Problema de path hierárquico no Firebase

import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import 'firebase_repository.dart';

// 📡 REPOSITORY V2: Estrutura hierárquica otimizada por funcionário
class IoTRepositoryV2 {
  static final _logger = Logger('IoTRepositoryV2');

  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  // 🏗️ NOVA ESTRUTURA: Coleções organizadas por funcionário
  static const String _healthDataCollection = 'health_data_v2';
  static const String _currentLocationCollection = 'current_location';
  static const String _locationHistoryCollection = 'location_history';

  // 💓 HEALTH DATA OPERATIONS - ESTRUTURA HIERÁRQUICA

  // 🔧 CORRIGIDO: Salvar dados de saúde com estrutura hierárquica
  Future<HealthData> saveHealthData(HealthData healthData) async {
    try {
      _logger.info('💓 Salvando dados de saúde V2: ${healthData.employeeId}');

      // 🔧 CORREÇÃO: Usar formato correto para subcoleção
      final timestamp =
          healthData.timestamp.toUtc().millisecondsSinceEpoch.toString();
      final firebaseData = _healthDataToFirebaseFormat(healthData);

      // 🏗️ CRIAR ESTRUTURA HIERÁRQUICA: health_data_v2 > EMP001 > timestamp
      // Primeiro, garantir que o documento do funcionário existe
      await _firebaseRepository
          .saveDocument(_healthDataCollection, healthData.employeeId, {
        'fields': {
          'employee_id': {'stringValue': healthData.employeeId}
        }
      });

      // Depois, salvar o registro de saúde como subcoleção
      final subcollectionPath =
          '$_healthDataCollection/${healthData.employeeId}/records';
      await _firebaseRepository
          .saveDocument(subcollectionPath, timestamp, {'fields': firebaseData});

      // Marcar como processado
      healthData.markAsProcessed();

      _logger.info('✅ Dados de saúde V2 salvos: $subcollectionPath/$timestamp');
      return healthData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar dados de saúde V2: $e');
      rethrow;
    }
  }

  // 🔧 CORRIGIDO: Buscar dados de saúde por funcionário
  Future<List<HealthData>> getHealthDataByEmployee(String employeeId,
      {int limit = 10}) async {
    try {
      _logger.info('🔍 Buscando dados de saúde V2 para: $employeeId');

      // 🔧 BUSCAR NA SUBCOLEÇÃO CORRETA
      final subcollectionPath = '$_healthDataCollection/$employeeId/records';
      final firebaseDocs =
          await _firebaseRepository.getCollection(subcollectionPath);

      // Converter documentos para HealthData
      final healthDataList = <HealthData>[];

      for (final doc in firebaseDocs) {
        try {
          final healthData = _healthDataFromFirebaseFormat(doc, employeeId);
          healthDataList.add(healthData);
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de saúde V2: $e');
        }
      }

      // Ordenar por timestamp (mais recente primeiro) e limitar
      healthDataList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final result = healthDataList.take(limit).toList();
      _logger.info('✅ ${result.length} registros de saúde V2 encontrados');

      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde V2: $e');
      return []; // Retornar lista vazia em caso de erro
    }
  }

  // 🗺️ LOCATION OPERATIONS - CURRENT + HISTORY (JÁ FUNCIONANDO)

  // Salvar localização atual: current_location/{employeeId}
  Future<LocationData> saveCurrentLocation(LocationData locationData) async {
    try {
      _logger
          .info('🗺️ Salvando localização atual: ${locationData.employeeId}');

      // Converter para formato Firebase
      final firebaseData = _locationDataToFirebaseFormat(locationData);

      // 🔄 SEMPRE SOBRESCREVER a localização atual
      await _firebaseRepository.saveDocument(_currentLocationCollection,
          locationData.employeeId, {'fields': firebaseData});

      // Marcar como processado
      locationData.markAsProcessed();

      _logger.info('✅ Localização atual salva: ${locationData.employeeId}');
      return locationData;
    } catch (e) {
      _logger.severe('❌ Erro ao salvar localização atual: $e');
      rethrow;
    }
  }

  // Buscar localização atual de um funcionário
  Future<LocationData?> getCurrentLocation(String employeeId) async {
    try {
      _logger.info('🔍 Buscando localização atual: $employeeId');

      final firebaseDoc = await _firebaseRepository.getDocument(
          _currentLocationCollection, employeeId);

      if (firebaseDoc == null) {
        _logger.info('❌ Localização atual não encontrada: $employeeId');
        return null;
      }

      final locationData =
          _locationDataFromFirebaseFormat(firebaseDoc, employeeId);
      _logger.info('✅ Localização atual encontrada: $employeeId');

      return locationData;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar localização atual: $e');
      return null;
    }
  }

  // Buscar localização atual de TODOS os funcionários
  Future<Map<String, LocationData>> getAllCurrentLocations() async {
    try {
      _logger.info('🗺️ Buscando localizações atuais de todos');

      final firebaseDocs =
          await _firebaseRepository.getCollection(_currentLocationCollection);
      final locations = <String, LocationData>{};

      for (final doc in firebaseDocs) {
        try {
          // Extrair employeeId do path do documento
          final employeeId = _extractEmployeeIdFromDoc(doc);
          if (employeeId != null) {
            final locationData =
                _locationDataFromFirebaseFormat(doc, employeeId);
            locations[employeeId] = locationData;
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter localização atual: $e');
        }
      }

      _logger.info('✅ ${locations.length} localizações atuais encontradas');
      return locations;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar todas localizações atuais: $e');
      return {};
    }
  }

  // 🔧 CORRIGIDO: Salvar movimento significativo no histórico
  Future<void> saveLocationHistory(
      LocationData locationData, String action) async {
    try {
      _logger.info(
          '📋 Salvando histórico de localização: ${locationData.employeeId}');

      // Só salvar se for mudança significativa
      if (!_isSignificantLocationChange(locationData, action)) {
        _logger.info('⏭️ Mudança não significativa, pulando histórico');
        return;
      }

      // 🔧 ESTRUTURA CORRIGIDA: location_history > EMP001 > records > timestamp
      final timestamp =
          locationData.timestamp.toUtc().millisecondsSinceEpoch.toString();

      // Primeiro, garantir que o documento do funcionário existe
      await _firebaseRepository
          .saveDocument(_locationHistoryCollection, locationData.employeeId, {
        'fields': {
          'employee_id': {'stringValue': locationData.employeeId}
        }
      });

      // Dados do histórico
      final historyData = {
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
        'device_id': {'stringValue': locationData.deviceId},
      }..removeWhere((key, value) => value == null);

      // Salvar na subcoleção
      final subcollectionPath =
          '$_locationHistoryCollection/${locationData.employeeId}/records';
      await _firebaseRepository
          .saveDocument(subcollectionPath, timestamp, {'fields': historyData});

      _logger.info('✅ Histórico de localização salvo');
    } catch (e) {
      _logger.severe('❌ Erro ao salvar histórico de localização: $e');
      // Não relançar para não quebrar o fluxo principal
    }
  }

  // 🔧 CORRIGIDO: Buscar histórico de localização de um funcionário
  Future<List<LocationData>> getLocationHistory(String employeeId,
      {int limit = 50}) async {
    try {
      _logger.info('📋 Buscando histórico de localização V2: $employeeId');

      // 🔧 BUSCAR NA SUBCOLEÇÃO CORRETA
      final subcollectionPath =
          '$_locationHistoryCollection/$employeeId/records';
      final firebaseDocs =
          await _firebaseRepository.getCollection(subcollectionPath);

      // Converter documentos para LocationData
      final locationHistoryList = <LocationData>[];

      for (final doc in firebaseDocs) {
        try {
          final locationData =
              _locationHistoryFromFirebaseFormat(doc, employeeId);
          locationHistoryList.add(locationData);
        } catch (e) {
          _logger.warning('⚠️ Erro ao converter documento de histórico V2: $e');
        }
      }

      // Ordenar por timestamp (mais recente primeiro) e limitar
      locationHistoryList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final result = locationHistoryList.take(limit).toList();
      _logger.info('✅ ${result.length} registros de histórico V2 encontrados');

      return result;
    } catch (e) {
      _logger.severe('❌ Erro ao buscar histórico de localização V2: $e');
      return [];
    }
  }

  // 📊 ESTATÍSTICAS OTIMIZADAS

  Future<Map<String, int>> getHealthDataCountsByEmployee() async {
    try {
      final counts = <String, int>{};

      // Buscar funcionários que têm dados de saúde
      final employeeDocs =
          await _firebaseRepository.getCollection(_healthDataCollection);

      for (final employeeDoc in employeeDocs) {
        try {
          final employeeId = _extractEmployeeIdFromDoc(employeeDoc);
          if (employeeId != null) {
            final subcollectionPath =
                '$_healthDataCollection/$employeeId/records';
            final healthDocs =
                await _firebaseRepository.getCollection(subcollectionPath);
            counts[employeeId] = healthDocs.length;
          }
        } catch (e) {
          _logger.warning('⚠️ Erro ao contar dados de saúde: $e');
        }
      }

      return counts;
    } catch (e) {
      _logger.severe('❌ Erro ao contar registros por funcionário: $e');
      return {};
    }
  }

  // Estatísticas gerais V2
  Future<Map<String, dynamic>> getOptimizedStats() async {
    try {
      final stats = <String, dynamic>{};

      // Contar funcionários com localização atual
      final currentLocations = await getAllCurrentLocations();
      stats['employees_with_current_location'] = currentLocations.length;

      // Contar total de registros de saúde por funcionário
      final healthCounts = await getHealthDataCountsByEmployee();
      stats['health_data_by_employee'] = healthCounts;
      stats['total_health_records'] =
          healthCounts.values.fold(0, (sum, count) => sum + count);

      // Funcionários ativos (dados nas últimas 2 horas)
      final cutoff = DateTime.now().subtract(Duration(hours: 2));
      final activeEmployees = currentLocations.entries
          .where((entry) => entry.value.timestamp.isAfter(cutoff))
          .length;
      stats['active_employees_2h'] = activeEmployees;

      stats['structure_version'] = 'v2_hierarchical_fixed';
      stats['timestamp'] = DateTime.now().toIso8601String();

      return stats;
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas otimizadas: $e');
      return {'error': e.toString()};
    }
  }

  // 🛠️ UTILITY METHODS CORRIGIDOS

  // 🔧 CORRIGIDO: Converter HealthData para formato Firebase
  Map<String, dynamic> _healthDataToFirebaseFormat(HealthData healthData) {
    return {
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
      'data_type': {'stringValue': 'health_v2'},
    }..removeWhere((key, value) => value == null);
  }

  // 🔧 CORRIGIDO: Converter formato Firebase para HealthData
  HealthData _healthDataFromFirebaseFormat(
      Map<String, dynamic> firebaseDoc, String employeeId) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final healthDataJson = <String, dynamic>{
      'employee_id': employeeId, // Vem do path, não do documento
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

  // Converter LocationData para formato Firebase
  Map<String, dynamic> _locationDataToFirebaseFormat(
      LocationData locationData) {
    return {
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
      'last_update': {
        'timestampValue': DateTime.now().toUtc().toIso8601String()
      },
      'data_type': {'stringValue': 'location_current'},
    }..removeWhere((key, value) => value == null);
  }

  // Converter formato Firebase para LocationData
  LocationData _locationDataFromFirebaseFormat(
      Map<String, dynamic> firebaseDoc, String employeeId) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final locationDataJson = <String, dynamic>{
      'employee_id': employeeId, // Vem do path
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

  // Converter formato Firebase para LocationData (histórico)
  LocationData _locationHistoryFromFirebaseFormat(
      Map<String, dynamic> firebaseDoc, String employeeId) {
    final fields = firebaseDoc['fields'] as Map<String, dynamic>;

    final locationDataJson = <String, dynamic>{
      'employee_id': employeeId, // Vem do path
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

  // Extrair employeeId do path do documento Firebase
  String? _extractEmployeeIdFromDoc(Map<String, dynamic> doc) {
    final name = doc['name'] as String?;
    if (name == null) return null;

    // Firebase path: "projects/.../documents/collection/EMP001"
    final parts = name.split('/');
    return parts.isNotEmpty ? parts.last : null;
  }

  // Verificar se é mudança significativa de localização
  bool _isSignificantLocationChange(LocationData locationData, String action) {
    // Por enquanto, salvar todas - no futuro, adicionar lógica de distância
    return action == 'zone_change' ||
        action == 'significant_movement' ||
        action == 'first_location';
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
    _logger.info('🧹 IoTRepositoryV2 disposed');
  }
}
