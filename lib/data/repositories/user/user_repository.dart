import 'dart:io';

import 'package:diakron_collection_center/data/services/database_service.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';

class UserRepository extends ChangeNotifier {
  UserRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  ValidationStatus? validationStatus;

  Future<ValidationStatus> getValidationStatus(
    String userId, {
    bool forceRefresh = false,
  }) async {
    // 1. Return cache if available and we aren't forcing a refresh
    if (validationStatus != null && !forceRefresh) {
      return validationStatus!;
    }

    try {
      // 2. Fetch from DB
      final status = await _databaseService.getValidationStatus(userId);

      // 3. Update local state and notify the app
      validationStatus = status;
      notifyListeners();

      return status;
    } catch (e) {
      // 4. Fallback/Error handling
      return validationStatus ?? ValidationStatus.uploading;
    }
  }

  void clearCache() {
    validationStatus = null;
    notifyListeners();
  }

  Future<String?> uploadFile({
    required String id,
    required String fileName,
    required File file,
  }) async {
    return await _databaseService.uploadFile(
      id: id,
      fileName: fileName,
      file: file,
    );
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

  Future<List<Map<String, dynamic>>> fetchAllWasteTypes() async {
    return await _databaseService.fetchAllWasteTypes();
  }

  Future<void> saveCenterCapabilities({
    required String centerId,
    required List<int> selectedWasteIds,
  }) async {
    await _databaseService.saveCenterCapabilities(
      centerId: centerId,
      selectedWasteIds: selectedWasteIds,
    );
  }
}
