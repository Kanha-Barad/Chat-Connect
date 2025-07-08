class UserModel {
  final String uid;
  final String email;
  final String country;
  final String userName;
  final String mobile;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.country,
    required this.userName,
    required this.mobile,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'country': country,
      'userName': userName,
      'mobile': mobile,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      userName: json['userName'] ?? '',
      mobile: json['mobile'] ?? '',
      fcmToken: json['fcmToken'],
    );
  }
}
