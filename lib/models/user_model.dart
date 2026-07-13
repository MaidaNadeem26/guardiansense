class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? homeAddress;
  final String? medicalNotes;
  final List<String> guardianIds;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.homeAddress,
    this.medicalNotes,
    this.guardianIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      homeAddress: data['homeAddress'],
      medicalNotes: data['medicalNotes'],
      guardianIds: List<String>.from(data['guardianIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'homeAddress': homeAddress,
      'medicalNotes': medicalNotes,
      'guardianIds': guardianIds,
    };
  }
}
