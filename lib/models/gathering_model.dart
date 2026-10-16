class Gathering {
  final String id;
  final String title;
  final String creatorEmail;
  final List<String> participantIds;

  const Gathering( {
    required this.id, 
    required this.title, 
    required this.creatorEmail, 
    required this.participantIds});
}
