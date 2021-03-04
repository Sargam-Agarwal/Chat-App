import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import './message_bubble.dart';

class Messages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MessagesState();
  }
}

class _MessagesState extends State<Messages> {
  String _username;
  String _dpUrl;
  var _enteredMsg = '';
  var user = FirebaseAuth.instance.currentUser;
  var _messageController = TextEditingController();

  void _addNewMsg() async {
    FocusScope.of(context).unfocus();
    _username = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((docSnapshot) => docSnapshot.data()['username']);

    _dpUrl = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((docSnapshot) => docSnapshot.data()['dpUrl']);
    FirebaseFirestore.instance.collection('chat').add({
      'uid': user.uid,
      'text': _enteredMsg,
      'time': Timestamp.now(),
      'username': _username,
      'imageUrl': _dpUrl
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              return ListView.builder(
                reverse: true,
                itemCount: chatSnapshot.data.docs.length,
                itemBuilder: (ctx, index) => MessageBubble(
                  username: chatSnapshot.data.docs[index]['username'],
                  message: chatSnapshot.data.docs[index]['text'],
                  dpUrl: chatSnapshot.data.docs[index]['imageUrl'],
                  isMe: user.uid == chatSnapshot.data.docs[index]['uid'],
                  key: ValueKey(chatSnapshot.data.docs[index].id),
                ),
              );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Send a message'),
                  onChanged: (value) {
                    setState(() {
                      _enteredMsg = value;
                    });
                  },
                ),
              ),
              IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed: _enteredMsg.trim().isEmpty ? null : _addNewMsg),
            ],
          ),
        ),
      ],
    );
  }
}
