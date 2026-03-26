import 'dart:io';

import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/data/services/auth_service.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UploadFilesViewModel extends ChangeNotifier {
  // Controllers live here to persist data between page swipes
  UploadFilesViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // Company data
  final companyNameController = TextEditingController(
    text: "companyNameController",
  );
  final commercialNameController = TextEditingController(
    text: "commercialNameController",
  );
  final curpController = TextEditingController(text: "curpController");
  final addressController = TextEditingController(text: "addressController");

  // Billing data
  final billingEmailController = TextEditingController(
    text: "billingEmailController",
  );
  final taxpayerTypeController = TextEditingController(
    text: "taxpayerTypeController",
  );
  final rfcController = TextEditingController(text: "rfcController");
  final taxRegimeController = TextEditingController(
    text: "taxRegimeController",
  );
  final bankController = TextEditingController(text: "bankController");
  final clabeController = TextEditingController(text: "clabeController");

  @override
  void dispose() {
    companyNameController.dispose();
    commercialNameController.dispose();
    curpController.dispose();
    addressController.dispose();
    billingEmailController.dispose();
    taxpayerTypeController.dispose();
    rfcController.dispose();
    taxRegimeController.dispose();
    bankController.dispose();
    clabeController.dispose();
    super.dispose();
  }

  // Docs upload data
  String? pathIdRep;
  String? pathProofAddress;
  String? pathTaxCertificate;
  String? openTime;
  String? closeTime;

  final _logger = Logger();
  late CollectionCenter _collectionCenter = CollectionCenter();

  void updatePath(String field, dynamic value) {
    switch (field) {
      case 'openTime':
        openTime =
            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
        break;
      case 'closeTime':
        closeTime =
            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
        break;
      case 'pathIdRep':
        pathIdRep = value;
        break;
      case 'pathProofAddress':
        pathProofAddress = value;
        break;
      case 'pathTaxCertificate':
        pathTaxCertificate = value;
        break;
    }
    notifyListeners();
  }

  void syncAllToModel() {
    _collectionCenter = CollectionCenter(
      id: '',
      email: '',
      phoneNumber: '',
      password: '',
      surnames: '',
      validationStatus: ValidationStatus.pending,

      companyName: companyNameController.text,
      commercialName: commercialNameController.text,
      curpRep: curpController.text,
      rfc: rfcController.text,
      taxRegime: taxRegimeController.text,
      taxpayerType: taxpayerTypeController.text,
      clabe: clabeController.text,
      billingEmail: billingEmailController.text,
      bank: bankController.text,
      address: addressController.text,
      openTime: openTime,
      closeTime: closeTime,
      pathIdRep: pathIdRep,
      pathProofAddress: pathProofAddress,
      pathTaxCertificate: pathTaxCertificate,
    );
  }

  Future<void> completeRegistration() async {
    final String userId = _authRepository.userId!;
    // Update model
    syncAllToModel();

    // Upload files
    await uploadDocument(userId, _collectionCenter.pathIdRep, 'pathIdRep');
    await uploadDocument(
      userId,
      _collectionCenter.pathProofAddress,
      'pathProofAddress',
    );
    await uploadDocument(
      userId,
      _collectionCenter.pathTaxCertificate,
      'pathTaxCertificate',
    );

    // Upload all data to Database
    final result = await _userRepository.uploadUserData(
      'collection_centers',
      _authRepository.userId!,
      _collectionCenter.toJson(),
    );
    switch (result) {
      case Ok():
        _logger.d(_collectionCenter.toJson());
        break;
      case Error():
        _logger.e(_collectionCenter.toJson());
        break;
    }
  }

  Future<void> uploadDocument(
    String userId,
    String? localPath,
    String docType,
  ) async {
    if (localPath == null) return;

    final file = File(localPath);
    if (!await file.exists()) return;

    // Use the docType (e.g., 'pathIdRep') as the filename
    final fileName = "$docType.pdf";

    final result = await _userRepository.uploadFile(
      id: userId,
      fileName: fileName,
      file: file,
    );

    _logger.i('PATH: $result');

    if (result != null) {
      // Update the model with the STORAGE path, not the local path
      switch (docType) {
        case 'pathIdRep':
          _collectionCenter = _collectionCenter.copyWith(pathIdRep: result);
          break;
        case 'pathProofAddress':
          _collectionCenter = _collectionCenter.copyWith(
            pathProofAddress: result,
          );
          break;
        case 'pathTaxCertificate':
          _collectionCenter = _collectionCenter.copyWith(
            pathTaxCertificate: result,
          );
          break;
      }

      notifyListeners();
    }
  }
}
