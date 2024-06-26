import 'package:flutter/material.dart';
import 'stateHandler.dart';

class PasswordDimenticata extends StatefulWidget {
  const PasswordDimenticata({super.key});

  @override
  State<PasswordDimenticata> createState() => _PasswordDimenticataState();
}

class _PasswordDimenticataState extends State<PasswordDimenticata> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final bool _obscureText = true;

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Benvenuto su Odyssey"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ClipOval(
                  child: SizedBox.fromSize(
                      size: const Size.fromRadius(90),
                      child: Image.asset(
                        "images/logo.jpeg",
                        fit: BoxFit.cover,
                      ))),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(children: <Widget>[
                  TextField(
                    controller: _usernameController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(labelText: 'Mail'),
                  )
                ]),
              ),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        var mail = _usernameController.text.trim().toLowerCase();
                        if (mail.isEmpty) {
                          displayDialog(context, "Errore", "Inserisci la tua mail");
                          return;
                        }
                        displayDialog(
                            context, "Password Reset", "Ti abbiamo inviato una mail per resettare la password");
                        await pb.collection('users').requestPasswordReset(mail);
                      },
                      child: const Text(
                        "Invia Mail di recupero",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
