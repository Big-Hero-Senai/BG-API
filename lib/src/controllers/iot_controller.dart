// 📁 lib/src/controllers/iot_controller.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../models/health_data.dart';
import '../models/location_data.dart';
import '../services/iot_service.dart';
import '../utils/response_helper.dart';

// 📡 CONTROLLER: Endpoints para receber dados IoT das pulseiras
class IoTController {
  static final _logger = Logger('IoTController');
  final IoTService _iotService = IoTService();
  
  // 💓 POST /api/iot/health - Receber dados de saúde
  Future<Response> receiveHealthData(Request request) async {
    try {
      _logger.info('💓 POST /api/iot/health - Recebendo dados de saúde');
      
      // Ler JSON da pulseira
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Dados de saúde vazios');
      }
      
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON de saúde inválido', details: e.toString());
      }
      
      // Processar dados através do service
      final healthData = await _iotService.processHealthData(json);
      
      _logger.info('✅ Dados de saúde processados: ${healthData.employeeId}');
      
      return ResponseHelper.created(
        healthData.toJson(),
        message: 'Dados de saúde recebidos e processados'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados de saúde: $e');
      return _handleIoTError(e);
    }
  }
  
  // 🗺️ POST /api/iot/location - Receber dados de localização
  Future<Response> receiveLocationData(Request request) async {
    try {
      _logger.info('🗺️ POST /api/iot/location - Recebendo dados de localização');
      
      // Ler JSON da pulseira
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Dados de localização vazios');
      }
      
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON de localização inválido', details: e.toString());
      }
      
      // Processar dados através do service
      final locationData = await _iotService.processLocationData(json);
      
      _logger.info('✅ Dados de localização processados: ${locationData.employeeId}');
      
      return ResponseHelper.created(
        locationData.toJson(),
        message: 'Dados de localização recebidos e processados'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados de localização: $e');
      return _handleIoTError(e);
    }
  }
  
  // 📊 POST /api/iot/batch - Receber múltiplos dados (batch)
  Future<Response> receiveBatchData(Request request) async {
    try {
      _logger.info('📊 POST /api/iot/batch - Recebendo dados em lote');
      
      // Ler JSON com array de dados
      final body = await request.readAsString();
      if (body.isEmpty) {
        return ResponseHelper.badRequest('Dados em lote vazios');
      }
      
      List<dynamic> jsonArray;
      try {
        jsonArray = jsonDecode(body);
      } catch (e) {
        return ResponseHelper.badRequest('JSON de lote inválido', details: e.toString());
      }
      
      if (jsonArray.isEmpty) {
        return ResponseHelper.badRequest('Array de dados vazio');
      }
      
      // Processar dados em lote
      final result = await _iotService.processBatchData(jsonArray);
      
      _logger.info('✅ Lote processado: ${result['processed']} itens');
      
      return ResponseHelper.created(
        result,
        message: 'Dados em lote processados com sucesso'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao processar dados em lote: $e');
      return _handleIoTError(e);
    }
  }
  
  // 🔍 GET /api/iot/health/:employeeId - Últimos dados de saúde
  Future<Response> getEmployeeHealthData(Request request, String employeeId) async {
    try {
      _logger.info('🔍 GET /api/iot/health/$employeeId - Buscando dados de saúde');
      
      final healthData = await _iotService.getLatestHealthData(employeeId);
      
      if (healthData.isEmpty) {
        return ResponseHelper.notFound('Dados de saúde', id: employeeId);
      }
      
      return ResponseHelper.listSuccess(
        healthData.map((h) => h.toJson()).toList(),
        message: 'Dados de saúde encontrados'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de saúde: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🗺️ GET /api/iot/location/:employeeId - Últimos dados de localização
  Future<Response> getEmployeeLocationData(Request request, String employeeId) async {
    try {
      _logger.info('🗺️ GET /api/iot/location/$employeeId - Buscando dados de localização');
      
      final locationData = await _iotService.getLatestLocationData(employeeId);
      
      if (locationData.isEmpty) {
        return ResponseHelper.notFound('Dados de localização', id: employeeId);
      }
      
      return ResponseHelper.listSuccess(
        locationData.map((l) => l.toJson()).toList(),
        message: 'Dados de localização encontrados'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao buscar dados de localização: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 📊 GET /api/iot/stats - Estatísticas dos dados IoT
  Future<Response> getIoTStats(Request request) async {
    try {
      _logger.info('📊 GET /api/iot/stats - Estatísticas IoT');
      
      final stats = await _iotService.getIoTStatistics();
      
      return ResponseHelper.success(
        data: stats,
        message: 'Estatísticas IoT calculadas'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao calcular estatísticas IoT: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🚨 GET /api/iot/alerts - Alertas ativos
  Future<Response> getActiveAlerts(Request request) async {
    try {
      _logger.info('🚨 GET /api/iot/alerts - Buscando alertas ativos');
      
      final alerts = await _iotService.getActiveAlerts();
      
      return ResponseHelper.listSuccess(
        alerts,
        message: '${alerts.length} alertas encontrados'
      );
    } catch (e) {
      _logger.severe('❌ Erro ao buscar alertas: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🧪 POST /api/iot/test - Endpoint de teste para desenvolvimento
  Future<Response> testIoTEndpoint(Request request) async {
    try {
      _logger.info('🧪 POST /api/iot/test - Teste IoT');
      
      // Dados de teste para simular pulseira
      final testData = {
        'message': 'Endpoint IoT funcionando!',
        'timestamp': DateTime.now().toIso8601String(),
        'examples': {
          'health_data': {
            'employee_id': 'EMP001',
            'device_id': 'DEVICE_001',
            'timestamp': DateTime.now().toIso8601String(),
            'heart_rate': 75,
            'body_temperature': 36.5,
            'battery_level': 85,
          },
          'location_data': {
            'employee_id': 'EMP001',
            'device_id': 'DEVICE_001',
            'timestamp': DateTime.now().toIso8601String(),
            'latitude': '-3.7319',
            'longitude': '-38.5267',
          }
        },
        'endpoints': [
          'POST /api/iot/health',
          'POST /api/iot/location',
          'POST /api/iot/batch',
          'GET /api/iot/health/:employeeId',
          'GET /api/iot/location/:employeeId',
          'GET /api/iot/stats',
          'GET /api/iot/alerts',
        ]
      };
      
      return ResponseHelper.success(
        data: testData,
        message: 'Endpoint de teste IoT funcionando'
      );
    } catch (e) {
      _logger.severe('❌ Erro no teste IoT: $e');
      return ResponseHelper.internalError(details: e.toString());
    }
  }
  
  // 🛡️ TRATAMENTO DE ERROS IoT ESPECÍFICOS
  Response _handleIoTError(dynamic error) {
    final errorMessage = error.toString();
    
    // Erros de validação dos models
    if (errorMessage.contains('ArgumentError')) {
      return ResponseHelper.badRequest(
        'Dados IoT inválidos',
        details: errorMessage.replaceAll('ArgumentError: ', '')
      );
    }
    
    // Erros de employee não encontrado
    if (errorMessage.contains('EmployeeNotFoundException')) {
      return ResponseHelper.notFound(
        'Funcionário',
        id: 'Verifique employee_id'
      );
    }
    
    // Erros de device não reconhecido
    if (errorMessage.contains('DeviceNotFoundException')) {
      return ResponseHelper.badRequest(
        'Device ID não reconhecido',
        details: 'Verifique device_id'
      );
    }
    
    // Erro genérico
    return ResponseHelper.internalError(details: errorMessage);
  }
  
  // 🧹 CLEANUP
  void dispose() {
    _iotService.dispose();
    _logger.info('🧹 IoTController disposed');
  }
}

/*
🎓 CONCEITOS DO IOT CONTROLLER:

1. 📡 **IoT-Specific Endpoints**
   - Recepção de dados de sensores
   - Processamento em tempo real
   - Batch processing para eficiência

2. 🛡️ **Robust Error Handling**
   - Validação específica para IoT
   - Tratamento de dados malformados
   - Respostas apropriadas para devices

3. 📊 **Real-time Operations**
   - Dados de saúde críticos
   - Localização para segurança
   - Alertas automáticos

4. 🔍 **Data Retrieval**
   - Últimos dados por funcionário
   - Estatísticas agregadas
   - Sistema de alertas

5. 🧪 **Development Support**
   - Endpoint de teste
   - Exemplos de formato
   - Debug information

6. 📋 **IoT Best Practices**
   - Logs específicos para rastreamento
   - Processamento assíncrono
   - Validação de device/employee
*/