import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';
import 'package:intl/intl.dart';

import 'config.dart';
import 'api.dart';
import 'navigationService.dart';
import 'reportDetail.dart';


class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> with WidgetsBindingObserver {
  Future? _data;
  String date = DateFormat('yyyy-MM').format(DateTime.now());
  String _dateMask = DateFormat('MMMM yyyy').format(DateTime.now());
  DateTime? currentBackPressTime;
  List<String> listThings = [];
  List<String> listMeals = [];
  List<String> listNap = [];
  late final FirebaseMessaging _messaging;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   log("======");
  //   log(state.toString());
  //   log("======");
  //   if(state == AppLifecycleState.resumed) {
  //     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //     final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //     String? payloadReportId = await Config().getBackgroundPayload();
  //     log("2 ====== 2");
  //     log((notificationAppLaunchDetails?.didNotificationLaunchApp).toString());
  //     log(payloadReportId.toString());
  //     log("2 ====== 2");
  //     if (notificationAppLaunchDetails?.didNotificationLaunchApp == true && payloadReportId != null) {
  //       await _onSelectNotification(payloadReportId);
  //       await Config().delPayloadReportId();
  //       await Config().delBackgroundPayload();
  //     }
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

  @override
  void initState() {
    Config().eventHome();

    _checkVersionUpdate();

    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _registerNotification();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   String? payloadReportId = await Config().getPayloadReportId();
    //
    //   if(payloadReportId!=null) {
    //     await _onSelectNotification(payloadReportId);
    //     await Config().delPayloadReportId();
    //     await Config().delBackgroundPayload();
    //   }
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _registerNotification() async {
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {

      // terminate
      RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        await _onSelectNotification(message.data['report_id']+'|||'+(message.data['status']=='new'?'1':'0'));
      }

      // background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        await _onSelectNotification(message.data['report_id']+'|||'+(message.data['status']=='new'?'1':'0'));
      });

      // foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Config().showNotification(int.parse(message.data['report_id']), message.notification!.title.toString(), message.notification!.body.toString(), '${message.data['report_id']}|||${message.data['status']=='new'?'1':'0'}', _onSelectNotification);
      });

    } else {
      log('User declined or has not accepted permission');
    }
  }

  Future<void> _onSelectNotification(String? payload) async {
    while(NavigationService.instance.canBack()) {
      NavigationService.instance.goBack();
    }

    String report_id = payload!.split('|||')[0];
    String notif_status = payload.split('|||')[1];

    if(notif_status == '1') {
      Config().eventNotifNew(report_id);
    } else {
      Config().eventNotifUpdate(report_id);
    }

    setState(() {
      _data = _buildReportList();
    });

    List _d = (await _data) as List;
    int index = _d.indexWhere((e) => e['id'] == report_id);
    if(index != -1) {
      NavigationService.instance.navigateToRoute(MaterialPageRoute(
          builder: (BuildContext context){
            return ReportDetail(data: _d[index], milks: _d[index]['report']['milk_sessions'], thingsList: listThings, mealsList: listMeals, napList: listNap);
          })
      );
    }
  }

  @override
  void didChangeDependencies() {
    _data = _buildReportList();

    super.didChangeDependencies();
  }

  Future<void> _checkVersionUpdate() async {
    final needUpdate = await Api.getVersionUpdate();
    if(needUpdate!=null && needUpdate.isNotEmpty && (needUpdate['forced'].toString()=='1' || needUpdate['recommend'].toString()=='1')) {
      _showAppUpdateModalDialog(context, needUpdate);
    }
  }

  Future _buildReportList() async {
    // things list
    listThings = (await Api.getThingsToBringTmrList())['rows'][0]['value'].toString().split(',');
    listThings.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    // meals list
    listMeals = (await Api.getMealsList())['rows'][0]['value'].toString().split(',');

    // nap list
    listNap = (await Api.getNapList())['rows'][0]['value'].toString().split(',');

    var _report = (await Api.getReportByYearMonth(date))['rows'];

    _report.sort((a, b) {
      int cmp = b['date'].toString().toLowerCase().compareTo(a['date'].toString().toLowerCase());
      if (cmp != 0) return cmp;
      return a['child_name'].toString().toLowerCase().compareTo(b['child_name'].toString().toLowerCase());
    });

    List _d = [];

    for (var i = 0; i < _report.length; i++) {
      _report[i].removeWhere((key, value) => value == null);
      _report[i].updateAll((key, value) => value.toString());
      _report[i].removeWhere((key, value) => value == '00:00:00');

      var _item = {
        'id': _report[i]['id'],
        'nanny_id': _report[i]['nanny_id'],
        'nanny_name': _report[i]['nanny_name'],
        'location_id': _report[i]['location_id'],
        'location_name': _report[i]['location_name'],
        'child_id': _report[i]['child_id'],
        'child_name': _report[i]['child_name'],
        'report': _report[i]
      };

      _d.add(_item);
    }

    return _d;
  }

  _showAppUpdateModalDialog(context, needUpdate) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(7)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 60),
                          child: const Text('Version Update available', style: TextStyle(fontSize: 16))
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Visibility(
                                visible: needUpdate['forced'].toString()!='1',
                                child: GestureDetector(
                                  onTap: () {
                                    NavigationService.instance.goBack();
                                  },
                                  child: const Text('SKIP', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 30),
                                child: GestureDetector(
                                    onTap: () {
                                      LaunchReview.launch();
                                    },
                                    child: const Text('UPDATE', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold))
                                )
                            )
                          ]
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () => Future.value(false),
            );
          });
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press back again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  _showLogoutModalDialog(context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(7)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 16))
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              NavigationService.instance.goBack();
                            },
                            child: const Text('GO BACK', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 30),
                            child: GestureDetector(
                                onTap: () {
                                  Config().logout();
                                },
                                child: const Text('LOGOUT', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold))
                            )
                        )
                      ]
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 100,
              backgroundColor: const Color(0xFFD2EBFD), // E2F2FF
              foregroundColor: Colors.black,
              elevation: 0,
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Text('Daily Care Report')
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: const Icon(Icons.event)
                          ),
                          Text(_dateMask, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16))
                        ]
                      ),
                      onTap: () => _showPicker(context: context)
                    )
                  ]
              ),
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        _showLogoutModalDialog(context);
                      },
                      child: const Icon(Icons.logout),
                    )
                ),
              ],
            ),
            body: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return listViewReport(context, snapshot.data as List?);
                }
                return const Scaffold(
                    body: Center(
                        child: CircularProgressIndicator()
                    )
                );
              },
            )
        )
    );
  }

  Widget listViewReport(BuildContext context, List? data){

    return data==null || data.isEmpty ? const Center(
      heightFactor: 4,
      child: Text("No reports available.", style: TextStyle(fontSize: 16), overflow: TextOverflow.visible),
    ) :
    Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: data.length,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  itemBuilder: (context, index) {
                    return Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ListTile(
                          textColor: Colors.black,
                          contentPadding: const EdgeInsets.only(top: 10, bottom: 15),
                          onTap: () {
                            NavigationService.instance.navigateToRoute(MaterialPageRoute(
                                builder: (BuildContext context){
                                  return ReportDetail(data: data[index], milks: data[index]['report']['milk_sessions'], thingsList: listThings, mealsList: listMeals, napList: listNap);
                                }
                            ));
                          },
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: const EdgeInsets.only(bottom:3), child: Text(data[index]['location_name'], style: const TextStyle(fontSize: 15))),
                                Padding(padding: const EdgeInsets.only(bottom:8), child: Text(data[index]['child_name'], style: const TextStyle(fontSize: 20)))
                              ]
                          ),
                          subtitle: Row(
                              children: [
                                Text(DateFormat('EEEE, d MMM yyyy').format(DateTime.parse(data[index]['report']['date'])), style: const TextStyle(fontSize: 16))
                              ]
                          ),
                          shape: const Border(
                              bottom: BorderSide(color: Colors.black26)
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.black87),
                        )
                    );
                  })
          )
        ]
    );
  }

  Future<void> _showPicker({required BuildContext context, String? locale}) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.parse('$date-01'),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      locale: localeObj
    );

    if (selected != null) {
      setState(() {
        _dateMask = DateFormat('MMMM yyyy').format(selected);
        date = DateFormat('yyyy-MM').format(selected);
        _data = _buildReportList();
      });
    }
  }

}