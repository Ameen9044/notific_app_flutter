import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as googlefonts;
import 'package:notific_app/LoginPage.dart';
import 'package:notific_app/SignUpAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notific_app/homePage.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() {
    return _SignUpPage();
  }
}

class _SignUpPage extends State<SignUpPage> {
  final SignUpAuth _signUpAuth = SignUpAuth();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("NotifiME",
              style: googlefonts.GoogleFonts.protestRevolution(fontSize: 45)),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Name"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Email"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Password"),
                ),
                SizedBox(
                  height: 10,
                ),
                Builder(builder: (BuildContext newContext) {
                  return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(double.maxFinite, 50),
                          backgroundColor: Colors.blue[100]),
                      onPressed: () async {
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (Route<dynamic> route) => false);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            showSnackbar(newContext, "Weak Password");
                          } else if (e.code == 'email-already-in-use') {
                            showSnackbar(newContext, "Already Exists");
                          } else if (e.code == 'email-already-in-use') {
                            showSnackbar(newContext, "Already Exists");
                          } else {
                            showSnackbar(
                                newContext, "An error occurred: ${e.message}");
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Text(
                        "SIGNUP",
                        style: googlefonts.GoogleFonts.aBeeZee(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ));
                }),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
