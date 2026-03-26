enum ValidationStatus { uploading, pending, approved, denied }

class CollectionCenter {
  CollectionCenter({
    this.id,
    this.email,
    this.validationStatus,
    this.username,
    this.surnames,
    this.phoneNumber,
    this.curpRep,
    this.password,
    this.companyName,
    this.rfc,
    this.taxRegime,
    this.taxpayerType,
    this.commercialName,
    this.openTime,
    this.closeTime,
    this.address,
    this.billingEmail,
    this.bank,
    this.clabe,
    this.pathIdRep,
    this.pathProofAddress,
    this.pathTaxCertificate,
  });

  final String? id;
  final String? email;
  final ValidationStatus? validationStatus;

  // Legal Representative
  final String? username;
  final String? surnames;
  final String? phoneNumber;
  final String? curpRep;
  final String? password;

  // Operation and Bank
  final String? companyName;
  final String? rfc;
  final String? taxRegime;
  final String? taxpayerType;
  final String? commercialName;
  final String? openTime; // Stored as String for easy JSON conversion
  final String? closeTime;
  final String? address;
  final String? billingEmail;
  final String? bank;
  final String? clabe;

  // Document Paths
  final String? pathIdRep;
  final String? pathProofAddress;
  final String? pathTaxCertificate;

  CollectionCenter.allRequired({
    required this.id,
    required this.email,
    required this.validationStatus,
    required this.username,
    required this.surnames,
    required this.phoneNumber,
    required this.curpRep,
    required this.password,
    required this.companyName,
    required this.rfc,
    required this.taxRegime,
    required this.taxpayerType,
    required this.commercialName,
    required this.openTime,
    required this.closeTime,
    required this.address,
    required this.billingEmail,
    required this.bank,
    required this.clabe,
    required this.pathIdRep,
    required this.pathProofAddress,
    required this.pathTaxCertificate,
  });
  // Create a copy with updated fields (essential for ViewModels)
  CollectionCenter copyWith({
    String? id,
    String? username,
    String? surnames,
    String? phoneNumber,
    String? curpRep,
    String? email,
    String? password,
    String? companyName,
    String? rfc,
    String? taxRegime,
    String? taxpayerType,
    String? commercialName,
    String? openTime,
    String? closeTime,
    String? address,
    String? billingEmail,
    String? bank,
    String? clabe,
    String? pathIdRep,
    String? pathProofAddress,
    String? pathTaxCertificate,
    ValidationStatus? validationStatus,
  }) {
    return CollectionCenter(
      id: id ?? this.id,
      email: email ?? this.email,
      validationStatus: validationStatus ?? this.validationStatus,
      username: username ?? this.username,
      surnames: surnames ?? this.surnames,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      curpRep: curpRep ?? this.curpRep,
      password: password ?? this.password,
      companyName: companyName ?? this.companyName,
      rfc: rfc ?? this.rfc,
      taxRegime: taxRegime ?? this.taxRegime,
      taxpayerType: taxpayerType ?? this.taxpayerType,
      commercialName: commercialName ?? this.commercialName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      address: address ?? this.address,
      billingEmail: billingEmail ?? this.billingEmail,
      bank: bank ?? this.bank,
      clabe: clabe ?? this.clabe,
      pathIdRep: pathIdRep ?? this.pathIdRep,
      pathProofAddress: pathProofAddress ?? this.pathProofAddress,
      pathTaxCertificate: pathTaxCertificate ?? this.pathTaxCertificate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // CollectionCenter User base data
      // 'id': id,
      // 'email': email,
      // 'username': username,
      // 'surnames': surnames,
      // 'phone_number': phoneNumber,
      // 'password': password,
      // Furthermore data
      'curp_rep': curpRep,
      'company_name': companyName,
      'rfc': rfc,
      'tax_regime': taxRegime,
      'taxpayer_type': taxpayerType,
      'commercial_name': commercialName,
      'open_time': openTime,
      'close_time': closeTime,
      'address': address,
      'billing_email': billingEmail,
      'bank': bank,
      'clabe': clabe,
      'path_id_rep': pathIdRep,
      'path_proof_address': pathProofAddress,
      'path_tax_certificate': pathTaxCertificate,
      'validation_status': parseStatustoString(validationStatus),
    };
  }

  // More data
  // Factory para convertir lo que viene de Supabase (DatabaseService)
  factory CollectionCenter.fromMap(Map<String, dynamic> map) {
    return CollectionCenter(
      id: map['id'],
      email: map['email'] ?? '',
      validationStatus: parseStatus(map['validation_status']),
    );
  }

  static String? parseStatustoString(ValidationStatus? status) {
    switch (status) {
      case ValidationStatus.pending:
        return 'PENDING';
      case ValidationStatus.approved:
        return 'APPROVED';
      case ValidationStatus.denied:
        return 'DENIED';
      default:
        return 'UPLOADING';
    }
  }

  static ValidationStatus parseStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return ValidationStatus.pending;
      case 'APPROVED':
        return ValidationStatus.approved;
      case 'DENIED':
        return ValidationStatus.denied;
      default:
        return ValidationStatus.uploading;
    }
  }
}
