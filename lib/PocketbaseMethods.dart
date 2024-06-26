import 'package:pocketbase/pocketbase.dart';
import 'dataModel.dart';
import 'stateHandler.dart';
import 'package:intl/intl.dart';

Future<List<Map<String, dynamic>>> getCommenti(String idPosto) async {
  var lista = await pb.collection("commenti").getList(filter: 'posto="$idPosto"', sort: '-created');
  var dizionario = await pb.collection("collagene").getFullList();
  List<Map<String, dynamic>> comments_list = [];
  var i = 0;
  for (var comment in lista.items) {
    var image = getAvatarFromUtente(comment.getStringValue('utente'), dizionario);
    Map<String, dynamic> map = {
      "posto": comment.getStringValue('posto'),
      "id": comment.id,
      "utente": comment.getStringValue('utente'),
      "commento": comment.getStringValue('commento'),
      "nome_utente": comment.getStringValue('nome_utente'),
      "image": image,
    };
    comments_list.add(map);
    i++;
  }

  return comments_list;
}

Future<List<Map<String, dynamic>>> getCommentiEventi(String idPosto) async {
  var lista = await pb.collection("commenti_eventi").getList(filter: 'posto="$idPosto"', sort: '-created');
  var dizionario = await pb.collection("collagene").getFullList();
  List<Map<String, dynamic>> comments_list = [];
  var i = 0;
  for (var comment in lista.items) {
    var image = getAvatarFromUtente(comment.getStringValue('utente'), dizionario);
    Map<String, dynamic> map = {
      "posto": comment.getStringValue('posto'),
      "id": comment.id,
      "utente": comment.getStringValue('utente'),
      "commento": comment.getStringValue('commento'),
      "nome_utente": comment.getStringValue('nome_utente'),
      "image": image,
    };
    comments_list.add(map);
    i++;
  }

  return comments_list;
}

Future<List<Map<String, dynamic>>> getPartecipanti(String idEvento, isViaggio) async {
  var tabella = isViaggio ? "iscrizioni_viaggi" : "iscrizioni";
  var nome_colonna = isViaggio ? "viaggio" : "evento";
  var lista = await pb.collection(tabella).getList(filter: '$nome_colonna="$idEvento"', sort: '-created');
  var dizionario = await pb.collection("collagene").getFullList();
  List<Map<String, dynamic>> partecipanti = [];
  for (var iscritto in lista.items) {
    var image = getAvatarFromUtente(iscritto.getStringValue('utente'), dizionario);
    var user = await pb.collection('users').getOne(iscritto.getStringValue('utente'));
    Map<String, dynamic> map = {
      "nome_utente": user.getStringValue('username'),
      "image": image,
      "id": user.id,
    };
    partecipanti.add(map);
  }

  return partecipanti;
}

void accettaAmicizia(utente) async {
  await pb.collection('richieste').delete(utente["record_id"]);
  var amicizia1 = <String, dynamic>{
    "username_amico": pb.authStore.model.toJson()["username"],
    "user": utente["id"],
    "amico": pb.authStore.model.toJson()["id"]
  };
  var amicizia2 = <String, dynamic>{
    "username_amico": utente["nome"],
    "user": pb.authStore.model.toJson()["id"],
    "amico": utente["id"]
  };
  //TODO stesso controllo di sopra
  pb.collection('amicizie').create(body: amicizia1);
  pb.collection('amicizie').create(body: amicizia2);
}

Future<String> getIdFromUsername(String username) async {
  return pb.collection("users").getFirstListItem('username="$username"').then((value) => value.id).catchError((error) {
    return "null";
  });
}

Future<List<dynamic>> getlistaAmicizieAndRichieste() async {
  var amici = pb.collection("amicizie").getList(filter: 'user="${pb.authStore.model.toJson()["id"]}"');
  var richieste = pb.collection("richieste").getList(filter: 'user="${pb.authStore.model.toJson()["id"]}"');
  var listaReleazioneAvatarUser = pb.collection("collagene").getFullList();

  var results = await Future.wait([amici, richieste, listaReleazioneAvatarUser]);

  return results;
}

Future<List<dynamic>> getlistaAmicizie() async {
  var amici = pb.collection("amicizie").getList(filter: 'user="${pb.authStore.model.toJson()["id"]}"');
  //var richieste = pb.collection("richieste").getList(filter: 'user="${pb.authStore.model.toJson()["id"]}"');
  var listaReleazioneAvatarUser = pb.collection("collagene").getFullList();

  var results = await Future.wait([amici, listaReleazioneAvatarUser]);

  return results;
}

Future<dynamic> getListaChat() async {
  var listaFinale = [];
  var lista = await getlistaAmicizie();
  var primaLista = lista[0].items;
  List<Future> lista_future = [];
  for (var element in primaLista) {
    var temp = element.toJson();
    var lastMessage = getLastMessage(temp["amico"]);
    lista_future.add(lastMessage);
    //listaFinale.add(temp);
  }

  var listocazzo = await Future.wait(lista_future);
  int i = 0;
  primaLista.forEach((element) {
    //print("hellooo");
    var temp = element.toJson();
    temp['immagine_profilo'] = getAvatarFromUtente(element.getStringValue('amico'), lista[1]);
    temp['record_id'] = element.id;
    if (listocazzo[i][0] == null) {
      temp['anteprima'] = "Nessun Messaggio";
      temp['daLeggere'] = false;
      temp['created'] = 0;
    } else {
      temp['anteprima'] = listocazzo[i][1];
      temp['daLeggere'] = listocazzo[i][0];
      temp['created'] = listocazzo[i][2];
    }
    i++;
    listaFinale.add(temp);
  });

  listaFinale.sort((a, b) => b['created'].compareTo(a['created']));

  return listaFinale;
}

Future<bool> sendFriendRequest(id, username, amici) async {
  for (var amico in amici) {
    if (amico['username_amico'] == username) {
      return false;
    }
  }
  //il check che la richiesta non sia doppia viene già effettuato dal db perché la combinazione dei due nomi utente deve essere unica
  var body = <String, dynamic>{
    "richiedente": pb.authStore.model.toJson()["id"].toString(),
    "user": id, // NB user è l'utente che riceve la richiesta
    "username_richiedente": pb.authStore.model.toJson()["username"].toString(),
    "combinazione": pb.authStore.model.toJson()["username"].toString() + username,
  };

  return pb
      .collection("richieste")
      .getFirstListItem('combinazione="${pb.authStore.model.toJson()["username"].toString() + username}"')
      .then((value) {
    return false;
  }).catchError((error) {
    return pb.collection('richieste').create(body: body).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  });
}

Future<List<dynamic>> getPostiVisitatiByFriends(filtroamici, List<RecordModel> dizionario) async {
  // fitlro per vedere i posti visitati dagli amici
  var visitati = await pb.collection("visitati").getList(filter: filtroamici, perPage: 20, sort: "-created");
  var entriesVisitati = [];

  for (RecordModel el in visitati.items) {
    var image = getAvatarFromUtente(el.getStringValue('user'), dizionario);
    entriesVisitati.add({
      "value":
          '${el.getStringValue('utente')[0].toUpperCase()}${el.getStringValue('utente').substring(1)} ha visitato ${el.getStringValue('nome_posto')}',
      "time": el.created,
      "username": el.getStringValue('utente'),
      "userid": el.getStringValue('user'),
      //"isFriend": true,
      "profile_image": image,
    });
  }

  return entriesVisitati;
}

String getAvatarFromUtente(utente, List<RecordModel> lista) {
  for (RecordModel record in lista) {
    if (record.getStringValue("user") == utente) {
      return record.getStringValue("link_immagine_profilo");
    }
  }
  return "errore";
}

Future<List<dynamic>> getLastMessage(String autore) async {
  var temp = await pb.collection("chat2").getList(
      filter:
          '(target_user.id="${pb.authStore.model.id}"&&author.id="$autore") || (target_user.id="$autore" && author.id="${pb.authStore.model.id}")',
      sort: "-created",
      page: 1,
      perPage: 1);

  if (temp.totalItems == 0) {
    return [null];
  }

  return [
    temp.items[0].getBoolValue("daLeggere"),
    temp.items[0].getStringValue("text"),
    temp.items[0].getIntValue("created_chat")
  ];
}

Future<List<dynamic>> getPostiSalvatiByFriends(filtroamici, List<RecordModel> dizionario) async {
  // fitlro per vedere i posti visitati dagli amici
  var visitati = await pb.collection("posti_salvati").getList(filter: filtroamici, perPage: 20, sort: "-created");

  var entriesSalvati = [];
  for (RecordModel el in visitati.items) {
    var image = getAvatarFromUtente(el.getStringValue('user'), dizionario);
    entriesSalvati.add({
      "value":
          '${el.getStringValue('utente')[0].toUpperCase()}${el.getStringValue('utente').substring(1)} ha salvato ${el.getStringValue('nome_posto')}',
      "time": el.created,
      "username": el.getStringValue('utente'),
      "userid": el.getStringValue('user'),
      //"isFriend": true,
      "profile_image": image,
    });
  }

  return entriesSalvati;
}

Future<void> getPostiVisitati(context) async {
  // fitlro per vedere i posti visitati dall'utente

  var salvati =
      await pb.collection("visitati").getList(filter: 'utente="${Data.username}"', sort: '-created', expand: 'place');
  for (var element in salvati.items) {
    var temp2 = element.expand['place'];
  }
}

Future<List<String>> getAmici() async {
  var richiestaAmici = await pb.collection("amicizie").getList(filter: 'user="${pb.authStore.model.toJson()["id"]}"');
  List<String> amici_ids = [];
  for (var element in richiestaAmici.items) {
    amici_ids.add(element.getStringValue('amico'));
  }
  // ritorno una stringa con tutti gli amici
  return amici_ids;
}

// filtro per vedere gli amici dell'utente
Future<String> createFiltroAmici(nome_colonna, amici) async {
  String filtro = '$nome_colonna=""';
  for (var id_amico in amici) {
    filtro = '${'$filtro || $nome_colonna="' + id_amico}"';
  }
  // ritorno una stringa con tutti gli amici
  return filtro;
}

void getRichiesteAmicizia() async {
  var lista = await pb.collection("richieste").getList(filter: 'user="${Data.id}"');
  Data.setNotificheAmicizia(lista.toJson()["totalItems"]);
}

void aggiornaDataUltimoLogin() async {
  DateTime date = DateTime.now();
  pb.collection("users").update(Data.id, body: {"lastLogin": date.toString()});
}

Future<int> conteggioSalvataggioPosto(String nome) async {
  var lista = await pb.collection("posti_salvati").getFullList(filter: 'nome_posto="$nome"');
  return lista.length;
}

enum AzioniValide { iscrizioneEvento, visitaPosto, caricaPosto }

Future<int> getPunti(String id) async {
  var item = await pb.collection("users").getFirstListItem('id="$id"');
  int punti = item.getIntValue("exp");
  return punti;
}

Future<void> updatePunti(String id, AzioniValide azione) async {
  var item = await pb.collection("users").getFirstListItem('id="$id"');
  int punti = item.getIntValue("exp");
  int puntiDaAssegnare;
  switch (azione) {
    case AzioniValide.iscrizioneEvento:
      puntiDaAssegnare = 10;
      break;
    case AzioniValide.visitaPosto:
      puntiDaAssegnare = 1;
      break;
    case AzioniValide.caricaPosto:
      puntiDaAssegnare = 20;
      break;
    default:
      puntiDaAssegnare = 0;
      break;
  }
  final body = <String, dynamic>{"exp": punti + puntiDaAssegnare};
  pb.collection('users').update(id, body: body);
}

Future<String> getProfileAvatarFromUsername(username) async {
  var user = await pb.collection("users").getFirstListItem('username="$username"', expand: 'avatar');
  final id = user.getStringValue('avatar');
  final filename = user.expand['avatar']?.first.getStringValue('avatar');
  final link = 'https://projectodyssey.it/api/files/gghip0969q05e62/$id/$filename';
  return link;
}

Future<List<List<dynamic>>> getAvatars(context) async {
  final avatars = await pb
      .collection('avatars')
      .getFullList(filter: 'sesso="${pb.authStore.model.getStringValue('sesso')}"', sort: 'exp_required');
  List<List<dynamic>> avatarsImages = [];
  for (RecordModel record in avatars) {
    final id = record.id;
    final filename = record.getStringValue('avatar');
    avatarsImages.add([
      'https://projectodyssey.it/api/files/gghip0969q05e62/$id/$filename',
      record.getStringValue('exp_required'),
      record.id
    ]);
  }

  return avatarsImages;
}

Future<int> numero_amici() async {
  final records = await pb.collection('amicizie').getFullList(
        filter: 'user="${Data.id}"',
      );
  return records.length;
}

Future<int> numero_amici_altrui(String id) async {
  final records = await pb.collection('amicizie').getFullList(
        filter: 'user="${id}"',
      );
  return records.length;
}

String updateProfileAvatar(String imageLink) {
  final splitted = imageLink.split('/');
  final id = splitted[splitted.length - 2];
  final body2 = <String, dynamic>{"link_immagine_profilo": imageLink};
  final body = <String, dynamic>{"avatar": id};
  pb.collection("collagene").getFirstListItem('user="${pb.authStore.model.id}"').then((value) {
    var collageneId = value.toJson()["id"];
    pb.collection('collagene').update(collageneId, body: body2);
  });
  pb.collection('users').update(pb.authStore.model.id, body: body);
  return imageLink;
}

Future<List<dynamic>> getDescription(placeId) async {
  final record = await pb.collection('places').getOne(
        placeId,
      );
  return [record.getStringValue('descrizione'), record.getStringValue('link_esterno')];
}

Future<void> rimuoviAmicizia(String id) async {
  pb.collection("collectionIdOrName").delete(id);
}

Future<bool> checkConsigliereEsperto(String username) async {
  return await pb.collection("places").getList(filter: 'uploaded_by="$username"', perPage: 1).then((value) {
    if (value.totalItems >= 3) {
      return true;
    } else {
      return false;
    }
  });
}

Future<bool> checkRecensoreProfessionista(String id) async {
  return await pb.collection("commenti").getList(filter: 'utente.id="$id"', perPage: 1).then((value) {
    if (value.totalItems >= 5) {
      return true;
    } else {
      return false;
    }
  });
}

Future<bool> checkEsploratore(String id) async {
  return await pb.collection("iscrizioni").getList(filter: 'utente.id="$id"').then((value) {
    if (value.totalItems >= 3) {
      return true;
    } else {
      return false;
    }
  });
}

Future<int> countEvents(String id) async {
  return await pb.collection("iscrizioni").getList(filter: 'utente.id="$id"').then((value) {
    return value.totalItems;
  });
}
