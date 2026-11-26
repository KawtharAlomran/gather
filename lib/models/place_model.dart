class Place {
  final String placeId;
  final String name;
  final String category;
  final String address;
  final String? cuisine;
  final String? openingHours;
  final String? phone;
  final String? website;
  final double latitude;
  final double longitude;
  final bool outdoorSeating;

  const Place({
    required this.placeId,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.cuisine,
    this.openingHours,
    this.phone,
    this.website,
    this.outdoorSeating = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['placeId']?.toString() ?? '',
      name: json['name']?.toString() ??
          'Unnamed restaurant',
      category: json['category']?.toString() ??
          'Restaurant',
      address: json['address']?.toString() ??
          'Address unavailable',
      cuisine: json['cuisine']?.toString(),
      openingHours: json['openingHours']?.toString(),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      outdoorSeating: json['outdoorSeating'] == true,
    );
  }

}
