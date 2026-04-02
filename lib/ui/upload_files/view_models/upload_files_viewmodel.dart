import 'dart:io';

import 'package:diakron_collection_center/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collection_center/data/repositories/user/user_repository.dart';
import 'package:diakron_collection_center/models/user/collection_center.dart';
import 'package:diakron_collection_center/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
       _authRepository = authRepository {
    init();
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // Store days open
  Set<int> daysOpen = {};

  // Its null while no error is detected
  String? timeErrorMsj;

  // GlobalKey for validations
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  bool validateStep1() {
    _logger.w(genScheduleMap());


    if(selectedWasteIds.isEmpty) {
      timeErrorMsj = 'Debe haber al menos un tipo de desecho aceptado';
      notifyListeners();
      return false;
    }

    if (daysOpen.isEmpty) {
      timeErrorMsj = 'Debe haber al menos un día de operación';
      notifyListeners();
      return false;
    }


    // Iterate open days and check all all filled
    for (int i = 0; i < daysOpen.length; i++) {
      if (weekSchedules[daysOpen.elementAt(i)].isUncomplete()) {
        timeErrorMsj = 'Todos los horarios deben ser llenados';
        notifyListeners();
        return false;
      }
    }
    timeErrorMsj = null;
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
    postCodeController.dispose(); 
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

  final _logger = Logger();
  late CollectionCenter _collectionCenter = CollectionCenter();

  String timeOfDaytoString(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  void updatePath(String field, dynamic value) {
    switch (field) {
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
      scheduleMap: genScheduleMap(),
      postCode: postCodeController.text,
      clabe: clabeController.text,
      billingEmail: billingEmailController.text,
      bank: bankController.text,
      address: addressController.text,
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

    _updateProgress("Subiendo tipos de materiales");
    await _userRepository.saveCenterCapabilities(centerId: _authRepository.userId!, selectedWasteIds: selectedWasteIds);

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

  void updateTime(int index, bool isOpenTime, TimeOfDay time) {
    if (isOpenTime) {
      weekSchedules[index].openTime = time;
    } else {
      weekSchedules[index].closeTime = time;
    }
    notifyListeners();
  }

  void copyToAll(int fromIndex) {
    final source = weekSchedules[fromIndex];
    if (source.openTime == null || source.closeTime == null) return;

    for (int i = 0; i < weekSchedules.length; i++) {
      weekSchedules[i].isOpen = true;
      weekSchedules[i].openTime = source.openTime;
      weekSchedules[i].closeTime = source.closeTime;

      // Agregamos el índice al Set para que el SegmentedButton se vea seleccionado
      daysOpen.add(i);
    }
    notifyListeners();
  }

  String? getErrorMessage(int index) {
    final day = weekSchedules[index];
    if (day.isOpen && day.openTime != null && day.closeTime != null) {
      final start = day.openTime!.hour * 60 + day.openTime!.minute;
      final end = day.closeTime!.hour * 60 + day.closeTime!.minute;
      if (end <= start) {
        weekSchedules[index].closeTime = null;
        return "El cierre debe ser después de la apertura";
      }
    }
    return null;
  }

  // NEW SEGMENTED BUTTON

  // Tu lista de modelos (7 días)
  final List<DaySchedule> weekSchedules = List.generate(
    7,
    (index) => DaySchedule(dayName: _getDayName(index)),
  );

  void onDaysChanged(Set<int> newSelection) {
    daysOpen = newSelection;

    // Sincronizamos el booleano isOpen en nuestros modelos
    for (int i = 0; i < weekSchedules.length; i++) {
      weekSchedules[i].isOpen = daysOpen.contains(i);
      // If not contains make it null
      weekSchedules[i].deleteTimesOnClosed();
    }
    notifyListeners();
  }

  static String _getDayName(int i) => [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ][i];

  Map<String, dynamic>? genScheduleMap() {
    final Map<String, dynamic> scheduleMap = {
      for (var day in weekSchedules) day.dayName: day.toJson(),
    };
    return scheduleMap;
  }

  //------------------------------TERMS & CONDITIONS-------------------
  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;
  String? _privacyMd;
  String? _termsMd;
  bool _isLoading = true;

  String get privacyData => _privacyMd ?? "";
  String get termsData => _termsMd ?? "";
  bool get isLoading => _isLoading;

  Future<void> init() async {


    //------------------------CHARGE TERMSN AND CONDITIONS---------------

    // Si ya tienen datos, no cargamos de nuevo
    if (_privacyMd != null && _termsMd != null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Cargamos ambos en paralelo
      final results = await Future.wait([
        rootBundle.loadString('assets/privacy_policy.md'),
        rootBundle.loadString('assets/terms_and_conditions.md'),
      ]);

      _privacyMd = results[0];
      _termsMd = results[1];
    } catch (e) {
      debugPrint("Error cargando MD: $e");
    }
    _isLoading = false;


    //------------------------CHECKBOX OF WASTE TYPES---------------
    allWasteTypes = await _userRepository.fetchAllWasteTypes();

    notifyListeners();
  }

  void setAccepted(bool value) {
    _isAccepted = value;
    notifyListeners();
  }

  //----------------------WASTE TYPES CHECKBOX----------------------------
  List<int> selectedWasteIds = [];
  List<Map<String, dynamic>> allWasteTypes = [
    // {'id': 1, 'waste_type': 'PLÁSTICO'},
    // {'id': 2, 'waste_type': 'METAL'},
    // {'id': 3, 'waste_type': 'PAPEL/CARTÓN'},
    // {'id': 4, 'waste_type': 'VIDRIO'},
  ];

  void onSelectedWasteType(bool? checked, type) {
    if (checked == true) {
      selectedWasteIds.add(type['id']);
    } else {
      selectedWasteIds.remove(type['id']);
    }
    notifyListeners();
    _logger.w(selectedWasteIds);
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

// Class to manage open times of week
class DaySchedule {
  final String dayName;
  bool isOpen;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  DaySchedule({
    required this.dayName,
    this.isOpen = false,
    this.openTime,
    this.closeTime,
  });

  void deleteTimesOnClosed() {
    if (!isOpen) {
      openTime = closeTime = null;
    }
  }

  bool isUncomplete() {
    return (openTime == null || closeTime == null);
  }

  // Convierte el objeto a un mapa compatible con JSONB
  Map<String, dynamic> toJson() => {
    'isOpen': isOpen,
    'open': openTime != null ? timeOfDaytoString(openTime!) : null,
    'close': closeTime != null ? timeOfDaytoString(closeTime!) : null,
  };

  String timeOfDaytoString(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
