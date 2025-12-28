class Incident {
  final String id;
  final String type;
  final String description;
  final double lat;
  final double lng;
  final int upvotes;
  final bool verified;
  final String status;
  final String? imageUrl;

  Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.lat,
    required this.lng,
    required this.upvotes,
    required this.verified,
    required this.status,
    this.imageUrl,
  });
}
