import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_app/screens/selectMainScreen.dart';
import 'package:my_app/screens/signInScreen.dart';

class SplashScreen extends StatelessWidget {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue.shade300,
      ),
      debugShowCheckedModeBanner: false,

      home: firebaseUser != null ? SelectMainScreen() : SignInScreen(),

      //pagina oer far evdere login o tutta l'app
    );
  }
}
