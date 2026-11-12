class AttendeeModel {
  final String id;
  final String name;
  final String gatheringId;
  final String? avatarAsset;
  const AttendeeModel({required this.id, required this.name, required this.gatheringId, this.avatarAsset});
  factory AttendeeModel.fromJson(Map<String, dynamic> json) => AttendeeModel(
    id: json['id'] as String, name: json['name'] as String,
    gatheringId: json['gatheringId'] as String,
    avatarAsset: json['avatarAsset'] as String?,
  );
}
