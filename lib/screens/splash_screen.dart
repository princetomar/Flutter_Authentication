import 'dart:async';
import 'package:test_project/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_project/provider/sign_in_provider.dart';
import 'package:test_project/screens/auth/login_screen.dart';
import 'package:test_project/screens/home_Screen.dart';
import 'package:test_project/utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // calling the sign in provider
    final signInProvider = context.read<SignInProvider>();
    super.initState();

    // A timer of 2 seconds in which we're fetching the isSignnedIn boolean value from the local storage
    Timer.periodic(Duration(seconds: 2), (timer) {
      signInProvider.isSignedIn == false
          ? nextScreenReplace(context, LoginScreen())
          : nextScreenReplace(context, HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            Utils.splash_icon,
            fit: BoxFit.cover,
            width: 200,
          ),
        ),
      ),
    );
  }
}
