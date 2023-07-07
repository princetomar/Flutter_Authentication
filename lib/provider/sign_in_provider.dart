import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  //-----------------------------------------------------------------
  // Instance variables
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // ----------------------------------------------------------------

  // value to check if the user is signed in or not
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  // for cloud firestore
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  // function to sign in the user
  SignInProvider() {
    checkSignInUser();
  }

  // ----------------------------------------------------------------
  // FUNCTION TO CHECK if the user is signed in
  // ----------------------------------------------------------------
  Future checkSignInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool("isSignedIn") ?? false;
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // FUNCTION TO SET SIGN IN TO TRUE
  // ----------------------------------------------------------------
  Future setSignIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isSignedIn", true);
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // FUNCTION TO SIGN IN WITH PHONE
  // ----------------------------------------------------------------
  void phoneNumberUser(User user, email, name) {
    _name = name;
    _email = email;
    _imageUrl =
        "https://img.freepik.com/free-photo/portrait-happy-male-with-broad-smile_176532-8175.jpg?size=626&ext=jpg";
    _uid = user.phoneNumber;
    _provider = "PHONE";
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // FUNCTION TO SIGN IN WITH GOOGLE
  // ----------------------------------------------------------------
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // execute authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // SIGN IN TO FIREBASE USER INSTANCE

        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // let's save all the user information
        _name = userDetails.displayName!;
        _email = userDetails.email!;
        _imageUrl = userDetails.photoURL!;
        _provider = "GOOGLE";
        _uid = userDetails.uid;

        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------
  // ENTRY FOR CLOUDFIRESTORE, GET EXISTING USER DETAILS
  // ----------------------------------------------------------------
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _uid = snapshot['uid'];
      _name = snapshot['name'];
      _email = snapshot['email'];
      _imageUrl = snapshot['image_url'];
      _provider = snapshot['provider'];
    });
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // ENTRY FOR CLOUDFIRESTORE, CREATE A NEW CLOUDFIRESTORE USER
  // ----------------------------------------------------------------
  Future saveDataToFirestore() async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await reference.set({
      "name": _name,
      "email": _email,
      "uid": _uid,
      "image_url": _imageUrl,
      "provider": _provider,
    });

    notifyListeners();
  }

  // ----------------------------------------------------------------
  // SAVE DATA TO SHAREDPREFERENCES
  // ----------------------------------------------------------------
  Future saveDataToSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", _name!);
    await prefs.setString("email", _email!);
    await prefs.setString("uid", _uid!);
    await prefs.setString("image_url", _imageUrl!);
    await prefs.setString("provider", _provider!);
  }

  // ----------------------------------------------------------------
  // GET DATA FROM SHAREDPREFERENCES
  // ----------------------------------------------------------------
  Future getDataFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = await prefs.getString("name");
    _email = await prefs.getString("email");
    _uid = await prefs.getString("uid");
    _imageUrl = await prefs.getString("image_url");
    _provider = await prefs.getString("provider");
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // CHECK USER EXISTS OR NOT
  // ----------------------------------------------------------------
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection("users").doc(_uid).get();

    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // ----------------------------------------------------------------
  // SIGN OUT
  // ----------------------------------------------------------------
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();

    // clear all storage information
    clearStorageData();
  }

  // ----------------------------------------------------------------
  // FUNCTION TO CLEAR STORAGE
  // ----------------------------------------------------------------
  Future clearStorageData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
