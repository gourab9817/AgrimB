// User model for authentication
class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? idNumber;
  final bool isEmailVerified;
  final String? profilePictureUrl;
  final bool profileVerified;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.idNumber,
    this.isEmailVerified = false,
    this.profilePictureUrl,
    this.profileVerified = false,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      idNumber: json['idNumber'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      profilePictureUrl: json['profilePictureUrl'],
      profileVerified: json['profileVerified'] ?? false,
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'idNumber': idNumber,
      'isEmailVerified': isEmailVerified,
      'profilePictureUrl': profilePictureUrl,
      'profileVerified': profileVerified,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? address,
    String? idNumber,
    bool? isEmailVerified,
    String? profilePictureUrl,
    bool? profileVerified,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      idNumber: idNumber ?? this.idNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileVerified: profileVerified ?? this.profileVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
} 