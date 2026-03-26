import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/data/services/auth_service.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository extends ChangeNotifier {
  // Dependency injection
  AuthRepository({required AuthService authService})
    : _authService = authService {
    // Listen to Supabase auth changes internally
    _authService.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecoveringPassword = true;
      } else if (event == AuthChangeEvent.signedIn) {
        // ONLY set recovering to false if we aren't already in a recovery flow
        // or if the session is standard.
        if (!_isRecoveringPassword) {
          _isRecoveringPassword = false;
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _isRecoveringPassword = false;
      }

      notifyListeners();
    });
  }

  final AuthService _authService;

  // Provide the current user ID
  String? get userId => _authService.currentUserId;

  // Ensures UI or other ViewModels can always find the ID
  bool get hasId => userId != null;
  bool get isLogged => _authService.currentUser != null;

  bool _isRecoveringPassword = false;
  bool get isRecoveringPassword => _isRecoveringPassword;


  Future<Result<void>> login(String email, String password) async {
    final result = await _authService.signInEmailPassword(
      email: email,
      password: password,
    );

    if (result is Error) {
      return result;
    }

    // Login successful
    return Result.ok(null);
  }

  Future<Result<void>> signUp({
    required String username,
    required String surnames,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
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
