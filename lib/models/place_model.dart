class Place{
  final String googlePlaceId;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String? image;
  final String address;
  final String? googleMapsUrl;

  const Place({
    required this.googlePlaceId,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.address,
    this.image,
    this.googleMapsUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      googlePlaceId: json['googlePlaceId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      address: json['address'] as String,
      image: json['image'] as String?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
    );
  }
}