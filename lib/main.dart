import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() => runApp(App());

var notifications = FlutterLocalNotificationsPlugin();

class App extends StatelessWidget {
  @override
  build(BuildContext context) {
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
  createState() => _PageState();
}

class _PageState extends State<Page> {
  final tagIsEnabled = 'isEnabled';
  final tagNotificationCount = 'notificationCount';
  var _prefs;
  var _isEnabled;
  var _notificationCount;

  _toggleEnabled() {
    _prefs.setBool(tagIsEnabled, !_isEnabled);
    setState(() => _isEnabled = !_isEnabled);
  }

  _setNotificationCount(double value) {
    _prefs.setDouble(tagNotificationCount, value);
    setState(() => _notificationCount = value);
  }

  @override
  initState() {
    var settingsAndroid = AndroidInitializationSettings('launch_background');
    var settingsIOS = IOSInitializationSettings();
    var settings = InitializationSettings(settingsAndroid, settingsIOS);
    notifications.initialize(settings);
    _initPrefs();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = _prefs.getBool(tagIsEnabled) ?? false;
      _notificationCount = _prefs.getDouble(tagNotificationCount) ?? 3.0;
    });
  }

  @override
  build(BuildContext context) {
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

  _getSmileButton() => IconButton(
        icon: Icon(Icons.notifications),
        onPressed: _setupNotifications,
      );

  _getCountSlider() => Slider(
        value: _notificationCount,
        min: 1,
        max: 10,
        divisions: 9,
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
    var androidChannel =
        AndroidNotificationDetails('Smiley', 'Smiley', 'Smiley');
    var iOSChannel = IOSNotificationDetails();
    var channel = NotificationDetails(androidChannel, iOSChannel);
    for (var i = 0; i < _notificationCount; i++) {
      _scheduleNotification(i, channel);
    }
  }

  _scheduleNotification(int id, NotificationDetails channel) async {
    final title = await _getRandomDataFromFile('assets/data/titles.json');
    final body = await _getRandomDataFromFile('assets/data/bodies.json');
    notifications.showDailyAtTime(id, title, body, _getRandomTime(), channel);
  }

  _getRandomDataFromFile(String path) async => (await _getJsonAsset(path)
        ..shuffle())
      .first
      .values
      .first;

  _getJsonAsset(String path) async =>
      await rootBundle.loadString(path).then((json) => jsonDecode(json));

  _getRandomTime() {
    final random = Random();
    final hour = 7 + random.nextInt(15);
    final minute = random.nextInt(60);
    final second = random.nextInt(60);
    return Time(hour, minute, second);
  }

  _cancelAllNotifications() {
    notifications.cancelAll();
  }
}
