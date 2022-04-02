import 'dart:convert';
import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

main() {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  build(BuildContext context) => MaterialApp(
        title: 'Smiley',
        theme: ThemeData(primaryTextTheme: TextTheme(bodyText2: TextStyle(color: Colors.amberAccent))),
        home: Home(),
      );
}

class Home extends StatefulWidget {
  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final tagIsEnabled = 'isEnabled';
  final tagNotificationCount = 'notificationCount';

  late FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  late SharedPreferences _prefs;
  late bool _isEnabled = false;
  late int _notificationCount = 1;

  _toggleEnabled() {
    _prefs.setBool(tagIsEnabled, !_isEnabled);
    setState(() => _isEnabled = !_isEnabled);
  }

  _setNotificationCount(double value) {
    _prefs.setInt(tagNotificationCount, value.toInt());
    setState(() => _notificationCount = value.toInt());
  }

  @override
  initState() {
    super.initState();
    initializeTimeZones();
    notifications.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: IOSInitializationSettings()));
    _initPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = _prefs.getBool(tagIsEnabled) ?? false;
      _notificationCount = _prefs.getInt(tagNotificationCount) ?? 1;
    });
  }

  @override
  build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
          title: Text('Smiley', style: TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 24)),
        ),
        backgroundColor: Colors.amberAccent,
        body: _getHomeContainer(),
      );

  _getHomeContainer() => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //_getHintLabel(),
            _getSmileButton(),
            _getCountSliderLabel(),
            _getCountSlider(),
          ],
        ),
      );

  _getSmileButton() => Container(
        height: 320,
        width: 320,
        child: ElevatedButton(
          style : ElevatedButton.styleFrom(
              elevation: 0,
              primary: Colors.amberAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(160))),
          child: FlareActor(
            'assets/animation/Smile.flr',
            animation: _isEnabled ? "On" : "Off"
          ),
          onPressed: _setupNotifications,
        ),
      );

  _getHintLabel() => Text(
      _isEnabled ? "Tap face to disable" : "Tap face to enable",
      style: const TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 20));

  _getCountSliderLabel() => const Text("Reminders per day",
      style: TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 16));

  _getCountSlider() => Slider(
        value: _notificationCount.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        activeColor: Colors.black,
        label: '${_notificationCount.round()}',
        onChanged: _isEnabled ? null : _setNotificationCount,
      );

  _setupNotifications() async {
    _toggleEnabled();
    if (_isEnabled) {
      _scheduleNotifications();
    } else {
      _cancelAllNotifications();
    }
  }

  _scheduleNotifications() {
    var androidChannel = AndroidNotificationDetails('Smiley', 'Smiley', channelDescription: 'Smiley', importance: Importance.max, priority: Priority.max);
    var iOSChannel = IOSNotificationDetails();
    var channel = NotificationDetails(android: androidChannel, iOS: iOSChannel);
    for (var i = 0; i < _notificationCount; i++) {
      _scheduleNotification(i, channel);
    }
  }

  _scheduleNotification(int id, NotificationDetails channel) async {
    var title = await _getRandomDataFromFile('assets/data/titles.json');
    var body = await _getRandomDataFromFile('assets/data/bodies.json');
    notifications.zonedSchedule(id, title, body, _getRandomTime(), channel,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time);
  }

  _getRandomDataFromFile(String path) async => (await _getJsonAsset(path)
        ..shuffle())
      .first
      .values
      .first;

  _getJsonAsset(String path) async =>
      await rootBundle.loadString(path).then((json) => jsonDecode(json));

  _getRandomTime() {
    var random = Random();
    var hours = 7 + random.nextInt(14);
    var minutes = random.nextInt(60);
    var seconds = random.nextInt(60);

    return TZDateTime.from(DateTime.now().add(Duration(days: 0, hours: hours, minutes: minutes, seconds: seconds, milliseconds: 0, microseconds: 0)), local);
  }

  _cancelAllNotifications() {
    notifications.cancelAll();
  }
}
