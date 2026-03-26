import 'dart:io';

import 'package:diakron_collection_center/data/services/database_service.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';

class UserRepository extends ChangeNotifier {
  UserRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  Future<ValidationStatus> getValidationStatus(String userId) async {
    return await _databaseService.getValidationStatus(userId);
  }

 Future<String?> uploadFile({
    required String id,
    required String fileName,
    required File file,
  }) async {
    return await _databaseService.uploadFile(id: id, fileName: fileName, file: file);    
  }

  Future<bool> isValidated(String userId) async {
    final status = await _databaseService.getValidationStatus(userId);
    return (status == ValidationStatus.approved);
  }

  Future<Result<void>> uploadUserData(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _databaseService.uploadUserData(
      table: table,
      id: id,
      data: data,
    );
    return result;
  }
}
