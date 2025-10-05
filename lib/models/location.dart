class Location {
  final String id;
  final String name;
  final String country;
  final String? state;
  final String? city;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final bool isCurrentLocation;

  Location({
    required this.id,
    required this.name,
    required this.country,
    this.state,
    this.city,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    this.isCurrentLocation = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isCurrentLocation': isCurrentLocation,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isCurrentLocation: json['isCurrentLocation'] ?? false,
    );
  }

  @override
  String toString() {
    if (city != null && state != null) {
      return '$city, $state, $country';
    }
    return '$name, $country';
  }

  // Check if location is stale (older than 1 day)
  bool get isStale {
    return DateTime.now().difference(lastUpdated).inDays > 1;
  }
}