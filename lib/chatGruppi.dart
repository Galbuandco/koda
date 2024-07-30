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

Future<String> sendData(dynamic message) async {
  print(message);
  final response = await http.post(
    Uri.parse('http://35.237.12.20:3000/groupchatsummary'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'data': message.toString(),
    }),
  );
  print(response.body);
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

Future<List<dynamic>> getMessages(String gruppoId) async {
  var response =
      await pb.collection("groupChat").getList(sort: "-created_chat", perPage: 100, filter: 'gruppo="$gruppoId"');

  List<types.TextMessage> messages = [];

  var jsonlist = response.toJson()["items"];

  for (var item in jsonlist) {
    messages.add(types.TextMessage(
      id: item["id"],
      author: types.User(id: item["author"], firstName: item["username"]),
      createdAt: item["created_chat"],
      text: item["text"],
    ));
  }

  return messages;
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class GruppiChatWidget extends StatefulWidget {
  String id;
  String name;
  //var immagineprofilo;
  GruppiChatWidget({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  @override
  State<GruppiChatWidget> createState() => _GruppiChatWidgetState();
}

class _GruppiChatWidgetState extends State<GruppiChatWidget> {
  final List<types.Message> _messages = [];
  final _user = types.User(id: pb.authStore.model.id);
  late Timer timer;

  @override
  void dispose() {
    pb.collection('groupChat').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pb.collection('groupChat').subscribe('*', (e) {
      var item = e.record!.toJson();
      setState(() {
        if (item["gruppo"] == pb.authStore.model.id) {
          _messages.add(types.TextMessage(
              id: item["id"],
              author: types.User(id: item["gruppo"]),
              createdAt: item["created_chat"],
              text: item["text"]));
        }
      });
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(234, 255, 255, 255),
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
              widget.name,
              //widget.username.toString().toUpperCase().substring(0, 1) + widget.username.toString().substring(1),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
          future: getMessages(widget.id),
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
              showUserNames: true,
              showUserAvatars: true,
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
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    if (message.text == "/summary") {
      var chatHistory =
          await pb.collection("groupChat").getFullList(filter: "gruppo = \"${widget.id}\"", sort: "-created_chat");
      //chatHistory = chatHistory.map((e) => e.toJson()).toList();
      sendData(chatHistory
              .map((e) => {"text": e.getStringValue("text"), "username": e.getStringValue("username")})
              .toList())
          .then((result) => {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Summary'),
                      content: Text(result.split(":").last.replaceAll('"', "").replaceAll("\\n}", "")),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                )
              });
    }

    if (message.text != "/summary") {
      pb.collection("groupChat").create(body: {
        "username": pb.authStore.model.getStringValue("username"),
        "author": pb.authStore.model.id,
        "text": message.text.substring(0, min(500, message.text.length)),
        "created_chat": DateTime.now().millisecondsSinceEpoch,
        "gruppo": widget.id, // Assuming widget.id is the group ID
        "True": true, // Assuming this is a required field, adjust the key as necessary
      }).then((value) {
        _addMessage(textMessage);
      });
    }
  }
}
