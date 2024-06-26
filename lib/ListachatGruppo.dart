import 'package:koda/PocketbaseMethods.dart';
import 'package:koda/amicizie.dart';
import 'package:koda/chatGruppi.dart';
import 'package:pocketbase/pocketbase.dart';
import 'stateHandler.dart';
import 'chatPrivata.dart';
import 'package:flutter/material.dart';

class ListaChatGruppi extends StatefulWidget {
  const ListaChatGruppi({super.key});

  @override
  State<ListaChatGruppi> createState() => _ListaChatGruppiState();
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

class _ListaChatGruppiState extends State<ListaChatGruppi> {
  @override
  void dispose() {
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(indicazioni: "")));
    super.dispose();
    //MaterialPageRoute(builder: (context) => HomePage(indicazioni: ""));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResultList<RecordModel>>(
        future: getListaChatGroup(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.items.isEmpty) {
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
                        Padding(
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
                          child: Text('Add Friend'),
                        ),
                      ],
                    ),
                  )));
            }
            var amici = snapshot.data!.items;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                  toolbarHeight: 40,
                  backgroundColor: const Color.fromARGB(234, 255, 255, 255),
                  foregroundColor: Theme.of(context).primaryColor,
                  title: const Text(
                    'Chat di Gruppo',
                    style: TextStyle(color: Colors.green, shadows: [Shadow(color: Colors.transparent, blurRadius: 2)]),
                  )),
              body: ListView.builder(
                  itemCount: amici.length,
                  itemBuilder: (BuildContext context, int index) {
                    //print(amici[index]);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GruppiChatWidget(
                                          id: amici[index].id,
                                          name: amici[index].getStringValue("Name"),
                                        )));
                          },
                          leading: ClipOval(
                              child: SizedBox.fromSize(
                            size: const Size.fromRadius(20),
                            child: Container(color: Colors.green),
                          )),
                          contentPadding: const EdgeInsets.all(8),
                          subtitle: FutureBuilder(
                              future: pb.collection('groups').getFirstListItem('id="${amici[index].id}"'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data!.getStringValue("members").split(", ").length.toString() +
                                      " partecipanti");
                                }
                                return const Text("Caricamento...");
                              }),
                          title: Text(
                            amici[index].getStringValue("Name").toUpperCase().substring(0, 1) +
                                amici[index].getStringValue("Name").substring(1),
                            style: TextStyle(fontSize: 18),
                          )),
                    );
                  }),
            );
          }
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text('Lista amici'),
                toolbarHeight: 40,
                backgroundColor: const Color.fromARGB(234, 255, 255, 255),
                foregroundColor: Theme.of(context).primaryColor,
              ),
              body: const Center(child: CircularProgressIndicator()));
        });
  }
}

Future<ResultList<RecordModel>> getListaChatGroup() async {
  //print('"members" ~ "${pb.authStore.model.id}"');
  final resultList = await pb.collection('groups').getList(
        page: 1,
        perPage: 50,
        filter: 'members ~ "${pb.authStore.model.id}"',
      );

  //print(resultList);
  return resultList;
}
