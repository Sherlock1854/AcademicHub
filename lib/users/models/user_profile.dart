class UserProfile {
  final String uid;
  final String name;
  final String gender;
  final int age;
  final String photoUrl;
  final String description;
  final String role;

  UserProfile({
    required this.uid,
    required this.name,
    required this.gender,
    required this.age,
    required this.photoUrl,
    required this.description,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Not specified',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'] ??
          'https://firebasestorage.googleapis.com/v0/b/academichub-c1068.appspot.com/o/profile%2Fdefault_user.png?alt=media',
      description: map['description'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,
      'description': description,
      'role': role,
    };
  }
}
