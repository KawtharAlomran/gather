class Vote {
  final String id;
  final String gatheringId;
  final String userId;
  final String targetId;
  final String targetType;

  const Vote({ 
    required this.id, 
    required this.gatheringId, 
    required this.userId, 
    required this.targetId, 
    required this.targetType,
  });
}