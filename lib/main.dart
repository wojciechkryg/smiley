import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  notifications = new FlutterLocalNotificationsPlugin();
  runApp(App());
}

var notifications;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smiley',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Page(),
    );
  }
}

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  void initState() {
    var settingsAndroid =
        AndroidInitializationSettings('launch_background');
    var settingsIOS = IOSInitializationSettings();
    var settings = InitializationSettings(settingsAndroid, settingsIOS);
    notifications.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNotification,
        child: Icon(Icons.notifications),
      ),
    );
  }

  Future _showNotification() async {
    var androidChannel = AndroidNotificationDetails('test', 'test', 'test',
        importance: Importance.Max, priority: Priority.High);
    var iOSChannel = IOSNotificationDetails();
    var channel = NotificationDetails(androidChannel, iOSChannel);
    await notifications.show(1, 'plain title', 'plain body', channel);
  }
}
