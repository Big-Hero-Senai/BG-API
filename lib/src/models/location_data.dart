// 📁 lib/src/models/location_data.dart

import 'dart:math' as math;

// 🗺️ MODEL: Dados de localização das pulseiras IoT (versão simplificada)
class LocationData {
  // 🔒 DADOS IMUTÁVEIS (snapshot da posição exata)
  final String employeeId;
  final DateTime timestamp;
  final String deviceId;
  final String? latitude;         // Coordenada como string (do sensor)
  final String? longitude;        // Coordenada como string (do sensor)
  
  // 🔄 DADOS MUTÁVEIS (processados após recebimento)
  String processingStatus;        // 'received', 'processed', 'analyzed'
  bool isProcessed;              // Flag de processamento
  String? processedZone;         // Zona calculada (futuro)
  String? alertLevel;            // 'normal', 'warning', 'danger'
  DateTime? processedAt;         // Quando foi processado
  String? notes;                 // Notas adicionais
  
  // 🏗️ CONSTRUCTOR COM VALIDAÇÕES BÁSICAS
  LocationData({
    required this.employeeId,
    required this.timestamp,
    required this.deviceId,
    this.latitude,
    this.longitude,
    // 🔄 Dados mutáveis com valores padrão
    this.processingStatus = 'received',
    this.isProcessed = false,
    this.processedZone,
    this.alertLevel,
    this.processedAt,
    this.notes,
  }) {
    // 🛡️ VALIDAÇÕES BÁSICAS
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('❌ Employee ID é obrigatório para localização');
    }
    
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('❌ Device ID é obrigatório para rastreamento');
    }
    
    // IoT: Timestamp não pode estar muito no futuro (tolerância: 5 min)
    if (timestamp.isAfter(DateTime.now().add(Duration(minutes: 5)))) {
      throw ArgumentError('❌ Timestamp de localização muito no futuro: ${timestamp}');
    }
    
    // IoT: Timestamp não pode ser muito antigo (tolerância: 1 hora)
    if (timestamp.isBefore(DateTime.now().subtract(Duration(hours: 1)))) {
      throw ArgumentError('❌ Timestamp de localização muito antigo: ${timestamp}');
    }
    
    // 🗺️ VALIDAÇÃO BÁSICA DE COORDENADAS (se fornecidas)
    if (latitude != null) {
      try {
        final lat = double.parse(latitude!);
        if (lat < -90 || lat > 90) {
          throw ArgumentError('❌ Latitude inválida: $latitude');
        }
      } catch (e) {
        throw ArgumentError('❌ Latitude deve ser um número válido: $latitude');
      }
    }
    
    if (longitude != null) {
      try {
        final lon = double.parse(longitude!);
        if (lon < -180 || lon > 180) {
          throw ArgumentError('❌ Longitude inválida: $longitude');
        }
      } catch (e) {
        throw ArgumentError('❌ Longitude deve ser um número válido: $longitude');
      }
    }
  }
  
  // 🏭 FACTORY: Criar a partir de JSON da pulseira
  factory LocationData.fromJson(Map<String, dynamic> json) {
    try {
      return LocationData(
        // 🔒 Dados imutáveis do sensor
        employeeId: json['employee_id']?.toString() ?? '',
        deviceId: json['device_id']?.toString() ?? '',
        timestamp: DateTime.parse(json['timestamp']?.toString() ?? ''),
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
        // 🔄 Dados mutáveis (podem vir do banco)
        processingStatus: json['processing_status']?.toString() ?? 'received',
        isProcessed: json['is_processed'] == true,
        processedZone: json['processed_zone']?.toString(),
        alertLevel: json['alert_level']?.toString(),
        processedAt: json['processed_at'] != null 
            ? DateTime.parse(json['processed_at']) 
            : null,
        notes: json['notes']?.toString(),
      );
    } catch (e) {
      throw ArgumentError('❌ Erro ao converter JSON para LocationData: $e');
    }
  }
  
  // 📤 CONVERSÃO PARA JSON (para Firebase)
  Map<String, dynamic> toJson() {
    return {
      // 🔒 Dados imutáveis
      'employee_id': employeeId,
      'device_id': deviceId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'data_type': 'location',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      // 🔄 Dados mutáveis  
      'processing_status': processingStatus,
      'is_processed': isProcessed,
      'processed_zone': processedZone,
      'alert_level': alertLevel,
      'processed_at': processedAt?.toUtc().toIso8601String(),
      'notes': notes,
    };
  }
  
  // 📤 JSON COMPACTO (para transmissão IoT)
  Map<String, dynamic> toJsonCompact() {
    final compact = <String, dynamic>{
      'emp_id': employeeId,
      'dev_id': deviceId,
      'ts': timestamp.millisecondsSinceEpoch,
    };
    
    // Só incluir coordenadas se existirem
    if (latitude != null) compact['lat'] = latitude;
    if (longitude != null) compact['lon'] = longitude;
    
    return compact;
  }
  
  // 🔄 MÉTODOS PARA ATUALIZAR DADOS MUTÁVEIS
  void markAsProcessed({String? zone, String? alertLevel}) {
    isProcessed = true;
    processingStatus = 'processed';
    processedAt = DateTime.now().toUtc();
    if (zone != null) processedZone = zone;
    if (alertLevel != null) this.alertLevel = alertLevel;
  }
  
  void addNote(String note) {
    if (notes == null || notes!.isEmpty) {
      notes = note;
    } else {
      notes = '$notes\n[${DateTime.now().toIso8601String()}] $note';
    }
  }
  
  void updateZone(String zone) {
    processedZone = zone;
    processingStatus = 'analyzed';
    processedAt = DateTime.now().toUtc();
  }
  
  void markAsAnalyzed() {
    processingStatus = 'analyzed';
    processedAt = DateTime.now().toUtc();
  }
  
  // 📊 ANÁLISE BÁSICA DE DADOS
  bool get hasCoordinates => latitude != null && longitude != null;
  
  bool get hasValidCoordinates {
    if (!hasCoordinates) return false;
    try {
      final lat = double.parse(latitude!);
      final lon = double.parse(longitude!);
      return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    } catch (e) {
      return false;
    }
  }
  
  // 📍 CONVERSÃO PARA DOUBLE (para uso em mapas)
  double? get latitudeAsDouble {
    if (latitude == null) return null;
    try {
      return double.parse(latitude!);
    } catch (e) {
      return null;
    }
  }
  
  double? get longitudeAsDouble {
    if (longitude == null) return null;
    try {
      return double.parse(longitude!);
    } catch (e) {
      return null;
    }
  }
  
  // 🗺️ COORDENADAS FORMATADAS (para exibição)
  String get coordinatesDisplay {
    if (!hasCoordinates) return 'Sem coordenadas';
    return 'Lat: $latitude, Lon: $longitude';
  }
  
  // 📏 CÁLCULO SIMPLES DE DISTÂNCIA (se tiver coordenadas válidas)
  double? distanceToPoint(String targetLat, String targetLon) {
    if (!hasValidCoordinates) return null;
    
    try {
      final lat1 = double.parse(latitude!);
      final lon1 = double.parse(longitude!);
      final lat2 = double.parse(targetLat);
      final lon2 = double.parse(targetLon);
      
      // Fórmula de Haversine simplificada
      const double earthRadius = 6371000; // metros
      final double dLat = (lat2 - lat1) * (math.pi / 180);
      final double dLon = (lon2 - lon1) * (math.pi / 180);
      
      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(lat1 * (math.pi / 180)) * math.cos(lat2 * (math.pi / 180)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
      
      final double c = 2 * math.asin(math.sqrt(a));
      return earthRadius * c;
    } catch (e) {
      return null;
    }
  }
  
  LocationStatus get overallStatus {
    if (alertLevel == 'danger') return LocationStatus.danger;
    if (alertLevel == 'warning') return LocationStatus.warning;
    if (hasValidCoordinates) return LocationStatus.tracked;
    return LocationStatus.unknown;
  }
  
  // 📋 DEBUG E LOGGING
  @override
  String toString() {
    if (hasCoordinates) {
      return 'LocationData(${employeeId}, ${coordinatesDisplay}, ${timestamp})';
    } else {
      return 'LocationData(${employeeId}, Sem coordenadas, ${timestamp})';
    }
  }
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
           (other is LocationData && 
            other.employeeId == employeeId && 
            other.deviceId == deviceId && 
            other.timestamp == timestamp);
  }
  
  @override
  int get hashCode => Object.hash(employeeId, deviceId, timestamp);
}

// 🚥 ENUM: Status de localização (simplificado)
enum LocationStatus {
  danger('Zona de Perigo'),
  warning('Atenção'),
  tracked('Rastreado'),
  unknown('Posição Desconhecida');
  
  const LocationStatus(this.displayName);
  final String displayName;
}