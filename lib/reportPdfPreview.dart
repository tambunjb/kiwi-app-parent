import 'dart:convert';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kiwi_app_parent/reportPdf.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import 'package:intl/intl.dart';


class ReportPdfPreview extends StatelessWidget {
  final dynamic data;
  dynamic milks;
  List<String> thingsList;
  List<String> mealsList;
  List<String> napList;

  ReportPdfPreview({Key? key, required this.data, required this.milks, required this.thingsList, required this.mealsList, required this.napList}) : super(key: key) {
    if(milks != null && milks.runtimeType == String) {
      milks = milks.replaceAll('null', '||||');
      milks = milks.replaceAll('{', '{"');
      milks = milks.replaceAll(': ', '": "');
      milks = milks.replaceAll(', ', '", "');
      milks = milks.replaceAll('}', '"}');
      milks = milks.replaceAll('}",', '},');
      milks = milks.replaceAll(', "{', ', {');
      milks = milks.replaceAll('"||||"', 'null');
      milks = jsonDecode(milks);

      milks.sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));

      for(int i=0;i<milks.length;i++) {
        milks[i].removeWhere((key, value) => value == null);
        // time remove second
        if(milks[i]['time']!=null) {
          milks[i]['time'] = '${milks[i]['time'].toString().split(':')[0]}:${milks[i]['time'].toString().split(':')[1]}';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String filename = '${data['child_name'].toString().replaceAll(RegExp(r"\s+"), "")}_${DateFormat('ddMMyyyy').format(DateTime.parse(data['report']['date'].toString().split('.')[0]))}_report.pdf';
    var fileBytes = reportPdf(context, data, milks);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        allowPrinting: false,
        canChangePageFormat: false,
        pdfFileName: filename,
        actions: [
          GestureDetector(
              onTap: () async {
                var status = await Permission.storage.status;
                if(!status.isGranted) {
                  await Permission.storage.request();
                }
                final String dir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                String path = '$dir/$filename';
                if(await File(path).exists()) {
                  path = '$dir/${data['child_name'].toString().replaceAll(RegExp(r"\s+"), "")}_${DateFormat('ddMMyyyy').format(DateTime.parse(data['report']['date'].toString().split('.')[0]))}_${DateFormat('His').format(DateTime.now())}_report.pdf';
                }
                final File file = File(path);
                Fluttertoast.showToast(msg: 'Processing to download...');
                file.writeAsBytes(List.from(await fileBytes)).then((value) async {
                  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
                  var initializationSettingsIOS = const IOSInitializationSettings();
                  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

                  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                  flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (payload) {
                    if (payload != null) OpenFile.open(payload);
                  });

                  var androidPlatformChannelSpecifics = const AndroidNotificationDetails('kidparent_importance_channel', 'KinderCastle Parent Importance Notifications', channelDescription: 'This channel is used for kindercastle parent important notifications.', styleInformation: BigTextStyleInformation(''), importance: Importance.high, priority: Priority.high);
                  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
                  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
                  await flutterLocalNotificationsPlugin.show(0, 'Download report complete', filename, platformChannelSpecifics, payload: path);
                }).onError((error, stackTrace) {
                  // log(error.toString());
                  Fluttertoast.showToast(msg: error.toString());
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: const Icon(Icons.download_rounded, size: 30),
              )
          )
        ],
        build: (context) => fileBytes
      ),
    );
  }
}
