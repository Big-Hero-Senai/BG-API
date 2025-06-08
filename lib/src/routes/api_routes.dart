import 'package:shelf_router/shelf_router.dart';
import '../controllers/employee_controller.dart';
import '../controllers/documentation_controller.dart';

// 🌐 ROUTER: Mapeamento de URLs para Controllers  
class ApiRoutes {
  late final Router _router;
  final EmployeeController _employeeController = EmployeeController();
  
  ApiRoutes() {
    _router = Router();
    _setupRoutes();
  }
  
  // 🗺️ CONFIGURAÇÃO DAS ROTAS
  void _setupRoutes() {
    // 📋 ROTAS DE FUNCIONÁRIOS
    _router.get('/api/employees', _employeeController.getAllEmployees);
    _router.get('/api/employees/<id>', _employeeController.getEmployeeById);
    _router.post('/api/employees', _employeeController.createEmployee);
    _router.put('/api/employees/<id>', _employeeController.updateEmployee);
    _router.delete('/api/employees/<id>', _employeeController.deleteEmployee);
    
    // 📄 ROTAS DE DOCUMENTAÇÃO (usando templates limpos)
    _router.get('/', DocumentationController.getDocumentation);
    _router.get('/api', DocumentationController.getApiInfo);
    _router.get('/health', DocumentationController.healthCheck);
  }
  
  // 🎯 Getter para o router
  Router get router => _router;
}