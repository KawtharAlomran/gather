
enum InvitationStatus {
  pending,
  accepted,
  declined,
}

class InvitationModel {
  final String id;
  final String gatheringId;
  final String inviterId;
  final String inviterName;
  final String? inviterAvatar;
  final String gatheringTitle;
  final String activityType;
  final InvitationStatus status;

  const InvitationModel({
    required this.id,
    required this.gatheringId,
    required this.inviterId,
    required this.inviterName,
    this.inviterAvatar,
    required this.gatheringTitle,
    required this.activityType,
    this.status = InvitationStatus.pending,
  });

  // Create an updated copy without modifying the original object.
  InvitationModel copyWith({
    String? id,
    String? gatheringId,
    String? inviterId,
    String? inviterName,
    String? inviterAvatar,
    String? gatheringTitle,
    String? activityType,
    InvitationStatus? status,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      gatheringId: gatheringId ?? this.gatheringId,
      inviterId: inviterId ?? this.inviterId,
      inviterName: inviterName ?? this.inviterName,
      inviterAvatar: inviterAvatar ?? this.inviterAvatar,
      gatheringTitle: gatheringTitle ?? this.gatheringTitle,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
    );
  }

  // Convert an invitation object into a map for future caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gatheringId': gatheringId,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterAvatar': inviterAvatar,
      'gatheringTitle': gatheringTitle,
      'activityType': activityType,
      'status': status.name,
    };
  }

  // Create an invitation object from API or cached data.
  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String,
      gatheringId: json['gatheringId'] as String,
      inviterId: json['inviterId'] as String,
      inviterName: json['inviterName'] as String,
      inviterAvatar: json['inviterAvatar'] as String?,
      gatheringTitle: json['gatheringTitle'] as String,
      activityType: json['activityType'] as String,
      status: InvitationStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
    );
  }
}
