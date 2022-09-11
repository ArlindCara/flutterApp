import 'package:flutter/material.dart';
import 'package:my_app/screens/selectMainScreen.dart';
import 'package:my_app/screens/signInScreen.dart';
import 'package:my_app/utils/firebaseUtils.dart';
import 'package:my_app/utils/loginRegisterData.dart';
import 'package:my_app/widgets/loginRegisterAlert.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // chiamate a firebaseutils
  FirebaseUtils fbUtils = FirebaseUtils();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool loaded = false;

  Future<bool> finishedRegistration() async {
    setState(() {
      loaded = false;
    });
    LoginRegisterData userLogged = await fbUtils.registerLocal(
        emailController.text, passwordController.text);

    if (userLogged.userCredential == true) {
      setState(() {
        loaded = true;
      });
      return loaded;
    } else {
      if (userLogged.error != null) {
        String error = userLogged.error as String;

        loginregisterAlert(error: error, context: context);
      }
      return loaded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authenticate"),
        backgroundColor: Colors.white,
      ),
      body: loaded == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'REGISTER',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 50.0,
                            color: Colors.blue),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: Icon(Icons.remove_red_eye),
                        ),
                      ),
                      Row(),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (await finishedRegistration() == true) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelectMainScreen()));
                            } else if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              loginregisterAlert(
                                  error: 'Empty email or password',
                                  context: context);
                            }
                          },
                          color: Colors.blue,
                          child: Text(
                            'REGISTER',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Divider(
                        color: Colors.black,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '''Already have an account? ''',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16.0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInScreen()));
                            },
                            child: Text('Login'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/*
classe con stringa nullable

showalert in widget

*/
