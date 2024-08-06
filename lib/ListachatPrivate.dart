import 'package:koda/PocketbaseMethods.dart';
import 'package:koda/amicizie.dart';
import 'chatMultimediale.dart';
import 'package:koda/chatPrivataSospetta.dart';

import 'stateHandler.dart';
import 'package:flutter/material.dart';

class ListaChat extends StatefulWidget {
  const ListaChat({super.key});

  @override
  State<ListaChat> createState() => _ListaChatState();
}

void _showReportDialog(context, amico, io) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Segnala Utente'),
        content: const Text('Sei sicuro di voler segnalare questo utente?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Report'),
            onPressed: () async {
              // TODO: Implement report user functionality
              pb
                  .collection("amicizie")
                  .getFirstListItem('username_amico="$amico" && user.id="$io"')
                  .then((value) => value.id)
                  .then((value) => pb.collection("amicizie").delete(value));
              //rimuoviAmicizia(id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _ListaChatState extends State<ListaChat> {
  @override
  void dispose() {
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(indicazioni: "")));
    super.dispose();
    //MaterialPageRoute(builder: (context) => HomePage(indicazioni: ""));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getListaChat(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                      toolbarHeight: 40,
                      backgroundColor: const Color.fromARGB(234, 255, 255, 255),
                      foregroundColor: Theme.of(context).primaryColor,
                      title: const Text(
                        'Lista amici',
                        style:
                            TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.transparent, blurRadius: 2)]),
                      )),
                  body: Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Aggiungi un nuovo amico per iniziare a chattare!",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaginaAmicizie(), // Replace AmicizieWidget with the desired widget to navigate to
                              ),
                            );
                          },
                          child: const Text('Add Friend'),
                        ),
                      ],
                    ),
                  )));
            }
            var amici = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                  toolbarHeight: 40,
                  backgroundColor: const Color.fromARGB(234, 255, 255, 255),
                  foregroundColor: Theme.of(context).primaryColor,
                  title: const Text(
                    'Chat private',
                    style: TextStyle(color: Colors.green, shadows: [Shadow(color: Colors.transparent, blurRadius: 2)]),
                  )),
              body: ListView.builder(
                  itemCount: amici.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        onTap: () {
                          print(amici[index]["trusted"]);
                          if (amici[index]["trusted"]) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatWidget(
                                        targetUser: amici[index]["amico"],
                                        immagineprofilo: amici[index]["immagine_profilo"],
                                        username: amici[index]['username_amico'])));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatWidgetSospetto(
                                        targetUser: amici[index]["amico"],
                                        immagineprofilo: amici[index]["immagine_profilo"],
                                        username: amici[index]['username_amico'])));
                          }
                          setState(() {});
                        },
                        onLongPress: () {
                          //display a dialog to report user
                          _showReportDialog(context, amici[index]["username_amico"], pb.authStore.model.id);
                          //setState(() {});
                        },
                        leading: ClipOval(
                            child: SizedBox.fromSize(
                          size: const Size.fromRadius(20),
                          child: Container(color: Colors.green),
                        )),
                        title: Text(
                          ' ${amici[index]['username_amico'].toString().toUpperCase().substring(0, 1)}${amici[index]['username_amico'].toString().substring(1)}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: amici[index]["daLeggere"]
                              ? Text(
                                  amici[index]["anteprima"].toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  amici[index]["anteprima"].toString(),
                                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                                ),
                        ));
                  }),
            );
          }
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text('Lista chat private'),
                toolbarHeight: 40,
                backgroundColor: const Color.fromARGB(234, 255, 255, 255),
                foregroundColor: Theme.of(context).primaryColor,
              ),
              body: const Center(child: CircularProgressIndicator()));
        });
  }
}
