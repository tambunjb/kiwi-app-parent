import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';


Image getImg(ByteData bytes) {
  final Uint8List img = bytes.buffer.asUint8List();
  return Image(
      MemoryImage(
          img
      ),
      fit: BoxFit.contain
  );
}

Checkbox getCheckbox(String name, bool value) {
  return Checkbox(
      decoration: BoxDecoration(
        //color: PdfColors.black,
          border: Border.all(color: PdfColors.black, width: 5, style: BorderStyle.solid)
      ),
      width: 6,
      height: 7,
      checkColor: value?PdfColors.black:PdfColors.white,
      activeColor: PdfColors.white,
      name: name,
      value: value
  );
}

Checkbox getCheckboxThings(String name, bool value) {
  return Checkbox(
      decoration: BoxDecoration(
        //color: PdfColors.black,
          border: Border.all(color: PdfColors.black, width: 7, style: BorderStyle.solid)
      ),
      checkColor: value?PdfColors.black:PdfColors.white,
      activeColor: PdfColors.white,
      name: name,
      value: value
  );
}

Future<Uint8List> reportPdf(context, data, milks, naps) async {
  // try {
    final Document pdf = Document();

    final ByteData logoHeader = await rootBundle.load('images/app-logo.jpg');
    final ByteData imgFooter = await rootBundle.load('images/pdf-footer.png');
    final ByteData moodHappy = await rootBundle.load('images/mood-happy.png');
    final ByteData moodSad = await rootBundle.load('images/mood-sad.png');
    final ByteData moodAngry = await rootBundle.load('images/mood-angry.png');
    final ByteData moodSick = await rootBundle.load('images/mood-sick.png');
    final ByteData gsHappy = await rootBundle.load(
        'images/grayscale-happy.png');
    final ByteData gsSad = await rootBundle.load('images/grayscale-sad.png');
    final ByteData gsAngry = await rootBundle.load(
        'images/grayscale-angry.png');
    final ByteData gsSick = await rootBundle.load('images/grayscale-sick.png');

    final ByteData iconStar = await rootBundle.load('images/icon-star.png');
    final ByteData iconPoop = await rootBundle.load('images/icon-poop.png');
    final ByteData iconDuck = await rootBundle.load('images/icon-duck.png');
    final ByteData gsDuck = await rootBundle.load('images/grayscale-duck.png');
    final ByteData ellipseFill = await rootBundle.load(
        'images/ellipse-fill.PNG');
    final ByteData ellipseEmpty = await rootBundle.load(
        'images/ellipse-empty.PNG');
    final ByteData checkboxChecked = await rootBundle.load(
        'images/checkbox-checked.png');
    final ByteData checkboxUncheck = await rootBundle.load(
        'images/checkbox-uncheck.png');

    double tempVolMilks = 0;
    String timeMilks = '';

    final activities = data['report']['activities'].toString().split(',');
    final things = data['report']['things_tobring_tmr'].toString().split(',');
    for (int i = 0; i < milks.length; i++) {
      if(milks[i].isEmpty) {
        continue;
      }
      if (timeMilks != '') {
        timeMilks += ', ';
      }
      timeMilks += milks[i]['time'].toString().split(':')[0] + ':' +
          milks[i]['time'].toString().split(':')[1] + ' (' +
          milks[i]['volume'].toString() + ' ml)';
      tempVolMilks += (milks[i]['volume']!=null && double.tryParse(milks[i]['volume'].toString())!=null)?double.parse(milks[i]['volume'].toString()):0;
    }
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    String volumeMilks = tempVolMilks.toString().replaceAll(regex, '');

    pdf.addPage(MultiPage(
        maxPages: 100,
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 80.0),
                    Text("Child's Daily Care Report", style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
                    Container(
                        height: 80,
                        child: getImg(logoHeader)
                    )
                  ]
              )
          );
        },
        footer: (Context context) {
          return Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                  children: [
                    Container(
                        height: 65,
                        child: getImg(imgFooter)
                    ),
                    Container(
                        height: 65,
                        child: getImg(imgFooter)
                    ),
                    Container(
                        height: 65,
                        child: getImg(imgFooter)
                    )
                  ]
              )
          );
        },
        build: (Context context) =>
        <Widget>[
          Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Row(
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DATE: ' + (data['report']['date']!=null?DateFormat('d/M/yyyy')
                                        .format(DateTime.parse(
                                        data['report']['date'].toString().split('.')[0])):'')
                                    ),
                                    Text('Arrival time: ' + (data['report']['arrival_time']!=null?(
                                        data['report']['arrival_time']
                                            .toString()
                                            .split(':')[0] + ':' +
                                            data['report']['arrival_time']
                                                .toString()
                                                .split(':')[1]):'')
                                    ),
                                    Row(
                                        children: [
                                          Text(
                                            "Healthy",
                                            style: TextStyle(
                                                decorationStyle: TextDecorationStyle
                                                    .solid,
                                                decoration: data['report']['condition']!=null && data['report']['condition'] ==
                                                    'sick'
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none
                                            ),
                                          ),
                                          Text(' / '),
                                          Text(
                                            "Sick",
                                            style: TextStyle(
                                                decorationStyle: TextDecorationStyle
                                                    .solid,
                                                decoration: data['report']['condition']!=null && data['report']['condition'] ==
                                                    'healthy'
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none
                                            ),
                                          )
                                        ]
                                    )
                                  ]
                              )
                          ),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nanny in charge: ' +
                                        (data['nanny_name']??'')),
                                    Text('Temperature: ' +
                                        (data['report']['temperature']??'') + ' C'),
                                    Text('Weight: ' + (data['report']['weight']??'') +
                                        ' kg')
                                  ]
                              )
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Center(
                              child: Text('My mood today: ')
                          ),
                          Container(
                              height: 80,
                              child: getImg(
                                  data['report']['child_feeling']!=null && data['report']['child_feeling'] == 'happy'
                                      ? moodHappy
                                      : gsHappy)
                          ),
                          Center(
                              child: Text('HAPPY', style: TextStyle(
                                  decoration: data['report']['child_feeling']!=null && data['report']['child_feeling'] ==
                                      'happy'
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough
                              ))
                          ),
                          SizedBox(width: 20),
                          Container(
                              height: 80,
                              child: getImg(
                                  data['report']['child_feeling']!=null && data['report']['child_feeling'] == 'sad'
                                      ? moodSad
                                      : gsSad)
                          ),
                          Center(
                              child: Text('SAD', style: TextStyle(
                                  decoration: data['report']['child_feeling']!=null && data['report']['child_feeling'] ==
                                      'sad'
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough
                              ))
                          ),
                          SizedBox(width: 20),
                          Container(
                              height: 80,
                              child: getImg(
                                  data['report']['child_feeling']!=null && data['report']['child_feeling'] == 'angry'
                                      ? moodAngry
                                      : gsAngry)
                          ),
                          Center(
                              child: Text('ANGRY', style: TextStyle(
                                  decoration: data['report']['child_feeling']!=null && data['report']['child_feeling'] ==
                                      'angry'
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough
                              ))
                          ),
                          SizedBox(width: 20),
                          Container(
                              height: 80,
                              child: getImg(
                                  data['report']['condition']!=null && data['report']['condition'] == 'sick'
                                      ? moodSick
                                      : gsSick)
                          ),
                          Center(
                              child: Text('SICK', style: TextStyle(
                                  decoration: data['report']['condition']!=null && data['report']['condition'] ==
                                      'sick'
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough
                              ))
                          ),
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meals: ', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                          Table(
                              border: TableBorder.all(),
                              columnWidths: {
                                0: const FlexColumnWidth(),
                                1: const FlexColumnWidth(),
                                2: const FlexColumnWidth(),
                                3: const FlexColumnWidth(),
                                4: const FlexColumnWidth()
                              },
                              children: [
                                TableRow(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          child: Column(
                                              children: [
                                                Text("Breakfast",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                SizedBox(height: 5),
                                                Container(
                                                  //padding: EdgeInsets.all(2),
                                                    child: Row(
                                                        children: [
                                                          // getCheckbox(
                                                          //     'breakfast_none',
                                                          //     data['report']['breakfast_qty']!=null && data['report']['breakfast_qty'] ==
                                                          //         'none'),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['breakfast_qty']!=null && data['report']['breakfast_qty'] ==
                                                                      'none')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('None',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['breakfast_qty']!=null && data['report']['breakfast_qty'] ==
                                                                      'some')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Some',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['breakfast_qty']!=null && data['report']['breakfast_qty'] ==
                                                                      'a lot')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Lot',
                                                              style: const TextStyle(
                                                                  fontSize: 10))
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          child: Column(
                                              children: [
                                                Text("Snack",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                SizedBox(height: 5),
                                                Container(
                                                  //padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                        children: [
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['morningsnack_qty']!=null && data['report']['morningsnack_qty'] ==
                                                                      'none')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('None',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['morningsnack_qty']!=null && data['report']['morningsnack_qty'] ==
                                                                      'some')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Some',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['morningsnack_qty']!=null && data['report']['morningsnack_qty'] ==
                                                                      'a lot')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Lot',
                                                              style: const TextStyle(
                                                                  fontSize: 10))
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          child: Column(
                                              children: [
                                                Text("Lunch",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                SizedBox(height: 5),
                                                Container(
                                                  //padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                        children: [
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['lunch_qty']!=null && data['report']['lunch_qty'] ==
                                                                      'none')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('None',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['lunch_qty']!=null && data['report']['lunch_qty'] ==
                                                                      'some')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Some',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['lunch_qty']!=null && data['report']['lunch_qty'] ==
                                                                      'a lot')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Lot',
                                                              style: const TextStyle(
                                                                  fontSize: 10))
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          child: Column(
                                              children: [
                                                Text("Snack",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                SizedBox(height: 5),
                                                Container(
                                                  //padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                        children: [
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['afternoonsnack_qty']!=null && data['report']['afternoonsnack_qty'] ==
                                                                      'none')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('None',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['afternoonsnack_qty']!=null && data['report']['afternoonsnack_qty'] ==
                                                                      'some')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Some',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['afternoonsnack_qty']!=null && data['report']['afternoonsnack_qty'] ==
                                                                      'a lot')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Lot',
                                                              style: const TextStyle(
                                                                  fontSize: 10))
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          child: Column(
                                              children: [
                                                Text("Dinner",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                SizedBox(height: 5),
                                                Container(
                                                  //padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                        children: [
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['dinner_qty']!=null && data['report']['dinner_qty'] ==
                                                                      'none')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('None',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['dinner_qty']!=null && data['report']['dinner_qty'] ==
                                                                      'some')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Some',
                                                              style: const TextStyle(
                                                                  fontSize: 10)),
                                                          SizedBox(width: 3),
                                                          Container(
                                                              height: 10,
                                                              child: getImg(
                                                                  (data['report']['dinner_qty']!=null && data['report']['dinner_qty'] ==
                                                                      'a lot')
                                                                      ? checkboxChecked
                                                                      : checkboxUncheck)
                                                          ),
                                                          SizedBox(width: 1),
                                                          Text('Lot',
                                                              style: const TextStyle(
                                                                  fontSize: 10))
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                      )
                                    ]
                                ),
                                TableRow(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                    data['report']['breakfast']??''),
                                                Text(
                                                    data['report']['breakfast_notes'] !=
                                                        null &&
                                                        data['report']['breakfast_notes'] !=
                                                            ''
                                                        ? ('# ' +
                                                        data['report']['breakfast_notes'])
                                                        : '')
                                              ]
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                    data['report']['morningsnack']??''),
                                                Text(
                                                    data['report']['morningsnack_notes'] !=
                                                        null &&
                                                        data['report']['morningsnack_notes'] !=
                                                            ''
                                                        ? ('# ' +
                                                        data['report']['morningsnack_notes'])
                                                        : '')
                                              ]
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(data['report']['lunch']??''),
                                                Text(
                                                    data['report']['lunch_notes'] !=
                                                        null &&
                                                        data['report']['lunch_notes'] !=
                                                            ''
                                                        ? ('# ' +
                                                        data['report']['lunch_notes'])
                                                        : '')
                                              ]
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                    data['report']['afternoonsnack']??''),
                                                Text(
                                                    data['report']['afternoonsnack_notes'] !=
                                                        null &&
                                                        data['report']['afternoonsnack_notes'] !=
                                                            ''
                                                        ? ('# ' +
                                                        data['report']['afternoonsnack_notes'])
                                                        : '')
                                              ]
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(data['report']['dinner']??''),
                                                Text(
                                                    data['report']['dinner_notes'] !=
                                                        null &&
                                                        data['report']['dinner_notes'] !=
                                                            ''
                                                        ? ('# ' +
                                                        data['report']['dinner_notes'])
                                                        : '')
                                              ]
                                          ))
                                    ]
                                ),
                              ]
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MILK: '),
                          SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                    child: Text(
                                        'TOTAL: ' + volumeMilks + ' ml, at ' +
                                            timeMilks)
                                )
                              ]
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nap times: '),
                          SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for(int i=0;i<naps.length;i++)
                                  Expanded(
                                      child: Row(
                                          children: [
                                            Container(
                                                height: 20,
                                                child: getImg(iconStar)
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                                (naps[i]['start'] !=
                                                    null &&
                                                    naps[i]['start'] !=
                                                        '')
                                                    ? ('${naps[i]['start'].toString().split(':')[0]}:${naps[i]['start'].toString().split(':')[1]}')
                                                    : '....:....'),
                                            SizedBox(width: 5),
                                            Text('UNTIL'),
                                            SizedBox(width: 5),
                                            Text(
                                                (naps[i]['end'] !=
                                                    null &&
                                                    naps[i]['end'] !=
                                                        '')
                                                    ? ('${naps[i]['end'].toString().split(':')[0]}:${naps[i]['end'].toString().split(':')[1]}')
                                                    : '....:....')
                                          ]
                                      )
                                  )
                              ]
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Row(
                        children: [
                          Expanded(
                              child: Row(
                                  children: [
                                    Text('POTTY: ' +
                                        (data['report']['num_of_potty']??'')),
                                    SizedBox(width: 5),
                                    Container(
                                        height: 20,
                                        child: getImg(iconPoop)
                                    ),
                                  ]
                              )
                          ),
                          Expanded(
                              child: Row(
                                  children: [
                                    Text('BATH: '),
                                    SizedBox(width: 10),
                                    Container(
                                        height: 20,
                                        child: getImg(
                                            data['report']['is_morning_bath']!=null && data['report']['is_morning_bath'] ==
                                                '1' ? iconDuck : gsDuck)
                                    ),
                                    SizedBox(width: 5),
                                    Text('Morning', style: TextStyle(
                                        decoration: data['report']['is_morning_bath']!=null && data['report']['is_morning_bath'] ==
                                            '1'
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough
                                    )),
                                    SizedBox(width: 10),
                                    Container(
                                        height: 20,
                                        child: getImg(
                                            data['report']['is_afternoon_bath']!=null && data['report']['is_afternoon_bath'] ==
                                                '1' ? iconDuck : gsDuck)
                                    ),
                                    SizedBox(width: 5),
                                    Text('Afternoon', style: TextStyle(
                                        decoration: data['report']['is_afternoon_bath']!=null && data['report']['is_afternoon_bath'] ==
                                            '1'
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough
                                    ))
                                  ]
                              )
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MY ACTIVITIES TODAY ARE:'),
                          SizedBox(height: 5),
                          Row(
                              children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'music')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Music', style: TextStyle(
                                                    decoration: activities
                                                        .contains('music')
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                        .lineThrough
                                                ))
                                              ]
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'books')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Books', style: TextStyle(
                                                    decoration: activities
                                                        .contains('books')
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                        .lineThrough
                                                ))
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'puzzles')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Puzzles', style: TextStyle(
                                                    decoration: activities
                                                        .contains('puzzles')
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                        .lineThrough
                                                ))
                                              ]
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'socialising')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Socialising',
                                                    style: TextStyle(
                                                        decoration: activities
                                                            .contains(
                                                            'socialising')
                                                            ? TextDecoration
                                                            .none
                                                            : TextDecoration
                                                            .lineThrough
                                                    ))
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'building blocks')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Building blocks',
                                                    style: TextStyle(
                                                        decoration: activities
                                                            .contains(
                                                            'building blocks')
                                                            ? TextDecoration
                                                            .none
                                                            : TextDecoration
                                                            .lineThrough
                                                    ))
                                              ]
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'cooking')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Cooking', style: TextStyle(
                                                    decoration: activities
                                                        .contains('cooking')
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                        .lineThrough
                                                ))
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'art')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Art', style: TextStyle(
                                                    decoration: activities
                                                        .contains('art')
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                        .lineThrough
                                                ))
                                              ]
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        activities.contains(
                                                            'colouring')
                                                            ? ellipseFill
                                                            : ellipseEmpty)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Colouring',
                                                    style: TextStyle(
                                                        decoration: activities
                                                            .contains(
                                                            'colouring')
                                                            ? TextDecoration
                                                            .none
                                                            : TextDecoration
                                                            .lineThrough
                                                    ))
                                              ]
                                          )
                                        ]
                                    )
                                )
                              ]
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MEDICINE / VITAMIN: ' +
                              (data['report']['medication'] == '1'
                                  ? 'Yes'
                                  : (data['report']['medication'] == '0'
                                  ? 'No'
                                  : (data['report']['medication'] == '10'
                                  ? 'N.A.'
                                  : '')))),
                          SizedBox(height: 5),
                          (data['report']['medication_notes'] != null &&
                              data['report']['medication_notes'] != '') ?
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('# ' + data['report']['medication_notes'])
                              ]
                          ) : Container()
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Please bring for tomorrow:'),
                          SizedBox(height: 10),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                //getCheckboxThings('things_milk',things.contains('milk')),
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('milk')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Milk'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('diapers')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Diapers'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('socks')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Socks'),
                                              ]
                                          ),
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('swimsuit')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Swimsuit'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('panties')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Panties'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('pajamas')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Pajamas'),
                                              ]
                                          ),
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('vitamin')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Vitamin'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('clothes')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Clothes'),
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('soap')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Soap'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('shampoo')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Shampoo'),
                                              ]
                                          )
                                        ]
                                    )
                                ),
                                Expanded(
                                    child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('towel')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Towel'),
                                              ]
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    height: 20,
                                                    child: getImg(
                                                        things.contains('nothing')
                                                            ? checkboxChecked
                                                            : checkboxUncheck)
                                                ),
                                                SizedBox(width: 5),
                                                Text('Nothing'),
                                              ]
                                          )
                                        ]
                                    )
                                )
                              ]
                          )
                        ]
                    )),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Special notes: '),
                          SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(data['report']['special_notes'] ?? '')
                              ]
                          )
                        ]
                    ))
              ]
          )
        ]
    ));

    return await pdf.save();

}