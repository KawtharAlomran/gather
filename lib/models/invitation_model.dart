
enum InvitationStatus {
  pending,
  accepted,
  declined,
}

class InvitationModel {
  final String id;
  final String gatheringId;
  final String inviterId;
  final InvitationStatus status;

  const InvitationModel({
    required this.id,
    required this.gatheringId,
    required this.inviterId,
    this.status = InvitationStatus.pending,
  });

  // Create an updated copy without modifying the original.
  InvitationModel copyWith({
    String? id,
    String? gatheringId,
    String? inviterId,
    InvitationStatus? status,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      gatheringId: gatheringId ?? this.gatheringId,
      inviterId: inviterId ?? this.inviterId,
      status: status ?? this.status,
    );
  }

  // Convert the invitation into JSON for future caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gatheringId': gatheringId,
      'inviterId': inviterId,
      'status': status.name,
    };
  }

  // Create an invitation from JSON data.
  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String,
      gatheringId: json['gatheringId'] as String,
      inviterId: json['inviterId'] as String,
      status: InvitationStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
    );
  }
}

