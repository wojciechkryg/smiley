import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(App());

var notifications = FlutterLocalNotificationsPlugin();

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
  var _notificationCount = 3.0;

  void _setNotificationCount(double value) =>
      setState(() => _notificationCount = value);

  @override
  void initState() {
    var settingsAndroid = AndroidInitializationSettings('launch_background');
    var settingsIOS = IOSInitializationSettings();
    var settings = InitializationSettings(settingsAndroid, settingsIOS);
    notifications.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smiley')),
      body: Center(
        child: Column(
          children: [
            _getSmileButton(),
            _getCountSlider(),
          ],
        ),
      ),
    );
  }

  IconButton _getSmileButton() {
    return IconButton(
      icon: Icon(Icons.notifications),
      onPressed: _showNotification,
    );
  }

  Slider _getCountSlider() => Slider(
        value: _notificationCount,
        min: 1,
        max: 5,
        divisions: 4,
        label: '${_notificationCount.round()}',
        onChanged: _setNotificationCount,
      );

  Future _showNotification() async {
    var androidChannel = AndroidNotificationDetails('Smiley', 'Smiley', 'Smiley',
        importance: Importance.Max, priority: Priority.High);
    var iOSChannel = IOSNotificationDetails();
    var channel = NotificationDetails(androidChannel, iOSChannel);
    await notifications.show(0, 'Smile', 'Smile to person near you! \u{1f642}', channel);
  }
}
