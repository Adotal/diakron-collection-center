import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/utils/command.dart';
import 'package:diakron_collection_center/utils/result.dart';

class LogoutViewModel {
  LogoutViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    logout = Command0(_logout);
  }
  final AuthRepository _authRepository;
  late Command0 logout;

  Future<Result> _logout() async {
    await _authRepository.logout();    

    return Result.ok('Success');
    
  }
}
