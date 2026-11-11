class Place{
  final String id;
  final String name;
  final String category;
  final double rating;
  final String? image;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    this.image,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),
      image: json['image'] as String?,
    );
  }
}