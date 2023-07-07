import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/screens/auth/login_screen.dart';
import 'package:test_project/utils/next_screen.dart';
import 'package:test_project/utils/utils.dart';

import '../provider/sign_in_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // getUserDetails();
    // getData();
    super.initState();
    getData().then((value) {
      setState(() {
        isDataLoaded = true;
      });
    });
  }

  String name = "";
  String email = "";
  String imageURL = "";
  String provider = "";
  bool isDataLoaded = false;
  double profileImageHeight = 144;
  double coverHeight = 280;

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _name = await prefs.getString("name")!;
    String _email = await prefs.getString("email")!;
    String _imageUrl = await prefs.getString("image_url")!;
    String _provider = await prefs.getString("provider")!;
    setState(() {
      name = _name;
      email = _email;
      imageURL = _imageUrl;
      provider = _provider;
    });
  }

  Future getUserDetails() async {
    final signInProvider = context.read<SignInProvider>();
    signInProvider.getDataFromSharedPreferences();
    setState(() {
      isDataLoaded = true;
    });
    print("USER DATA  " +
        signInProvider.getDataFromSharedPreferences().toString());
  }

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileImageHeight / 2;
    final sp = context.read<SignInProvider>();
    return Scaffold(
        body: Container(
      child: Column(
        children: [
         
          isDataLoaded == false
              ? Center(child: CircularProgressIndicator())
              // ignore: unnecessary_null_comparison
              : name != null
                  ? ListView(
                      shrinkWrap: true,
                      children: [
                        buildImageSection(
                            top, Utils.welcome_user_url, imageURL),
                        SizedBox(
                          height: 20,
                        ),
                        buildUserContentSection(name, email, provider),
                      ],
                    )
                 
                  : Text("Failed to fetched Data"),
          Center(
            child: ElevatedButton(
              onPressed: () {
                sp.userSignOut();
                nextScreenReplace(context, LoginScreen());
              },
              child: Text("Sign out"),
            ),
          ),
        ],
      ),
    ));
  }

  buildImageSection(double topV, backgroundURL, profileURL) {
    final bottomMarginValue = profileImageHeight / 2;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottomMarginValue),
          child: buildThumbnailImage(backgroundURL),
        ),
        Positioned(
          top: topV,
          child: buildProfileImage(profileURL),
        )
      ],
    );
  }

  buildThumbnailImage(String thumbnailURL) {
    return Container(
      width: double.infinity,
      height: coverHeight,
      child: Image.network(
        thumbnailURL,
        fit: BoxFit.cover,
      ),
    );
  }

  buildProfileImage(String imageURL) {
    return CircleAvatar(
      radius: profileImageHeight / 2,
      backgroundImage: NetworkImage(imageURL),
    );
  }

  // Content Section
  buildUserContentSection(name, email, provider) {
    final space = profileImageHeight / 10;
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: space,
        ),
        Text(
          email,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: space,
        ),
        Divider(
          thickness: 1,
        ),
        Text(
          "PROVIDER USED",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          provider,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
