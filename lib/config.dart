import 'dart:convert';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigationService.dart';


class Config {

  static Config? _instance;
  factory Config() => _instance ??= Config._();
  Config._();

  final String _firstLaunch = 'firstlaunch';
  final String _token = 'token';
  final String _preToken = 'pretoken';
  final String _subs = 'subs';
  final String _preSubs = 'presubs';
  final String _phone = 'phone';
  final String _prePhone = 'prephone';
  final String _payloadReportId = 'payloadreportid';
  final String _backgroundPayload = 'backgroundpayload';
  final String _amplitudeKey = '2a6d2d8df9872b356cb0a68620e5f1cc';

  final String _eventLaunch = 'launch_first_time';
  final String _eventHome = 'homescreen.load';
  final String _eventDetail = 'rdp.load';
  final String _eventNotifNew = 'pnbnr.click';
  final String _eventNotifUpdate = 'pnur.click';
  final String _eventRatingOverview = 'rrop.load';


  // Future<SharedPreferences> getPref() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.reload();
  //   return prefs;
  // }

  // Future getBackgroundPayload() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   return prefs.getString(_backgroundPayload);
  // }
  //
  // Future<void> setBackgroundPayload(String backgroundpayload) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   await prefs.setString(_backgroundPayload, backgroundpayload);
  // }
  //
  // Future<void> delBackgroundPayload() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   await prefs.remove(_backgroundPayload);
  // }
  //
  // Future getPayloadReportId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   return prefs.getString(_payloadReportId);
  // }
  //
  // Future<void> setPayloadReportId(String payloadreportid) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   await prefs.setString(_payloadReportId, payloadreportid);
  // }
  //
  // Future<void> delPayloadReportId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   await prefs.remove(_payloadReportId);
  // }

  Future<void> setFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_firstLaunch, _firstLaunch);
  }

  Future getFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstLaunch);
  }

  String getAmplitudeKey() {
    return _amplitudeKey;
  }

  Future getPreToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preToken);
  }

  void setPreToken(String pretoken, String presubs, String prephone) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_preToken, pretoken);
    prefs.setString(_preSubs, presubs);
    prefs.setString(_prePhone, prephone);
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  Future getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phone);
  }

  Future getSubs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subs);
  }

  Future<void> setToken() async {
    final prefs = await SharedPreferences.getInstance();
    final pretoken = prefs.getString(_preToken);
    prefs.setString(_token, pretoken!);

    final presubs = prefs.getString(_preSubs);
    List arrSubs = jsonDecode(presubs!);
    for(var i = 0; i < arrSubs.length; i++){
      await FirebaseMessaging.instance.subscribeToTopic(arrSubs[i].toString());
    }
    prefs.setString(_subs, presubs);

    final prephone = prefs.getString(_prePhone);
    await prefs.setString(_phone, prephone!);
  }

  Future<bool> checkSubs(String sub) async {
    final prefs = await SharedPreferences.getInstance();
    final subs = prefs.getString(_subs);
    List<String> arrSubs = jsonDecode(subs.toString());

    if(!arrSubs.contains(sub)) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(sub);
      return false;
    }

    return true;
  }

  void delToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_token);
    prefs.remove(_phone);

    final subs = prefs.getString(_subs);
    List arrSubs = jsonDecode(subs!);
    for(var i = 0; i < arrSubs.length; i++){
      await FirebaseMessaging.instance.unsubscribeFromTopic(arrSubs[i].toString());
    }
    prefs.remove(_subs);

    await prefs.remove(_payloadReportId);
    await prefs.remove(_backgroundPayload);
  }

  void logout(){
    Config().delToken();
    NavigationService.instance.navigateUntil("login");
  }

  Future<void> showNotification(int notificationId, String notificationTitle, String notificationContent, String payload, void Function(String?)? onSelectNotification) async {
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('kidparent_importance_channel', 'KinderCastle Parent Importance Notifications', channelDescription: 'This channel is used for kindercastle parent important notifications.', styleInformation: BigTextStyleInformation(''), importance: Importance.high, priority: Priority.high);
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(notificationId, notificationTitle, notificationContent, platformChannelSpecifics, payload: payload);
  }

  Future<void> eventLaunch() async {
    await logEvent(_eventLaunch);
  }
  void eventHome() {
    logEvent(_eventHome);
  }
  void eventDetail(String reportId) {
    logEvent(_eventDetail, eventProperties: {'report_id': reportId});
  }
  void eventNotifNew(String reportId) {
    logEvent(_eventNotifNew, eventProperties: {'report_id': reportId});
  }
  void eventNotifUpdate(String reportId) {
    logEvent(_eventNotifUpdate, eventProperties: {'report_id': reportId});
  }
  void eventRatingOverview(String reportId) {
    logEvent(_eventRatingOverview, eventProperties: {'report_id': reportId});
  }

  Future<void> logEvent(String event, {Map<String, dynamic> eventProperties = const {}}) async {
    final Amplitude analytics = Amplitude.getInstance(instanceName: "project");

    // Initialize SDK
    analytics.init(_amplitudeKey);

    // Enable COPPA privacy guard. This is useful when you choose not to report sensitive user information.
    analytics.enableCoppaControl();

    // Set user Id
    analytics.setUserId(await Config().getPhone());

    // Turn on automatic session events
    analytics.trackingSessionEvents(true);

    // Log an event
    analytics.logEvent(event, eventProperties: eventProperties);
  }

}