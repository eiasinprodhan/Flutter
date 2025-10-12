import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.token != null) {
        final user = User(
          email: email,
          name: '',
          phone: '',
          role: 'EMPLOYEE',
          active: true,
        );

        await _authService.saveUserData(user);
        _currentUser = user;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await loadUserData();
    }
    return isLoggedIn;
  }

  Future<void> loadUserData() async {
    _currentUser = await _authService.getUserData();
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    _authService.saveUserData(user);
    notifyListeners();
  }

  Future<User?> getUserData() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    _currentUser = await _authService.getUserData();
    return _currentUser;
  }
}