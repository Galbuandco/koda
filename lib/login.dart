import 'dart:convert';
import 'package:koda/ListachatPrivate.dart';
import 'passworddimenticata.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dataModel.dart';
import 'dart:ui';
import 'stateHandler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Benvenuto su Koda"),
      ),
      body: Container(
        //decoration: BoxDecoration(
        //image: DecorationImage(
        //image: AssetImage('images/Odissey_Project.png'),
        //fit: BoxFit.cover,
        //),
        //),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ClipOval(
                        child: SizedBox.fromSize(
                            size: const Size.fromRadius(90),
                            child: Image.asset(
                              "assets/images/logo.jpeg",
                              fit: BoxFit.cover,
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            cursorColor: Colors.green,
                            key: Key("username"),
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              // focusColor: Colors.green,
                              labelText: 'Mail / Username',
                              /*  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                              fillColor: Colors.green, // Add this line to make the bar green
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green), // Add this line to make the border green
                              ), */
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            cursorColor: Colors.green,
                            key: Key("password"),
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: const InputDecoration(
                              // focusColor: Colors.green,
                              labelText: 'Password',
                              /* labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                              fillColor: Colors.green, // Add this line to make the bar green
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green), // Add this line to make the border green
                              ), */
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Center(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                                  //textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                onPressed: () async {
                                  var mail = _usernameController.text.trim().toLowerCase();

                                  var password = _passwordController.text;

                                  await pb.collection('users').authWithPassword(mail, password).catchError((err) {
                                    displayDialog(context, "Errore!",
                                        "Non è stato trovato nessun account con questa Username e Password");
                                    return RecordAuth();
                                  });
                                  /* 
                                  await pb.collection('users').authWithPassword(mail, password).catchError((err) {
                                    displayDialog(context, "Errore!",
                                        "Non è stato trovato nessun account con questa Username e Password");
                                  }); */
                                  //storage.write(key: "username", value: auth.toJson()["usernameOrEmail"]);
                                  //storage.write(key: "password", value: auth.toJson()["password"]);
                                  if (pb.authStore.isValid) {
                                    storage.write(key: "token", value: pb.authStore.token);
                                    storage.write(key: "model", value: jsonEncode(pb.authStore.model));
                                    Data.initializeValues(pb.authStore.model.toJson()["username"],
                                        pb.authStore.model.toJson()["id"], pb.authStore.model.getIntValue("exp"));
                                    //posti_scaricati = await get_places();
                                    //if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => const ListaChat()));
                                  } else {
                                    //if (!context.mounted) return;
                                    displayDialog(context, "Errore!",
                                        "Non è stato trovato nessun account con questa combinazione di email e password");
                                  }
                                },
                                child: const Text(
                                  "Accedi",
                                  style: TextStyle(
                                    fontSize: 18,
                                    //fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  //foregroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                                  //   //textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                onPressed: () async {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                                },
                                child: const Text(
                                  "Registrati",
                                  style: TextStyle(
                                    fontSize: 18,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: const Text("Password Dimenticata?"),
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordDimenticata()));
                        },
                      ),
                    ),
                  ],
                ),
              ) // your content here
              ),
        ),
      ),
    );
  }
}
