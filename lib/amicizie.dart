import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koda/stateHandler.dart';
import 'PocketbaseMethods.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaginaAmicizie extends StatefulWidget {
  const PaginaAmicizie({super.key});

  @override
  State<PaginaAmicizie> createState() => _PaginaAmicizieState();
}

class _PaginaAmicizieState extends State<PaginaAmicizie> {
  var isLoading = false;

  final TextEditingController _usernameController = TextEditingController();

  void displayDialog(context, title) => showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(title)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true, // Add this line
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 5,
          toolbarHeight: 40,
          backgroundColor: const Color.fromARGB(234, 255, 255, 255),
          foregroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Aggiungi un amico",
            style: TextStyle(color: Colors.blue, shadows: [Shadow(color: Colors.transparent, blurRadius: 2)]),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<dynamic>(
            future: getlistaAmicizieAndRichieste(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Scaffold(
                  body: Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Theme.of(context).primaryColor,
                      rightDotColor: const Color.fromARGB(255, 0, 56, 102),
                      size: 50,
                    ),
                  ),
                );
              } else {
                var amici = [];
                snapshot.data[0].items.forEach((element) {
                  var temp = element.toJson();
                  var image = getAvatarFromUtente(element.getStringValue('amico'), snapshot.data[2]);
                  temp['immagine_profilo'] = image;
                  amici.add(temp);
                });
                var pending = [];
                snapshot.data[1].items.forEach((element) {
                  var temp = element.toJson();
                  var image = getAvatarFromUtente(element.getStringValue('richiedente'), snapshot.data[2]);
                  pending.add({
                    "nome": temp["username_richiedente"],
                    "id": temp["richiedente"],
                    "immagine_profilo": image,
                    "record_id": temp["id"],
                  });
                });
                return SafeArea(
                    minimum: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            // ignore: sort_child_properties_last
                            child: Row(mainAxisSize: MainAxisSize.max, children: [
                              Container(
                                width: (3 * MediaQuery.of(context).size.width / 4) - 10,
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(labelText: 'Username del tuo amico'),
                                ),
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  ),
                                  onPressed: () async {
                                    var username = _usernameController.text.toLowerCase();
                                    var id = await getIdFromUsername(username);
                                    if (id == "null") {
                                      AnimatedSnackBar.material(
                                              mobileSnackBarPosition: MobileSnackBarPosition.top,
                                              'Non esiste nessun utente con questo nome',
                                              type: AnimatedSnackBarType.error,
                                              duration: const Duration(seconds: 1))
                                          .show(context);
                                      return;
                                    } else if (await sendFriendRequest(id, username, amici)) {
                                      AnimatedSnackBar.material(
                                              mobileSnackBarPosition: MobileSnackBarPosition.top,
                                              'Richiesta Inviata',
                                              type: AnimatedSnackBarType.success,
                                              duration: const Duration(seconds: 1))
                                          .show(context);
                                    } else {
                                      AnimatedSnackBar.material(
                                              mobileSnackBarPosition: MobileSnackBarPosition.top,
                                              'Richiesta già inviata',
                                              type: AnimatedSnackBarType.info,
                                              duration: const Duration(seconds: 1))
                                          .show(context);
                                    }
                                  },
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                          size: 30,
                                        ))
                            ]),
                            //flex: 3,
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("I tuoi amici", style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                          Flexible(
                            flex: 8,
                            child: ListView.builder(
                                itemCount: amici.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      color: const Color.fromARGB(255, 36, 149, 241).withOpacity(0.30),
                                      child: ListTile(
                                        tileColor: Colors.white.withOpacity(0.50),
                                        onTap: () {
                                          /* Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Profilo(
                                                  id: amici[index]["amico"],
                                                  imageURL: amici[index]["immagine_profilo"],
                                                  user: amici[index]["username_amico"],
                                                ),
                                              )); */
                                        },
                                        leading: ClipOval(
                                            child: SizedBox.fromSize(
                                          size: const Size.fromRadius(20),
                                          child: CachedNetworkImage(
                                            imageUrl: amici[index]["immagine_profilo"],
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                        title: Text(
                                            ' ${amici[index]['username_amico'].toString().toUpperCase().substring(0, 1)}${amici[index]['username_amico'].toString().substring(1)}'),
                                        //subtitle: Text('User ${entries[index]}'),
                                      ));
                                }),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text("Richieste di amicizia", style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: ListView.builder(
                                itemCount: pending.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              // TODO: aggiungere valutazione
                                              title: const Text("Vuoi accettare la richiesta?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Sì"),
                                                  onPressed: () async {
                                                    accettaAmicizia(pending[index]);
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                    //TODO aggiorna widget state to update request list
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("No"),
                                                  onPressed: () async {
                                                    await pb
                                                        .collection('richieste')
                                                        .delete(pending[index]["record_id"]);
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        color: Colors.white.withOpacity(0.45),
                                        child: ListTile(
                                          leading: ClipOval(
                                              child: SizedBox.fromSize(
                                            size: const Size.fromRadius(20),
                                            child: CachedNetworkImage(
                                              imageUrl: pending[index]["immagine_profilo"],
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                          title: Text(
                                              ' ${pending[index]['nome'].toString().toUpperCase().substring(0, 1)}${pending[index]['nome'].toString().substring(1)}'),
                                          //subtitle: Text('User ${entries[index]}'),
                                        )),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ));
              }
            }));
  }
}
