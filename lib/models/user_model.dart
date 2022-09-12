import 'dart:convert';

class UserModel {
  final String username;
  final String email;
  final String profilePicUrl;
  final String uid; // unique for each user
  final String token;
  UserModel({
    required this.username,
    required this.email,
    required this.profilePicUrl,
    required this.uid,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'uid': uid,
      'token': token,
    };
  }

// retrieve data from json object in the following format
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      uid: map['_id'] ?? '', // _id is the key in the json object not uid
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap()); // encode to string from usermodel to send to server(as url take string)

// using the string sent from server, decode it to json object and convert it to UserModel object
  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

// to get the object and change it's values
  UserModel copyWith({
    String? username,
    String? email,
    String? profilePicUrl,
    String? uid,
    String? token,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}
