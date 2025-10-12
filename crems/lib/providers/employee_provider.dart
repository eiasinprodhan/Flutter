import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../models/user_model.dart';
import '../services/employee_service.dart';
import '../utils/image_picker_helper.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _errorMessage;

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _employeeService.getAllEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployeeById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEmployee = await _employeeService.getEmployeeById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployeeByEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEmployee = await _employeeService.getEmployeeByEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee(User user, Employee employee, PickedImageData? imageData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _employeeService.addEmployee(user, employee, imageData);
      await loadEmployees();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee, PickedImageData? imageData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _employeeService.updateEmployee(employee, imageData);
      await loadEmployees();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// DELETE EMPLOYEE - ENHANCED VERSION
  Future<bool> deleteEmployee(int id) async {
    print('\n╔════════════════════════════════════════╗');
    print('║  EMPLOYEE PROVIDER - DELETE            ║');
    print('╚════════════════════════════════════════╝');
    print('🔴 Starting delete for Employee ID: $id');
    print('Current employee count: ${_employees.length}');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call service to delete from backend
      final success = await _employeeService.deleteEmployee(id);

      print('Service returned: $success');

      if (success) {
        print('✅ Delete successful - Updating local state');

        // Remove from local list
        final initialCount = _employees.length;
        _employees.removeWhere((emp) => emp.id == id);
        final finalCount = _employees.length;

        print('Removed from list: ${initialCount - finalCount} employee(s)');
        print('New employee count: $finalCount');

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();

        print('✅ UI updated successfully');
        print('╚════════════════════════════════════════╝\n');
        return true;
      } else {
        print('❌ Delete service returned false');
        _errorMessage = 'Failed to delete employee from server';
        _isLoading = false;
        notifyListeners();
        print('╚════════════════════════════════════════╝\n');
        return false;
      }
    } catch (e) {
      print('💥 Exception in provider: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('╚════════════════════════════════════════╝\n');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}