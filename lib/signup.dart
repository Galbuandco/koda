//import 'package:Odyssey/autenticazione/eula.dart';
import 'login.dart';
import 'package:flutter/gestures.dart';
import 'package:pocketbase/pocketbase.dart';
import 'stateHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';

const default_link_avatars = {
  "F": "https://projectodyssey.it/api/files/gghip0969q05e62/gzn9ryx7fa8suy1/girl1_yG0G48dUtP.png",
  "M": "https://projectodyssey.it/api/files/gghip0969q05e62/dtm9u04cqppktlu/dall_e_2023_03_14_11_44_33_4hJygxnR03.png",
  "": "https://projectodyssey.it/api/files/gghip0969q05e62/5hlu83onng5yr75/nexplorer_jmKAl36PFU.jpg"
};

const default_id_avatars = {"F": "y861dum2uvpaqdv", "M": "dtm9u04cqppktlu", "": "5hlu83onng5yr75"};

void _showScrollableDialog(RichText contentText, context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('EULA'),
        content: SingleChildScrollView(
          child: contentText,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

DateTime _selectedDate = DateTime.now();

void signup(body) async {
  await pb.collection('users').create(body: body);
}

bool validateInput(dynamic input) {
  if (input != null) {
    DateTime now = DateTime.now();
    Duration ageDifference = now.difference(input);
    int ageInYears = ageDifference.inDays ~/ 365;
    return ageInYears >= 18;
  } else {
    return false;
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordconfirmationController = TextEditingController();
  var data_di_nascita;
  void _showDatePicker() async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: DateTime(2023),
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.it,
      looping: false,
    );
    var data_stringa = datePicked!.toLocal().toString().split(' ')[0];
    _dateController.text = data_stringa;

    data_di_nascita = datePicked;
  }

  final TextEditingController _mailController = TextEditingController();

  String sessoController = 'M';

  List<DropdownMenuItem<String>> genders = [
    const DropdownMenuItem<String>(
      value: 'M',
      child: Text('Uomo'),
    ),
    const DropdownMenuItem<String>(
      value: 'F',
      child: Text('Donna'),
    ),
    const DropdownMenuItem<String>(
      value: '',
      child: Text('Preferisco non specificare'),
    ),
  ];

  final TextEditingController _dateController = TextEditingController();

  bool _acceptedEULA = false;
  bool _obscurePsw = true;
  bool _obscureCheckPsw = true;
  bool _registrazioneTry = false;

/*   Future<String?> attemptLogIn(String username, String password) async {
    var res = await http.post(login,headers: {"content-type":"application/json"},
        body: '{"nickname":"$username", "password": "$password"}');

    if (res.body != 'Combinazione Nickname e Password Invalida'){
      return res.body;
    }else{
      return null;
    }
  }

  Future<int> attemptSignUp(String username, String password) async {
    var res = await http.post(signup,headers: {"content-type":"application/json"},
        body: '{"nickname":"$username", "password": "$password"}');

    return res.statusCode;
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Benvenuto su Koda"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePsw,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePsw = !_obscurePsw;
                      });
                    },
                    child: Icon(_obscurePsw ? Icons.visibility_off : Icons.visibility),
                  ),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              TextField(
                controller: _passwordconfirmationController,
                obscureText: _obscureCheckPsw,
                decoration: InputDecoration(
                  labelText: 'Conferma password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureCheckPsw = !_obscureCheckPsw;
                      });
                    },
                    child: Icon(_obscureCheckPsw ? Icons.visibility_off : Icons.visibility),
                  ),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              TextField(
                controller: _mailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _showDatePicker,
                decoration: InputDecoration(
                  labelText: 'Data di nascita',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 37, 4)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("Sesso"),
              ),
              DropdownButtonFormField<String>(
                value: sessoController,
                items: genders,
                onChanged: (value) {
                  setState(() {
                    sessoController = value!;
                  });
                },
              ),
              Row(
                children: <Widget>[
                  /*  Checkbox(
                    value: _acceptedEULA,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _acceptedEULA = newValue!;
                      });
                    },
                  ), */
                  /*          RichText(
                    text: TextSpan(
                      text: 'Ho letto ed accetto l\'',
                     
                      children: [
                        TextSpan(
                          text: 'EULA',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _showScrollableDialog(eula_text, context);
                            },
                        ),
                      ],
                    ),
                  ),*/
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        //if (_acceptedEULA) {
                        if (true) {
                          setState(() {
                            _registrazioneTry = true; // Show loading state
                          });
                          var registrazione_riuscita = await registrazione(
                                  context,
                                  _usernameController.text.trim().toLowerCase(),
                                  _passwordController.text,
                                  _passwordconfirmationController.text,
                                  _mailController.text.trim().toLowerCase(),
                                  data_di_nascita,
                                  sessoController)
                              .catchError((err) {
                            setState(() {
                              _registrazioneTry = false; // Show loading state
                            });
                          });

                          if (registrazione_riuscita) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => const LoginPage()));
                              displayDialog(context, "Registrazione riuscita",
                                  "La registrazione è stata effettuata con successo!");
                            });
                          }

                          setState(() {
                            _registrazioneTry = false; // Show loading state
                          });
                        } else {
                          displayDialog(context, "Errore", "Devi accettare l'EULA.");
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        padding:
                            MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                        //textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      child: _registrazioneTry
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Registrati",
                              style: TextStyle(fontSize: 20, color: Colors.green),
                            )),
                ),
              ),
              //ShinyButton()
            ],
          ),
        ));
  }
}

Future<bool> registrazione(
    context, username, password, passwordConfirmation, mail, data_di_nascita, sessoController) async {
  bool risultato = false;
  if (password == passwordConfirmation) {
    if (password.length < 8) {
      displayDialog(context, "Errore", "La password non è abbastanza lunga");
    } else if (validateInput(data_di_nascita)) {
      await pb.collection('users').create(body: {
        "username": username,
        "email": mail,
        "password": password,
        "passwordConfirm": password,
        "data_di_nascita": DateFormat('yyyy-MM-dd').format(data_di_nascita),
        "sesso": sessoController,
        // "avatar": default_id_avatars[sessoController],
        //"provincia": "v11w1sr36e16qk0" //mette monza e brianza di default
      }).then((value) {
        pb.collection("collagene").create(body: {
          "user": value.toJson()["id"],
          "link_immagine_profilo": default_link_avatars[sessoController],
          "username": username,
        });
        risultato = true;
      }).catchError((err) {
        var tipo_errore = err.response["data"];
        var key = tipo_errore.keys.first;
        if (err.response["data"][key]["message"].toString() == "The username is invalid or already in use.") {
          displayDialog(context, "Errore", "Questo username è già utilizzato");
        } else if (err.response["data"][key]["message"].toString() == "The email is invalid or already in use.") {
          displayDialog(context, "Errore", "Questa mail è già utilizzata");
        } else {
          displayDialog(context, "Errore", "C'è stato un errore nella tua richiesta");
        }
        risultato = false;
        return risultato;
      });
    } else {
      displayDialog(context, "Errore", "Inserisci una data di nascita valida (devi avere almeno 18 anni)");
    }
  } else {
    displayDialog(context, "Errore", "Le due password non coincidono");
    risultato = false;
    return risultato;
  }

  pb.collection("users").requestVerification(mail);
  return risultato;
}

void displayDialog(context, title, text) => showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text(title), content: Text(text)),
    );
