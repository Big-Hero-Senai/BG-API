// 📁 lib/src/mappers/iot_mapper.dart

import '../models/health_data.dart';
import '../models/location_data.dart';

// 🔄 MAPPER: Conversões IoT ↔ Firebase Format
class IoTMapper {
  
  // 💓 HEALTH DATA CONVERSIONS
  
  // HealthData → Firebase Format
  static Map<String, dynamic> healthDataToFirebase(HealthData healthData) {
    return {
      'fields': {
        // 🔒 Dados imutáveis
        'employee_id': {'stringValue': healthData.employeeId},
        'device_id': {'stringValue': healthData.deviceId},
        'timestamp': {'timestampValue': healthData.timestamp.toUtc().toIso8601String()},
        'heart_rate': healthData.heartRate != null 
            ? {'integerValue': healthData.heartRate.toString()} 
            : null,
        'body_temperature': healthData.bodyTemperature != null 
            ? {'doubleValue': healthData.bodyTemperature} 
            : null,
        'blood_pressure_systolic': healthData.bloodPressure?.systolic != null 
            ? {'integerValue': healthData.bloodPressure!.systolic.toString()} 
            : null,
        'blood_pressure_diastolic': healthData.bloodPressure?.diastolic != null 
            ? {'integerValue': healthData.bloodPressure!.diastolic.toString()} 
            : null,
        'oxygen_saturation': healthData.oxygenSaturation != null 
            ? {'integerValue': healthData.oxygenSaturation.toString()} 
            : null,
        'stress_level': healthData.stressLevel != null 
            ? {'integerValue': healthData.stressLevel.toString()} 
            : null,
        'activity': healthData.activity != null 
            ? {'stringValue': healthData.activity!.name} 
            : null,
        'battery_level': healthData.batteryLevel != null 
            ? {'integerValue': healthData.batteryLevel.toString()} 
            : null,
        'signal_strength': healthData.signalStrength != null 
            ? {'stringValue': healthData.signalStrength!} 
            : null,
        // 🔄 Dados mutáveis
        'processing_status': {'stringValue': healthData.processingStatus},
        'is_processed': {'booleanValue': healthData.isProcessed},
        'alert_level': healthData.alertLevel != null 
            ? {'stringValue': healthData.alertLevel!} 
            : null,
        'processed_at': healthData.processedAt != null 
            ? {'timestampValue': healthData.processedAt!.toUtc().toIso8601String()} 
            : null,
        'notes': healthData.notes != null 
            ? {'stringValue': healthData.notes!} 
            : null,
        // Metadados
        'data_type': {'stringValue': 'health'},
        'created_at': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }..removeWhere((key, value) => value == null), // Remove campos null
    };
  }
  
  // Firebase Format → HealthData
  static HealthData healthDataFromFirebase(Map<String, dynamic> firebaseDoc) {
    try {
      final fields = firebaseDoc['fields'] as Map<String, dynamic>;
      
      // Extrair dados para o modelo
      final healthDataJson = <String, dynamic>{
        'employee_id': fields['employee_id']?['stringValue'] ?? '',
        'device_id': fields['device_id']?['stringValue'] ?? '',
        'timestamp': fields['timestamp']?['timestampValue'] ?? '',
        'heart_rate': _parseIntegerValue(fields['heart_rate']),
        'body_temperature': _parseDoubleValue(fields['body_temperature']),
        'oxygen_saturation': _parseIntegerValue(fields['oxygen_saturation']),
        'stress_level': _parseIntegerValue(fields['stress_level']),
        'activity': fields['activity']?['stringValue'],
        'battery_level': _parseIntegerValue(fields['battery_level']),
        'signal_strength': fields['signal_strength']?['stringValue'],
        'processing_status': fields['processing_status']?['stringValue'] ?? 'received',
        'is_processed': fields['is_processed']?['booleanValue'] ?? false,
        'alert_level': fields['alert_level']?['stringValue'],
        'processed_at': fields['processed_at']?['timestampValue'],
        'notes': fields['notes']?['stringValue'],
      };
      
      // Construir blood_pressure se existir
      final systolic = _parseIntegerValue(fields['blood_pressure_systolic']);
      final diastolic = _parseIntegerValue(fields['blood_pressure_diastolic']);
      if (systolic != null && diastolic != null) {
        healthDataJson['blood_pressure'] = {
          'systolic': systolic,
          'diastolic': diastolic,
        };
      }
      
      return HealthData.fromJson(healthDataJson);
    } catch (e) {
      throw FormatException('Erro ao converter documento Firebase para HealthData: $e');
    }
  }
  
  // 🗺️ LOCATION DATA CONVERSIONS
  
  // LocationData → Firebase Format
  static Map<String, dynamic> locationDataToFirebase(LocationData locationData) {
    return {
      'fields': {
        // 🔒 Dados imutáveis
        'employee_id': {'stringValue': locationData.employeeId},
        'device_id': {'stringValue': locationData.deviceId},
        'timestamp': {'timestampValue': locationData.timestamp.toUtc().toIso8601String()},
        'latitude': locationData.latitude != null 
            ? {'stringValue': locationData.latitude!} 
            : null,
        'longitude': locationData.longitude != null 
            ? {'stringValue': locationData.longitude!} 
            : null,
        // 🔄 Dados mutáveis
        'processing_status': {'stringValue': locationData.processingStatus},
        'is_processed': {'booleanValue': locationData.isProcessed},
        'processed_zone': locationData.processedZone != null 
            ? {'stringValue': locationData.processedZone!} 
            : null,
        'alert_level': locationData.alertLevel != null 
            ? {'stringValue': locationData.alertLevel!} 
            : null,
        'processed_at': locationData.processedAt != null 
            ? {'timestampValue': locationData.processedAt!.toUtc().toIso8601String()} 
            : null,
        'notes': locationData.notes != null 
            ? {'stringValue': locationData.notes!} 
            : null,
        // Metadados
        'data_type': {'stringValue': 'location'},
        'created_at': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }..removeWhere((key, value) => value == null), // Remove campos null
    };
  }
  
  // Firebase Format → LocationData
  static LocationData locationDataFromFirebase(Map<String, dynamic> firebaseDoc) {
    try {
      final fields = firebaseDoc['fields'] as Map<String, dynamic>;
      
      // Extrair dados para o modelo
      final locationDataJson = <String, dynamic>{
        'employee_id': fields['employee_id']?['stringValue'] ?? '',
        'device_id': fields['device_id']?['stringValue'] ?? '',
        'timestamp': fields['timestamp']?['timestampValue'] ?? '',
        'latitude': fields['latitude']?['stringValue'],
        'longitude': fields['longitude']?['stringValue'],
        'processing_status': fields['processing_status']?['stringValue'] ?? 'received',
        'is_processed': fields['is_processed']?['booleanValue'] ?? false,
        'processed_zone': fields['processed_zone']?['stringValue'],
        'alert_level': fields['alert_level']?['stringValue'],
        'processed_at': fields['processed_at']?['timestampValue'],
        'notes': fields['notes']?['stringValue'],
      };
      
      return LocationData.fromJson(locationDataJson);
    } catch (e) {
      throw FormatException('Erro ao converter documento Firebase para LocationData: $e');
    }
  }
  
  // 🚨 ALERT CONVERSIONS
  
  // Alert → Firebase Format
  static Map<String, dynamic> alertToFirebase(Map<String, dynamic> alert) {
    return {
      'fields': {
        'type': {'stringValue': alert['type'] ?? ''},
        'employee_id': {'stringValue': alert['employee_id'] ?? ''},
        'device_id': alert['device_id'] != null 
            ? {'stringValue': alert['device_id']} 
            : null,
        'severity': {'stringValue': alert['severity'] ?? 'medium'},
        'status': {'stringValue': alert['status'] ?? 'active'},
        'timestamp': {'timestampValue': alert['timestamp'] ?? DateTime.now().toUtc().toIso8601String()},
        'details': alert['details'] != null 
            ? {'stringValue': alert['details'].toString()} 
            : null,
        'zone': alert['zone'] != null 
            ? {'stringValue': alert['zone']} 
            : null,
        'coordinates': alert['coordinates'] != null 
            ? {'stringValue': alert['coordinates']} 
            : null,
        'battery_level': alert['battery_level'] != null 
            ? {'integerValue': alert['battery_level'].toString()} 
            : null,
        'created_at': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }..removeWhere((key, value) => value == null),
    };
  }
  
  // Firebase Format → Alert
  static Map<String, dynamic> alertFromFirebase(Map<String, dynamic> firebaseDoc) {
    try {
      final fields = firebaseDoc['fields'] as Map<String, dynamic>;
      
      return {
        'type': fields['type']?['stringValue'] ?? '',
        'employee_id': fields['employee_id']?['stringValue'] ?? '',
        'device_id': fields['device_id']?['stringValue'],
        'severity': fields['severity']?['stringValue'] ?? 'medium',
        'status': fields['status']?['stringValue'] ?? 'active',
        'timestamp': fields['timestamp']?['timestampValue'] ?? DateTime.now().toIso8601String(),
        'details': fields['details']?['stringValue'],
        'zone': fields['zone']?['stringValue'],
        'coordinates': fields['coordinates']?['stringValue'],
        'battery_level': _parseIntegerValue(fields['battery_level']),
        'created_at': fields['created_at']?['timestampValue'],
      };
    } catch (e) {
      throw FormatException('Erro ao converter documento Firebase para Alert: $e');
    }
  }
  
  // 🛠️ UTILITY METHODS
  
  // Parse integer values do Firebase
  static int? _parseIntegerValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    
    if (field.containsKey('integerValue')) {
      return int.tryParse(field['integerValue'].toString());
    }
    
    return null;
  }
  
  // Parse double values do Firebase
  static double? _parseDoubleValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    
    if (field.containsKey('doubleValue')) {
      return double.tryParse(field['doubleValue'].toString());
    }
    
    return null;
  }
}