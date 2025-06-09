// 📁 lib/src/models/health_data.dart

// 💓 MODEL: Dados de saúde das pulseiras IoT
class HealthData {
  // 🔒 DADOS IMUTÁVEIS (snapshot do momento exato)
  final String employeeId;
  final DateTime timestamp;
  final String deviceId;
  final int? heartRate;           // bpm no momento X
  final double? bodyTemperature;   // °C no momento X
  final BloodPressure? bloodPressure;  // Pressão no momento X
  final int? oxygenSaturation;    // % no momento X
  final int? stressLevel;         // 0-100 no momento X
  final ActivityLevel? activity;  // Atividade no momento X
  final int? batteryLevel;        // % no momento X
  final String? signalStrength;   // Sinal no momento X
  
  // 🔄 DADOS MUTÁVEIS (podem mudar após processamento)
  String processingStatus;        // 'received', 'processed', 'analyzed'
  bool isProcessed;              // Flag de processamento
  String? alertLevel;            // 'normal', 'warning', 'critical'
  DateTime? processedAt;         // Quando foi processado
  String? notes;                 // Notas médicas adicionadas depois
  
  // 🏗️ CONSTRUCTOR COM VALIDAÇÕES IoT
  HealthData({
    required this.employeeId,
    required this.timestamp,
    required this.deviceId,
    this.heartRate,
    this.bodyTemperature,
    this.bloodPressure,
    this.oxygenSaturation,
    this.stressLevel,
    this.activity,
    this.batteryLevel,
    this.signalStrength,
    // 🔄 Dados mutáveis com valores padrão
    this.processingStatus = 'received',
    this.isProcessed = false,
    this.alertLevel,
    this.processedAt,
    this.notes,
  }) {
    // 🛡️ VALIDAÇÕES CRÍTICAS PARA IoT
    if (employeeId.trim().isEmpty) {
      throw ArgumentError('❌ Employee ID é obrigatório para dados IoT');
    }
    
    if (deviceId.trim().isEmpty) {
      throw ArgumentError('❌ Device ID é obrigatório para rastreamento');
    }
    
    // IoT: Timestamp não pode estar muito no futuro (tolerância: 5 min)
    if (timestamp.isAfter(DateTime.now().add(Duration(minutes: 5)))) {
      throw ArgumentError('❌ Timestamp IoT muito no futuro: ${timestamp}');
    }
    
    // IoT: Timestamp não pode ser muito antigo (tolerância: 1 hora)
    if (timestamp.isBefore(DateTime.now().subtract(Duration(hours: 1)))) {
      throw ArgumentError('❌ Timestamp IoT muito antigo: ${timestamp}');
    }
    
    // 💓 VALIDAÇÕES MÉDICAS ESPECÍFICAS
    if (heartRate != null && (heartRate! < 30 || heartRate! > 220)) {
      throw ArgumentError('❌ Frequência cardíaca perigosa: $heartRate bpm');
    }
    
    if (bodyTemperature != null && (bodyTemperature! < 30.0 || bodyTemperature! > 45.0)) {
      throw ArgumentError('❌ Temperatura corporal perigosa: $bodyTemperature°C');
    }
    
    if (oxygenSaturation != null && (oxygenSaturation! < 70 || oxygenSaturation! > 100)) {
      throw ArgumentError('❌ Saturação de oxigênio crítica: $oxygenSaturation%');
    }
    
    if (stressLevel != null && (stressLevel! < 0 || stressLevel! > 100)) {
      throw ArgumentError('❌ Nível de stress inválido: $stressLevel');
    }
    
    if (batteryLevel != null && (batteryLevel! < 0 || batteryLevel! > 100)) {
      throw ArgumentError('❌ Nível de bateria inválido: $batteryLevel%');
    }
  }
  
  // 🏭 FACTORY: Criar a partir de JSON da pulseira
  factory HealthData.fromJson(Map<String, dynamic> json) {
    try {
      return HealthData(
        // 🔒 Dados imutáveis do sensor
        employeeId: json['employee_id']?.toString() ?? '',
        deviceId: json['device_id']?.toString() ?? '',
        timestamp: DateTime.parse(json['timestamp']?.toString() ?? ''),
        heartRate: json['heart_rate'] as int?,
        bodyTemperature: json['body_temperature'] != null 
            ? (json['body_temperature'] as num).toDouble() 
            : null,
        bloodPressure: json['blood_pressure'] != null 
            ? BloodPressure.fromJson(json['blood_pressure']) 
            : null,
        oxygenSaturation: json['oxygen_saturation'] as int?,
        stressLevel: json['stress_level'] as int?,
        activity: json['activity'] != null 
            ? ActivityLevel.fromString(json['activity']) 
            : null,
        batteryLevel: json['battery_level'] as int?,
        signalStrength: json['signal_strength']?.toString(),
        // 🔄 Dados mutáveis (podem vir do banco)
        processingStatus: json['processing_status']?.toString() ?? 'received',
        isProcessed: json['is_processed'] == true,
        alertLevel: json['alert_level']?.toString(),
        processedAt: json['processed_at'] != null 
            ? DateTime.parse(json['processed_at']) 
            : null,
        notes: json['notes']?.toString(),
      );
    } catch (e) {
      throw ArgumentError('❌ Erro ao converter JSON IoT para HealthData: $e');
    }
  }
  
  // 📤 CONVERSÃO PARA JSON (para Firebase)
  Map<String, dynamic> toJson() {
    return {
      // 🔒 Dados imutáveis
      'employee_id': employeeId,
      'device_id': deviceId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'heart_rate': heartRate,
      'body_temperature': bodyTemperature,
      'blood_pressure': bloodPressure?.toJson(),
      'oxygen_saturation': oxygenSaturation,
      'stress_level': stressLevel,
      'activity': activity?.name,
      'battery_level': batteryLevel,
      'signal_strength': signalStrength,
      'data_type': 'health',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      // 🔄 Dados mutáveis  
      'processing_status': processingStatus,
      'is_processed': isProcessed,
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
    
    // Só incluir dados que existem (economia de banda IoT)
    if (heartRate != null) compact['hr'] = heartRate;
    if (bodyTemperature != null) compact['temp'] = bodyTemperature;
    if (oxygenSaturation != null) compact['ox'] = oxygenSaturation;
    if (batteryLevel != null) compact['bat'] = batteryLevel;
    
    return compact;
  }
  
  // 🔄 MÉTODOS PARA ATUALIZAR DADOS MUTÁVEIS
  void markAsProcessed({String? alertLevel}) {
    isProcessed = true;
    processingStatus = 'processed';
    processedAt = DateTime.now().toUtc();
    if (alertLevel != null) {
      this.alertLevel = alertLevel;
    }
  }
  
  void addMedicalNote(String note) {
    if (notes == null || notes!.isEmpty) {
      notes = note;
    } else {
      notes = '$notes\n[${DateTime.now().toIso8601String()}] $note';
    }
  }
  
  void updateAlertLevel(String newAlertLevel) {
    alertLevel = newAlertLevel;
    processingStatus = 'analyzed';
  }
  
  void markAsAnalyzed() {
    processingStatus = 'analyzed';
    processedAt = DateTime.now().toUtc();
  }
  bool get hasVitalSigns => heartRate != null || bodyTemperature != null || oxygenSaturation != null;
  
  bool get isAbnormalHeartRate {
    if (heartRate == null) return false;
    return heartRate! < 60 || heartRate! > 100; // Bradicardia/Taquicardia
  }
  
  bool get isFeverDetected {
    if (bodyTemperature == null) return false;
    return bodyTemperature! > 37.5; // Febre
  }
  
  bool get isLowOxygen {
    if (oxygenSaturation == null) return false;
    return oxygenSaturation! < 95; // Hipoxemia
  }
  
  bool get isHighStress {
    if (stressLevel == null) return false;
    return stressLevel! > 70; // Stress alto
  }
  
  bool get isLowBattery {
    if (batteryLevel == null) return false;
    return batteryLevel! < 20; // Bateria baixa
  }
  
  // 🚨 ALERTA CRÍTICO (para notificações automáticas)
  bool get isCriticalAlert {
    return isAbnormalHeartRate || isFeverDetected || isLowOxygen;
  }
  
  HealthStatus get overallStatus {
    if (isCriticalAlert) return HealthStatus.critical;
    if (isHighStress) return HealthStatus.warning;
    if (hasVitalSigns) return HealthStatus.normal;
    return HealthStatus.noData;
  }
  
  // 📋 DEBUG E LOGGING
  @override
  String toString() {
    return 'HealthData(${employeeId}, ${deviceId}, HR:${heartRate}, Temp:${bodyTemperature}, ${timestamp})';
  }
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
           (other is HealthData && 
            other.employeeId == employeeId && 
            other.deviceId == deviceId && 
            other.timestamp == timestamp);
  }
  
  @override
  int get hashCode => Object.hash(employeeId, deviceId, timestamp);
}

// 🩸 CLASSE: Pressão arterial
class BloodPressure {
  final int systolic;   // Pressão sistólica (120 normal)
  final int diastolic;  // Pressão diastólica (80 normal)
  
  BloodPressure({
    required this.systolic,
    required this.diastolic,
  }) {
    if (systolic < 70 || systolic > 200) {
      throw ArgumentError('❌ Pressão sistólica inválida: $systolic');
    }
    if (diastolic < 40 || diastolic > 120) {
      throw ArgumentError('❌ Pressão diastólica inválida: $diastolic');
    }
  }
  
  factory BloodPressure.fromJson(Map<String, dynamic> json) {
    return BloodPressure(
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
    };
  }
  
  bool get isHigh => systolic > 140 || diastolic > 90;
  bool get isLow => systolic < 90 || diastolic < 60;
  bool get isNormal => !isHigh && !isLow;
  
  @override
  String toString() => '$systolic/$diastolic mmHg';
}

// 🏃 ENUM: Nível de atividade
enum ActivityLevel {
  resting('Repouso'),
  light('Atividade Leve'),
  moderate('Atividade Moderada'),
  intense('Atividade Intensa'),
  unknown('Desconhecido');
  
  const ActivityLevel(this.displayName);
  final String displayName;
  
  static ActivityLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'resting':
      case 'repouso':
        return ActivityLevel.resting;
      case 'light':
      case 'leve':
        return ActivityLevel.light;
      case 'moderate':
      case 'moderada':
        return ActivityLevel.moderate;
      case 'intense':
      case 'intensa':
        return ActivityLevel.intense;
      default:
        return ActivityLevel.unknown;
    }
  }
}

// 🚥 ENUM: Status geral de saúde
enum HealthStatus {
  critical('Crítico'),
  warning('Atenção'),
  normal('Normal'),
  noData('Sem Dados');
  
  const HealthStatus(this.displayName);
  final String displayName;
}

/*
🎓 CONCEITOS IoT IMPLEMENTADOS:

1. 📡 **Timestamp Validation**
   - Tolerância para sincronia de rede
   - Detecção de dados muito antigos/futuros
   - UTC obrigatório para coordenação global

2. 🛡️ **Medical Validations**
   - Ranges médicos realistas
   - Detecção de valores críticos
   - Alertas automáticos

3. 📊 **Real-time Analysis**
   - Status calculado em tempo real
   - Flags de alerta imediatos
   - Agregação de múltiplos sensores

4. 🔋 **Device Management**
   - Status da bateria
   - Qualidade do sinal
   - Rastreamento de dispositivo

5. 📱 **IoT Optimizations**
   - JSON compacto para transmissão
   - Campos opcionais para flexibilidade
   - Economia de banda de rede
*/