import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:koda/homepage.dart';
import 'login.dart';
import 'dataModel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import "package:pocketbase/pocketbase.dart";
//import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

String intent_da_notifica = "";
String apiUrl = "http://192.168.1.146:8090";
final pb = PocketBase(apiUrl);
const storage = FlutterSecureStorage();

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

/// Handles the incoming FCM message and sets the intent_da_notifica variable.
void handleMessage(RemoteMessage message) {
  //print("Sono stato chiamato");
}

/// Sets up the handling of the interacted FCM message.
Future<void> setupInteractedMessage() async {
  //print("______________________________________________________________________________________");
  // Get any messages which caused the application to open from
  // a terminated state.
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  // navigate to a chat screen
  if (initialMessage != null) {
    handleMessage(initialMessage);
  }

  // Also handle any interaction when the app is in the background via a
  // Stream listener
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
}

Future<String> login(context) async {
  String? token = await storage.read(key: "token");
  String? rawModel = await storage.read(key: "model");

  if (token != null && rawModel != null) {
    var model = RecordModel.fromJson(jsonDecode(rawModel) as Map<String, dynamic>? ?? {});
    pb.authStore.save(token, model);
    if (pb.authStore.isValid) {
      Data.initializeValues(pb.authStore.model.toJson()["username"], pb.authStore.model.toJson()["id"],
          pb.authStore.model.getIntValue("exp"));
      pb
          .collection("chat2")
          .getList(filter: 'target_user.id="${pb.authStore.model.id}"&&daLeggere=true')
          .then((value) => Data.setNotificheMessaggi(value.items.length));

      return "true"; // posti_scaricati = await get_places();

      //final fcmToken = await FirebaseMessaging.instance.getToken();
      //print(fcmToken);

      // IMPORTANTE SERVE PER GESTIRE L'INTENT DALLE NOTIFICHE QUANDO L'APP è CHIUSA
/*       await setupInteractedMessage();

      if (fcmToken != null) {
        await pb.collection('users').update(pb.authStore.model.toJson()["id"], body: {"fcmToken": fcmToken});
      }
      return "true"; */
    }
  }

  Future<String?> primologin = storage.read(key: "primologin");
  var risultatiSecureStorage = await primologin;
  if (risultatiSecureStorage == null) {
    /*  FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    ); */
    return "primologin";
  } else {
    return "false";
  }
}

class Autenticazione extends StatefulWidget {
  const Autenticazione({super.key});

  @override
  State<Autenticazione> createState() => _AutenticazioneState();
}

class _AutenticazioneState extends State<Autenticazione> {
  late Future<String> _getDataFuture;

  @override
  void initState() {
    super.initState();
    _getDataFuture = login(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == "true" && pb.authStore.isValid) {
            return BottomNavigationBarWrapper();
          } /* else if (snapshot.data == "primologin") {
            return const WelcomePage();
          } */
          return const LoginPage();
        } else {
          return Center(
              child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  secondRingColor: Theme.of(context).primaryColor,
                  size: 50,
                  thirdRingColor: const Color.fromARGB(255, 0, 56, 102)));
        }
      },
    );
  }
}
