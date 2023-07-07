import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:test_project/provider/internet_provider.dart';
import 'package:test_project/provider/sign_in_provider.dart';
import 'package:test_project/screens/auth/phone_auth/phone_auth_screen.dart';
import 'package:test_project/screens/home_Screen.dart';
import 'package:test_project/utils/next_screen.dart';
import 'package:test_project/utils/toast_tile.dart';
import 'package:test_project/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneAuthController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: 80,
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Utils.login_icon2,
                      color: Colors.black,
                      width: 200,
                      height: 200,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "FLUTTER AUTH PROJECT",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GOOGLE AUTHENTICATION BUTTON
                  RoundedLoadingButton(
                    controller: googleController,
                    color: Colors.red,
                    successColor: Colors.redAccent,
                    width: MediaQuery.of(context).size.width * 0.8,
                    borderRadius: 25,
                    elevation: 8,
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    child: Wrap(
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 24,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // PHONE AUTHENTICATION BUTTON
                  RoundedLoadingButton(
                    controller: phoneAuthController,
                    color: Colors.black,
                    successColor: Colors.black,
                    width: MediaQuery.of(context).size.width * 0.8,
                    borderRadius: 25,
                    elevation: 8,
                    onPressed: () {
                      nextScreenReplace(
                        context,
                        PhoneAuthScreen(),
                      );
                      phoneAuthController.reset();
                    },
                    child: Wrap(
                      children: [
                        Icon(
                          FontAwesomeIcons.phone,
                          size: 24,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          "Sign in with Phone",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // function to handle google sign in
  Future handleGoogleSignIn() async {
    final signInProvider = context.read<SignInProvider>();
    // checking internet connectivity
    final internetProvider = context.read<InternetProvider>();

    // check internet connectivity
    await internetProvider.checkInternetConnection();

    if (internetProvider.hasInternet == false) {
      showToastTile(context, "CHECK INTERNET CONNECTION", Colors.red);
      googleController.reset();
    } else {
      await signInProvider.signInWithGoogle().then((value) {
        if (signInProvider.hasError == true) {
          showToastTile(
              context, signInProvider.errorCode.toString(), Colors.red);
        } else {
          // check if the user exists or not
          signInProvider.checkUserExists().then((value) async {
            if (value == true) {
              // user already exists
              await signInProvider
                  .getUserDataFromFirestore(signInProvider.uid)
                  .then((value) => signInProvider
                      .saveDataToSharedPreferences()
                      .then((value) => signInProvider.setSignIn().then((value) {
                            googleController.success();
                            handleAfterSignIn();
                          })));
            } else {
              signInProvider.saveDataToFirestore().then((value) {
                signInProvider.saveDataToSharedPreferences().then((value) {
                  signInProvider.setSignIn().then((value) {
                    googleController.success();
                    handleAfterSignIn();
                  });
                });
              });
            }
          });
        }
      });
    }
  }

  // ----------------------------------------------------------------
  // HANDLE AFTER SIGN IN
  // ----------------------------------------------------------------
  handleAfterSignIn() {
    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, HomeScreen());
    });
  }
}
