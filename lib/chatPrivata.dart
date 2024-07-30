import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:koda/isolamento.dart';
import 'stateHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

Future<String> sendData(String message) async {
  final response = await http.post(
    Uri.parse('http://34.23.235.230:3000/checkeducation'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'data': message,
    }),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

Future<List<dynamic>> getMessages(user) async {
  var response = await pb.collection("chat2").getList(
      sort: "-created",
      filter:
          'target_user.id="$user"&&author.id="${pb.authStore.model.id}"||target_user.id="${pb.authStore.model.id}"&&author.id="$user"');

  List<types.TextMessage> messages = [];

  var jsonlist = response.toJson()["items"];

  //print(jsonlist);

  for (var item in jsonlist) {
    if (item["target_user"] == pb.authStore.model.id && item["daLeggere"]) {
      pb.collection("chat2").update(item["id"], body: {"daLeggere": false});
    }
    messages.add(types.TextMessage(
        id: item["id"],
        author: types.User(id: item["author"]),
        createdAt: item["created_chat"],
        text: item["text"]));
  }

  //print(messages);

  return messages;
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatWidget extends StatefulWidget {
  String targetUser;
  String username;
  var immagineprofilo;
  ChatWidget(
      {Key? key,
      required this.targetUser,
      required this.username,
      required this.immagineprofilo})
      : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<types.Message> _messages = [];
  final _user = types.User(id: pb.authStore.model.id);
  late Timer timer;

  @override
  void dispose() {
    pb.collection('chat2').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pb.collection('chat2').subscribe('*', (e) {
      var item = e.record!.toJson();
      setState(() {
        if (item["target_user"] == pb.authStore.model.id) {
          _messages.add(types.TextMessage(
              id: item["id"],
              author: types.User(id: item["target_user"]),
              createdAt: item["created_chat"],
              text: item["text"]));
        }
      });
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(118, 255, 255, 255),
        foregroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //SizedBox(width: MediaQuery.of(context).size.width / 5),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: ClipOval(
                  child: SizedBox.fromSize(
                size: const Size.fromRadius(20),
                /*      child: CachedNetworkImage(
                  imageUrl: widget.immagineprofilo,
                  fit: BoxFit.cover,
                ), */
              )),
            ),
            Text(
              widget.username.toString().toUpperCase().substring(0, 1) +
                  widget.username.toString().substring(1),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
          future: getMessages(widget.targetUser),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //print(snapshot.data);
            return Chat(
              theme: DefaultChatTheme(
                //inputBackgroundColor: Theme.of(context).primaryColor,
                primaryColor: Color.fromARGB(255, 65, 166, 69),
              ),
              messages: snapshot.data as List<types.Message>,
              onSendPressed: _handleSendPressed,
              user: _user,
            );
          }),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    bool sendingMessage = true;
    var res = await sendData(message.text);
    print(res);
    if ((!res.contains("ok") && !res.contains("ok")) || res.contains("not")) {
      sendingMessage = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text(
              res.split(":").last.replaceAll('"', "").replaceAll("\\n}", ""),
            ),
            actions: [
              TextButton(
                child: Text('Send anyway'),
                onPressed: () {
                  /*   final textMessage = types.TextMessage(
                    author: _user,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: randomString(),
                    text: message.text,
                  );

                  pb.collection("chat2").create(body: {
                    //"id": randomString(),
                    "author": pb.authStore.model.id,
                    "text": message.text.substring(0, min(500, message.text.length)),
                    "created_chat": DateTime.now().millisecondsSinceEpoch,
                    "target_user": widget.targetUser,
                    "daLeggere": true,
                  }).then((value) {
                    _addMessage(textMessage);
                  }); */
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Isolamento(),
                    ),
                  );
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    if (sendingMessage) {
      final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text,
      );

      pb.collection("chat2").create(body: {
        //"id": randomString(),
        "author": pb.authStore.model.id,
        "text": message.text.substring(0, min(500, message.text.length)),
        "created_chat": DateTime.now().millisecondsSinceEpoch,
        "target_user": widget.targetUser,
        "daLeggere": true,
      }).then((value) {
        _addMessage(textMessage);
      });
    }
  }
}
