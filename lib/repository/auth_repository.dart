import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdocs/constants/constants.dart';
import 'package:vdocs/models/error_model.dart';
import 'package:vdocs/models/user_model.dart';
import 'package:vdocs/repository/local_storage.dart';

// create provider of current class and pass instance fo google signin class
final authRepoProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client(), localStorage: LocalStorageRepo()),
);
// by using provider we reduce creating instance of class AuthRepository and passing googleSignIn instance

// above authRepoProvider is a read only provider meaning we cannot change its object values, for changing user data we have to use StateProvider
// or create a StateNotifier class and use StateNotifierProvider(more complex than StateProvider)
final userProvider = StateProvider<UserModel?>((ref) {
  return null;
});
// the type is UserModel? because initially the user can be null so we want to return null for that otherwise usermodel

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client; // we can use requests but we use http package for testing and so we use client
  final LocalStorageRepo _localStorage; // better to take as parameter so we can mock it in tests
  AuthRepository(
      {required GoogleSignIn googleSignIn, required Client client, required LocalStorageRepo localStorage})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorage = localStorage;
  // scope of client and googleSignIn non private variables inside this constructor only

  /// signIn method returns UserModel object if user is signed in successfully by sending request to server
  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(error: 'unexpected error in signInWithGoogle method', data: null);
    try {
      final userAccount = await _googleSignIn.signIn(); // returns future google account
      if (userAccount != null) {
        final user = UserModel(
            username: userAccount.displayName ?? '', // can be null too
            email: userAccount.email,
            profilePicUrl: userAccount.photoUrl ?? '', // default pic can be null
            uid: '', // uid and token are not available in google account
            token: ''); // so keep them empty as we generate in backend

        // send user data to backend
        var res = await _client.post(Uri.parse('$host/api/signup'), body: user.toJson(), headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        }); // send the request to specified url as URI object and store the result in res

        switch (res.statusCode) {
          case 200:
            {
              // email and other parameters are final so cant change so use the above usermodel values
              final newUser = user.copyWith(
                uid: jsonDecode(res.body)['user']['_id'], // making mongoose object id as user id
                token: jsonDecode(res.body)['token'], // get tokn send from response
                // '_id' value(see thunderclient post request response)
              );
              // use req on server side and res on client side
              error = ErrorModel(error: null, data: newUser); // no error so send data
              _localStorage.setToken(newUser.token); // save token in local storage
            }
            break;
          default:
            debugPrint('error in signInWithGoogle method');
        }
      }
    } catch (err) {
      debugPrint(err.toString());
      error = ErrorModel(error: err.toString(), data: null);
    }
    return error; // make sure to return it outside the try-catch block
  }

  Future<ErrorModel> getuserData() async {
    ErrorModel error = ErrorModel(error: 'unexpected error in signInWithGoogle method', data: null);

    try {
      // get token from local storage, if token is null then user is not signed in
      // if not null, get the user based on that token
      String? token = await _localStorage.getToken();
      if (token != null) {
        // get user data from backend using token, get rquest has no body
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token // pas token in header
        }); // send the request to specified url as URI object and store the result in res

        switch (res.statusCode) {
          case 200:
            {
              // email and other parameters are final so cant change so use the above usermodel values
              final userJson = jsonDecode(res.body)['user']; // decode the string to map and from 'user' object get
              // convert the user object to json string and then to UserModel object
              final newUser =
                  UserModel.fromJson(jsonEncode(userJson)).copyWith(token: token); // use token from local storage

              // use req on server side and res on client side
              error = ErrorModel(error: null, data: newUser); // no error so send data
              _localStorage.setToken(newUser.token); // save token in local storage
            }
            break;
          default:
            debugPrint('error in signInWithGoogle method');
        }
      }
    } catch (err) {
      debugPrint(err.toString());
      error = ErrorModel(error: err.toString(), data: null);
    }
    return error; // make sure to return it outside the try-catch block
  }

  /// signout by removing the token from local storage
  Future<void> signOut() async {
    await _googleSignIn.disconnect(); // disconnect otherwise next time login wont ask for email
    _localStorage.setToken(''); // set token to empty string
  }
}


// dont initialize the googlesignin, take it from the constructor as easier for testing
// Note we cannot simply take required this._googleSignIn as constructor argument as it is private
// so take a google signin as constructor argument and assign it to the private variable
// the scope of googleSignIn is limited to constructor only and then we assign _googleSignIn to it
