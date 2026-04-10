import 'package:diakron_collection_center/data/services/auth_service.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  // Dependency injection
  AuthRepository({required AuthService authService})
    : _authService = authService {
    _initListener();
  }

  final AuthService _authService;

  // Provide the current user ID
  String get userId => _authService.currentUserId!;
  bool get isAuthenticated => (_authService.currentUser != null);

  bool _isRecoveringPassword = false;
  bool get isRecoveringPassword => _isRecoveringPassword;

  // State flag to freeze the router during check of USER TYPE and for permit ANIMATION
  bool _isVerifyingAuth = false;
  bool get isVerifyingAuth => _isVerifyingAuth;

  void _initListener() {
    _authService.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecoveringPassword = true;
      } else if (event == AuthChangeEvent.signedIn) {
        if (!_isRecoveringPassword) {
          _isRecoveringPassword = false;
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _isRecoveringPassword = false;
      }

      notifyListeners();
    });
  }

  void lockRouter() {
    _isVerifyingAuth = true;
  }

  void unlockRouter() {
    _isVerifyingAuth = false;
    notifyListeners();
  }

  Future<Result<void>> login(String email, String password) async {
    // LOCK THE ROUTER
    _isVerifyingAuth = true;
    notifyListeners();

    final result = await _authService.signInEmailPassword(
      email: email,
      password: password,
    );
    return result;
  }

  Future<Result<void>> signUp({
    required String username,
    required String surnames,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    // Lock router to manually sign in and force user to login and see animation
    lockRouter();
    final result = await _authService.sigUpEmailPassword(
      username: username,
      surnames: surnames,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    if (result is Error<AuthResponse>) {
      return Result.error(result.error);
    }
    // Sign up successful
    return Result.ok(null);

    // return await _authService.sigUpEmailPassword(email, password);
  }

  Future<Result<void>> updatePassword({required String password}) async {
    // Lock router to manually sign in and force user to login and see animation
    lockRouter();
    final result = await _authService.updatePassword(password: password);
    _isRecoveringPassword = false;
    if (result is Error<UserResponse>) {
      return Result.error(result.error);
    }

    return Result.ok(null);
  }

  // In auth_repository.dart
  Future<Result<void>> logout() async {
    try {
      await _authService.signOut();
      // CLEAR CACHE OF USER_REPO
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> sendEmailforgetPassword({required String email}) async {
    final result = await _authService.sendEmailforgetPassword(email: email);
    if (result is Error) {
      return Result.error(result.error);
    }
    return Result.ok(null);
  }

  String? getCurrentUserEmail() => _authService.getEmail();
}
