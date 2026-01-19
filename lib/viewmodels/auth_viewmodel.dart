import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthViewModel() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _supabaseService.getCurrentUser();
    if (user != null) {
      _currentUser = UserModel(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'],
        avatarUrl: user.userMetadata?['avatar_url'],
      );
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(email, password);

      if (response.user != null) {
        _currentUser = UserModel(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: name,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(email, password);

      if (response.user != null) {
        _currentUser = UserModel(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['name'],
          avatarUrl: response.user!.userMetadata?['avatar_url'],
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.resetPassword(email);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
