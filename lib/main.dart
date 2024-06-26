//import 'package:Odyssey/temi.dart';
//import 'package:eraser/eraser.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//mport 'firebase_options.dart';
import 'stateHandler.dart';
import 'package:flutter/services.dart';

// NON TOCCARE QUESTO SNIPPET ANCHE SE NON FA NULLA, SEMBRA CHE L'INTENT DA NOTIFICA (implementato in stateHandler(backgorund) e stackAndNavbar()terminated) NON FUNZIONI SENZA
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //print("handling a background message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Loads the environment variables from the specified file.
  /// The [fileName] parameter specifies the path to the environment file
  /// that contains the variables to be loaded

  //TODO: Inizializzare progetto da firebase console
/*   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); */

  runApp(const MyApp());
  //Eraser.clearAllAppNotifications();
  //Eraser.resetBadgeCountAndRemoveNotificationsFromCenter();
  //MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odyssey',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        /*  primaryColor: Colors.green,
        focusColor: Colors.green,
        primaryColorLight: Colors.green,
        highlightColor: Colors.green,
        primaryColorDark: Colors.green,
        primarySwatch: Colors.green,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.blue),
            backgroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),
          bodySmall: TextStyle(fontSize: 14.0, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black),
          titleMedium: TextStyle(fontSize: 16.0, color: Colors.black),
        ), */
      ),
      //themeMode: ThemeMode.light,
      home: const Autenticazione(),
    );
  }
}
