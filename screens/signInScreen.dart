import 'package:flutter/material.dart';
import 'package:my_app/screens/registerScreen.dart';
import 'package:my_app/screens/selectMainScreen.dart';
import 'package:my_app/utils/firebaseUtils.dart';
import 'package:my_app/utils/loginRegisterData.dart';
import 'package:my_app/widgets/loginRegisterAlert.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // chiamate a firebaseutils
  FirebaseUtils fbUtils = FirebaseUtils();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool loaded = false;

  Future<bool> finishedLogin() async {
    setState(() {
      loaded = false;
    });
    /* String result = await fbUtils.signInLocal(
        emailController.text, passwordController.text, context);
    */
    LoginRegisterData userLogged = await fbUtils.signInLocal(
        emailController.text, passwordController.text);

    if (userLogged.userCredential == true) {
      print('entrato corretto signIn');
      setState(() {
        loaded = true;
      });
      return loaded;
    } else {
      print('entrato sbagliato signIn');
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
                        'LOGIN',
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
                            if (await finishedLogin() == true) {
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
                            'LOGIN',
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
                            '''Don't have an account? ''',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16.0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()));
                            },
                            child: Text('Register Now'),
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
