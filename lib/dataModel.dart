class Data {
  static late String _username;
  static late String _id;

  static String get username => _username;
  static String get id => _id;
  static int _NotificheMessaggi = 0;

  static void setNotificheMessaggi(int notificheMessaggi) {
    _NotificheMessaggi = notificheMessaggi;
  }

  static void initializeValues(username, id, punti) {
    _username = username;
    _id = id;
  }

  static void setNotificheAmicizia(json) {}
}
