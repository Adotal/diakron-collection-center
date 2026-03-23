// home_viewmodel.dart
import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // Command0 is used because logout doesn't require input parameters
  }

  final AuthRepository _authRepository;  

}