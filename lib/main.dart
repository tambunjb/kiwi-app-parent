import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'dismissKeyboard.dart';
import 'navigationService.dart';
import 'login.dart';
import 'report.dart';
import 'config.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'kidparent_importance_channel', // id
    'KinderCastle Parent Importance Notifications', // title
    description: 'This channel is used for kindercastle parent important notifications.', // description
    importance: Importance.high
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await _checkDidNotificationLaunchApp();

  runApp(const MyApp());
}

// Future<void> _checkDidNotificationLaunchApp() async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
//   log("-------");
//   log((notificationAppLaunchDetails?.didNotificationLaunchApp ?? false).toString());
//   log("-------");
//   if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
//     await Config().delBackgroundPayload();
//     await Config().setPayloadReportId(notificationAppLaunchDetails!.payload.toString());
//   }
// }

// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   log("{{{{{{{");
//   log(message.data.toString());
//   log("{{{{{{{");
  // await Config().setBackgroundPayload(message.data['report_id']);
  // String? payloadReportId = await Config().getBackgroundPayload();
  // log("1 ====== 1");
  // log(payloadReportId.toString());
  // log("1 ====== 1");
  // Config().showNotification(int.parse(message.data['report_id']), message.data['title'].toString(), message.data['body'].toString(), message.data['report_id'].toString(), _onSelectNotification);
// }

// Future<void> _onSelectNotification(String? payload) async {
//   log("+++++++");
//   log(payload!);
//   log("+++++++");
//   // await Config().setPayloadReportId(payload);
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterUxcam.optIntoSchematicRecordings();
    FlutterUxcam.startWithKey("sioegq093tl2ge7");

    Amplitude.getInstance().init(Config().getAmplitudeKey());

    return DismissKeyboard(
        child: MaterialApp(
            title: 'KinderCastle Parent',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(),
            navigatorKey: NavigationService.instance.navigationKey,
            routes: {
              "login":(BuildContext context) => const Login(),
              "home":(BuildContext context) => const Report(),
            },
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              MonthYearPickerLocalizations.delegate,
            ],
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future? _token;

  @override
  void initState() {
    _token = Config().getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data == null ? const Login() : const Report();
        }
        return const Scaffold(
            body: Center(
                child: CircularProgressIndicator()
            )
        );
      },
    );
  }
}
