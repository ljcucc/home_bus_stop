class ApiSuggestion {
  final String name;
  final String? lat;
  final String? lon;

  const ApiSuggestion({required this.name, this.lat, this.lon});

  factory ApiSuggestion.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'name': String name} => ApiSuggestion(
          name: name,
          lat: json['lat'] as String?,
          lon: json['lon'] as String?,
        ),
      _ => throw const FormatException('Invalid ApiSuggestion JSON'),
    };
  }

  Map<String, dynamic> toJson() => {'name': name, 'lat': lat, 'lon': lon};
}
