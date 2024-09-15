import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:medicine_chest/entities/scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  FlutterLocalNotificationsPlugin? _notificationsPlugin = null;
  static const _startNotificationId = 0;
  static const _notificationIdPrefKey = "notification_id_counter";

  final _medicineTakeNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails('medicineTake', 'Прием лекарств',
          channelDescription: 'Напоминания о приеме лекарств'));

  void requestNotificationPermission() async {
    final plugin = await _providePlugin();
    final androidPlatform = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    androidPlatform?.requestNotificationsPermission();
  }

  void setupNotificationsForScheme(Scheme scheme) async {
    cancelNotificationForScheme(scheme);

    DateTime begin = scheme.takeSchedule.getFirstTakeDay();
    DateTime end = scheme.takeSchedule.getLastTakeDay();
    DateTime curentDay = begin;
    List<int> notificationIds = [];
    while (curentDay.isBefore(end)) {
      var dayNotificationTimes = scheme.takeSchedule.getTakeMomentsForDay(curentDay);
      for (var time in dayNotificationTimes) {
        var id = await _sheduleNotification(time, scheme.medicine.name);
        if (id != null) {
          notificationIds.add(id);
        }
      }
      curentDay = curentDay.add(Duration(days: 1));
    }

    List<String> notificationIdsString = notificationIds.map((id) => id.toString()).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_getSchemeNotificationIdsKey(scheme), notificationIdsString);
  }

  void cancelNotificationForScheme(Scheme scheme) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? notificationIdsStrings = prefs.getStringList(_getSchemeNotificationIdsKey(scheme));
    final plugin = await _providePlugin();

    if (notificationIdsStrings != null) {
      for (var notificationIdString in notificationIdsStrings) {
        final id = int.tryParse(notificationIdString);
        if (id != null) {
          plugin.cancel(id);
        }
      }
    }
  }

  Future<int> _getNextNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    int id = (prefs.getInt(_notificationIdPrefKey) ?? _startNotificationId) + 1;
    await prefs.setInt(_notificationIdPrefKey, id);
    return id;
  }

  String _getSchemeNotificationIdsKey(Scheme scheme) {
    return "scheme_notification_ids_${scheme.id}";
  }

  Future<int?> _sheduleNotification(DateTime dateTime, String medicineName) async {
    if (dateTime.isBefore(DateTime.now())) {
      return null;
    }

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final time = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.getLocation(currentTimeZone),
        dateTime.millisecondsSinceEpoch);

    final plugin = await _providePlugin();
    final id = await _getNextNotificationId();

    plugin.zonedSchedule(id, "Пора принять лекарство", "Надо принять $medicineName",
        time, _medicineTakeNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    return id;
  }

  Future<FlutterLocalNotificationsPlugin> _providePlugin() async {
    if (_notificationsPlugin == null) {
      tz.initializeTimeZones();
      _notificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _notificationsPlugin!.initialize(initializationSettings,
          onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
    }
    return _notificationsPlugin!;
  }

  void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {}
}
