class UserModel {
  final String uid;
  final String phone;
  final String? name;
  final String? address;
  final String? email;
  final String? photoUrl;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phone,
    this.name,
    this.address,
    this.email,
    this.photoUrl,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phone: map['phone'] ?? '',
      name: map['name'],
      address: map['address'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'address': address,
      'email': email,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
