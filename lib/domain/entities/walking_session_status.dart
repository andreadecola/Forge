/// Stable values stored in `camminate.stato`.
enum WalkingSessionStatus {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  aborted('ABORTED');

  const WalkingSessionStatus(this.code);

  final String code;

  static WalkingSessionStatus fromCode(String code) =>
      values.firstWhere((status) => status.code == code);
}
