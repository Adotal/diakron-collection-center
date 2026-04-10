import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/utils/command.dart';
import 'package:diakron_collection_center/utils/result.dart';

class LogoutViewModel {
  LogoutViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    // Command0 is used because logout doesn't require input parameters
    logout = Command0<void>(_logout);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  late Command0 logout;

  Future<Result<void>> _logout() async {
    // Clear cache
    await _userRepository.clearCache();
    return await _authRepository.logout();
  }
}
