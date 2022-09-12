import 'package:shared_preferences/shared_preferences.dart';

/// class LocalStorage to store the jwt token in local storage for saving the user signin info
class LocalStorageRepo {
  /// save token passed in parameter to local storage for authenticating and authorising current user
  void setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // get instance of local storage created
    prefs.setString('x-auth-token', token); // store the token as key-value pair
  }

  /// get user token from local storage
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token'); // get the token from local storage
    return token;
  }
}
