class BodyMeasurement {
  const BodyMeasurement({
    this.id,
    required this.profileId,
    required this.measuredAt,
    required this.weightKg,
    this.neckCm,
    this.chestCm,
    this.waistCm,
    this.abdomenCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.leftCalfCm,
    this.rightCalfCm,
    this.notes,
  });

  final int? id;
  final int profileId;
  final DateTime measuredAt;
  final double weightKg;
  final double? neckCm;
  final double? chestCm;
  final double? waistCm;
  final double? abdomenCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;
  final double? leftCalfCm;
  final double? rightCalfCm;
  final String? notes;

  BodyMeasurement copyWith({
    int? id,
    int? profileId,
    DateTime? measuredAt,
    double? weightKg,
    double? Function()? waistCm,
    String? Function()? notes,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      neckCm: neckCm,
      chestCm: chestCm,
      waistCm: waistCm != null ? waistCm() : this.waistCm,
      abdomenCm: abdomenCm,
      hipsCm: hipsCm,
      leftArmCm: leftArmCm,
      rightArmCm: rightArmCm,
      leftThighCm: leftThighCm,
      rightThighCm: rightThighCm,
      leftCalfCm: leftCalfCm,
      rightCalfCm: rightCalfCm,
      notes: notes != null ? notes() : this.notes,
    );
  }
}
