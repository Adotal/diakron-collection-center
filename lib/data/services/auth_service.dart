import 'package:diakron_collection_center/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Provide a stream of auth changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Session? get currentSession => _supabase.auth.currentSession;

  // Sign in (login)
  Future<Result<AuthResponse>> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Result.ok(result);
    } on AuthException catch (error) {
      // Supabase error
      return Result.error(Exception(error.message));
    } catch (error) {
      return Result.error(Exception("Unknow error"));
    }
  }

  // Sign up
  Future<Result<AuthResponse>> sigUpEmailPassword({
    required String email,
    required String password,
    required String username,
    required String surnames,
    required String phoneNumber,    
  }) async {
    try {
      final result = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_name': username,
          'surnames': surnames,
          'phone_number': phoneNumber,
          // Empieza desactivado porque es solicitud de registro
          'is_active': false,
          // Siempre es admin
          'user_type': 'admin',
          'is_superadmin': false,
        },
      );

      return Result.ok(result);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Send email password recover

  Future<Result<void>> sendEmailforgetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.diakron.admin://reset-password/',
      );
      return Result.ok(null);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // Update user password
  Future<Result<UserResponse>> updatePassword({
    required String password,
  }) async {
    try {
      final result = await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      return Result.ok(result);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // get Email
  String? getEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;

    return user?.email;
  }
}
