

class AttendeeModel {
  final String id;
  final String name;
  final String gatheringId;
  final String? avatarAsset;

  const AttendeeModel({
    required this.id,
    required this.name,
    required this.gatheringId,
    this.avatarAsset,
  });

  // Create an attendee from stored data.
  factory AttendeeModel.fromJson(Map<String, dynamic> json) {
    return AttendeeModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Name unavailable',
      gatheringId: json['gatheringId'] as String,
      avatarAsset: json['avatarAsset'] as String?,
    );
  }

  // Convert an attendee to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gatheringId': gatheringId,
      'avatarAsset': avatarAsset,
    };
  }

  // Create an updated copy.
  AttendeeModel copyWith({
    String? id,
    String? name,
    String? gatheringId,
    String? avatarAsset,
  }) {
    return AttendeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gatheringId: gatheringId ?? this.gatheringId,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}

