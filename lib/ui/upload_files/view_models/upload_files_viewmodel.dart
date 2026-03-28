import 'dart:io';

import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

enum TaxpayerType {
  moral('Persona Moral'),
  physical('Persona Física');

  final String label;
  const TaxpayerType(this.label);
}

class UploadFilesViewModel extends ChangeNotifier {
  // Controllers live here to persist data between page swipes
  UploadFilesViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // Its null while no error is detected
  String? timeErrorMsj;

  // GlobalKey for validations
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  bool validateStep1() {
    if (openTime == null || closeTime == null) {
      timeErrorMsj = 'Ambos horarios deben ser llenados';
      notifyListeners();
      return false;
    }

    return step1FormKey.currentState?.validate() ?? false;
  }

  bool validateStep2() => step2FormKey.currentState?.validate() ?? false;

  bool validateStep3() {
    // Manual check for files
    return pathIdRep != null &&
        pathProofAddress != null &&
        pathTaxCertificate != null;
  }

  TaxpayerType _currentType = TaxpayerType.moral;
  TaxpayerType get currentType => _currentType;

  void setTaxpayerType(TaxpayerType? value) {
    if (value == null) return;
    _currentType = value;
    notifyListeners();
  }

  // Company data
  final companyNameController = TextEditingController(
    text: "companyNameController",
  );
  final commercialNameController = TextEditingController(
    text: "commercialNameController",
  );
  final curpController = TextEditingController(text: "OEOA070414HAAAAAA9");
  final addressController = TextEditingController(text: "addressController");
  final postCodeController = TextEditingController(text: "44000");

  // Billing data
  final billingEmailController = TextEditingController(
    text: "ccenter@diakron.com",
  );
  final rfcController = TextEditingController(text: "rfcController");
  final taxRegimeController = TextEditingController(
    text: "taxRegimeController",
  );
  final bankController = TextEditingController(text: "bankController");
  final clabeController = TextEditingController(text: "012180015488584106");

  @override
  void dispose() {
    companyNameController.dispose();
    commercialNameController.dispose();
    curpController.dispose();
    addressController.dispose();
    billingEmailController.dispose();
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
  String? openTime = '07:00';
  String? closeTime = '15:00';

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
      taxpayerType: currentType.label,
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

  String _uploadMessage = "Iniciando registro...";
  String get uploadMessage => _uploadMessage;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  void _updateProgress(String message) {
    _uploadMessage = message;
    notifyListeners();
  }

  Future<void> completeRegistration() async {
    final String userId = _authRepository.userId!;
    _isProcessing = true;

    _updateProgress("Sincronizando datos...");

    // Update model
    syncAllToModel();

    // Upload files

    // Upload ID
    _updateProgress("Subiendo: Identificación del Representante...");
    await uploadDocument(userId, _collectionCenter.pathIdRep, 'pathIdRep');

    // Upload Proof Address
    _updateProgress("Subiendo: Comprobante de Domicilio...");
    await uploadDocument(
      userId,
      _collectionCenter.pathProofAddress,
      'pathProofAddress',
    );
    // Upload Tax Certificate
    _updateProgress("Subiendo: Constancia de Situación Fiscal...");
    await uploadDocument(
      userId,
      _collectionCenter.pathTaxCertificate,
      'pathTaxCertificate',
    );

    // Database sync
    _updateProgress("Finalizando: Información del Centro de Acopio...");

    // Upload all data to Database
    final result = await _userRepository.uploadUserData(
      'collection_centers',
      _authRepository.userId!,
      _collectionCenter.toJson(),
    );
    switch (result) {
      case Ok():
        _updateProgress('Todo listo!');
        _logger.d(_collectionCenter.toJson());
        await _userRepository.getValidationStatus(userId, forceRefresh: true);
        _isProcessing = false;
        break;
      case Error():
        _updateProgress("Error al subir los datos. Reintenta.");
        _isProcessing = false;
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

    // Use the docType (e.g., 'pathIdRep') as the filename, but quit 'path', quit first 4 chars

    final fileName = "${docType.substring(4)}.pdf";

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

class Validators {
  // Empty Check
  static String? required(String? value) =>
      (value == null || value.isEmpty) ? 'Este campo es obligatorio' : null;

  // Email (Billing)
  static String? email(String? value) {
    final emptyField = required(value);
    if (emptyField != null) {
      return emptyField;
    }
    final bool emailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value ?? '');
    return emailValid ? null : 'Correo electrónico no válido';
  }

  // CURP (Mexico - 18 chars)
  static String? curp(String? value) {
    final emptyField = required(value);
    if (emptyField != null) {
      return emptyField;
    }
    final bool curpValid = RegExp(
      r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z\d]\d$',
    ).hasMatch(value ?? '');
    return curpValid ? null : 'CURP no válido (revisa 18 caracteres y formato)';
  }

  // RFC (Mexico - 12 or 13 chars)
  static String? rfc(String? value) {
    /*
    Regex retrieved and fixed from
    https://wwwmat.sat.gob.mx/cs/Satellite?blobcol=urldata&blobkey=id&blobtable=MungoBlobs&blobwhere=1461175750735&ssbinary=true
    
    Rfc contribuyente (original):
    ˆ([A-ZÑ]|\&){3,4}[0-9]{2}(0[1-9]|1[0-2])([12][0-9]|0[1-9]|3[01])[A-Z0-9]{3}$
      */

    final emptyField = required(value);
    if (emptyField != null) {
      return emptyField;
    }

    final bool rfcValid = RegExp(
      r'^([A-ZÑ&]{3,4})([0-9]{2})(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])[A-Z\d]{3}$',
    ).hasMatch(value ?? '');
    return rfcValid ? null : 'RFC no válido';
  }

  // CLABE (18 digits)
  static String? clabe(String? value) {
    final emptyField = required(value);
    if (emptyField != null) {
      return emptyField;
    }
    final bool clabeValid = RegExp(r'^\d{18}$').hasMatch(value ?? '');
    return clabeValid ? null : 'CLABE debe tener 18 dígitos';
  }

  static String? postCode(String? value) {
    final emptyField = required(value);
    if (emptyField != null) {
      return emptyField;
    }
    final bool postCodeValid = RegExp(r'^\d{5}$').hasMatch(value ?? '');
    return postCodeValid ? null : 'Código postal debe tener 5 dígitos';
  }
}
