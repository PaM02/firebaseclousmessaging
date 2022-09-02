import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm/screen_2.dart';
import 'package:fcm/services/service_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  String? mtoken = " ";

  @override
  void initState() {
    super.initState();

    NotificationService.requestPermission();

    NotificationService.loadFCM();

    NotificationService.listenFCM();

    getToken();

    NotificationService.init();
    listenNotification();

    FirebaseMessaging.instance.subscribeToTopic("Likid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String name = username.text.trim();
                      String titleText = title.text;
                      String bodyText = body.text;

                      if (name != "") {
                        DocumentSnapshot snap = await FirebaseFirestore.instance
                            .collection("UserTokens")
                            .doc(name)
                            .get();

                        String token = snap['token'];
                        print(token);

                        sendPushMessage(token, titleText, bodyText);
                      }
                    },
                    child: Text('button'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
      'token': token,
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
      print("token $token");
      saveToken(token!);
    });
  }

  void listenNotification() =>
      NotificationService.onNotifications.stream.listen(onClickNotification);

  void onClickNotification(String? payload) => Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MyWidget(payload: payload)));

  void sendPushMessage(String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAHf3aoZ4:APA91bHO2QXJOLQxzzu0B0P8H0NnabRDzAi8sgfA_Y9ZDAZibz4N9J88YG9n9FWHyMcLffcD9k-ngyZx37eOIsYdxGBsxQ9ZIan_GUznE7b-ubByp9s-K_Bgq_Qne63Ma6e9RZ77IdrX',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'title': title,'body': body},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }
}
