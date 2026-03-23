// home_viewmodel.dart
import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/utils/command.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // Command0 is used because logout doesn't require input parameters
    logout = Command0<void>(_logout); 
  }

  final AuthRepository _authRepository;
  late Command0<void> logout;

  Future<Result<void>> _logout() async {
    return await _authRepository.logout();
  }
}