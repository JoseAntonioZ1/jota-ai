class Contact {
  const Contact({required this.id, required this.name, required this.phoneNumber, this.photoUrl});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final String id;
  final String name;
  final String phoneNumber;
  final String? photoUrl;
}
