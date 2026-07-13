class GuardianModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String relation;

  GuardianModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.relation,
  });

  factory GuardianModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GuardianModel(
      id: documentId,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
      relation: data['relation'] ?? 'Guardian',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'relation': relation,
    };
  }
}
