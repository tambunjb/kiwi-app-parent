import 'dart:convert';

import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:kiwi_app_parent/reportPdfPreview.dart';

import 'config.dart';
import 'navigationService.dart';
import 'detailCard.dart';
import 'rating.dart';


class ReportDetail extends StatefulWidget{
  final dynamic data;
  dynamic milks;
  dynamic naps;
  dynamic rating;
  List<String> thingsList;
  List<String> mealsList;
  List<String> napList;
  Function updateReport;

  ReportDetail({Key? key, required this.data, required this.milks, required this.naps, required this.rating, required this.thingsList, required this.mealsList, required this.napList, required this.updateReport}) : super(key: key) {
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

    if(naps != null && naps.runtimeType == String) {
      naps = naps.replaceAll('null', '||||');
      naps = naps.replaceAll('{', '{"');
      naps = naps.replaceAll(': ', '": "');
      naps = naps.replaceAll(', ', '", "');
      naps = naps.replaceAll('}', '"}');
      naps = naps.replaceAll('}",', '},');
      naps = naps.replaceAll(', "{', ', {');
      naps = naps.replaceAll('"||||"', 'null');
      naps = jsonDecode(naps);

      naps.sort((a, b) => a['start'].toString().compareTo(b['start'].toString()));

      for(int i=0;i<naps.length;i++) {
        naps[i].removeWhere((key, value) => value == null);
        // time remove second
        if(naps[i]['start']!=null) {
          naps[i]['start'] = '${naps[i]['start'].toString().split(':')[0]}:${naps[i]['start'].toString().split(':')[1]}';
        }
        if(naps[i]['end']!=null) {
          naps[i]['end'] = '${naps[i]['end'].toString().split(':')[0]}:${naps[i]['end'].toString().split(':')[1]}';
        }
      }
    }

    if(rating != null && rating.runtimeType == String) {
      rating = rating.replaceAll('null', '||||');
      rating = rating.replaceAll('{', '{"');
      rating = rating.replaceAll(': ', '": "');
      rating = rating.replaceAll(', ', '", "');
      rating = rating.replaceAll('}', '"}');
      rating = rating.replaceAll('}",', '},');
      rating = rating.replaceAll(', "{', ', {');
      rating = rating.replaceAll('"||||"', 'null');
      rating = jsonDecode(rating);

      if(rating.length > 0) {
        rating = rating[0];
      }
    }
  }

  @override
  _ReportDetailState createState() => _ReportDetailState();
}

class _ReportDetailState extends State<ReportDetail> {
  // int starTapped = 0;
  bool isSubmit = false;
  String ratingId = '0';

  @override
  void initState() {
    Config().eventDetail(widget.data['id']);

    if(widget.rating!=null && widget.rating.isNotEmpty && widget.rating['id']!=null) {
      ratingId = widget.rating['id'];
    }

    super.initState();
  }

  void _setRatingId(String newRatingId) {
    setState(() {
      ratingId = newRatingId;
    });
  }

  void _setRatingSubmitted() {
    setState(() {
      isSubmit = true;
    });
  }

  List<Widget> listThings() {
    final items = <Widget>[];
    final things = (widget.data['report']['things_tobring_tmr']!=null && widget.data['report']['things_tobring_tmr'].trim()!='')?widget.data['report']['things_tobring_tmr'].toString().split(','):[];
    things.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    for(int i=0;i<things.length;i++) {
      items.add(
          Row(
              children: [
                Expanded(
                    child: Text(textProcess(things[i], isBeginUpper: true), style: const TextStyle(fontSize: 16))
                ),
                const Icon(Icons.check_box, color: Colors.green),
                const SizedBox(height: 15)
              ]
          )
      );
    }
    for(int i=0;i<widget.thingsList.length;i++) {
      if(!things.contains(widget.thingsList[i]) && widget.thingsList[i]!='nothing') {
        items.add(
            Row(
                children: [
                  Expanded(
                      child: Text(textProcess(widget.thingsList[i], isBeginUpper: true), style: const TextStyle(fontSize: 16))
                  ),
                  const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                  const SizedBox(height: 15)
                ]
            )
        );
      }
    }

    return items;
  }

  String textProcess(String? text, {bool isBeginUpper=false}) {
    String textRes = '';
    if(text!=null) {
      textRes = text.toString();
    }
    if(isBeginUpper && textRes.length>1) {
      textRes = '${textRes[0].toUpperCase()}${textRes.substring(1)}';
    }
    return textRes;
  }

  String activitiesProcess(String? activities) {
    if(activities==null) {
      return '';
    }
    final actList = activities.split(',');
    actList.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    String actRes = '';
    for(int i=0;i<actList.length;i++) {
      if(actRes!='') {
        actRes += ', ';
      }
      actRes += textProcess(actList[i], isBeginUpper: true);
    }
    return actRes;
  }

  String bathProcess() {
    String res = '';
    if(widget.data['report']['is_morning_bath']!=null && widget.data['report']['is_morning_bath']=='1') {
      res += 'Morning bath';
    }
    if(widget.data['report']['is_afternoon_bath']!=null && widget.data['report']['is_afternoon_bath']=='1') {
      if(res!='') {
        res += ', ';
      }
      res += 'Afternoon bath';
    }
    return res;
  }

  String medProcess() {
    if(textProcess(widget.data['report']['medication_notes'])!='') {
      return textProcess(widget.data['report']['medication_notes'], isBeginUpper: true);
    }

    return (widget.data['report']['medication']==null || widget.data['report']['medication']=='10')?'N.A.':(widget.data['report']['medication']=='1'?'Yes':'No');
  }

  List<Widget> mealsProcess() {
    List<Widget> items = [];
    for(int i=0;i<widget.mealsList.length;i++) {
      if(items.isNotEmpty) {
        items.add(
            const Divider(
                color: Colors.black12
            )
        );
      }
      items.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: Row(children: [Flexible(
                child: Text('${textProcess(widget.mealsList[i], isBeginUpper: true)}: ${textProcess(widget.data['report'][widget.mealsList[i].replaceAll(' ', '')], isBeginUpper: true)}', style: const TextStyle(fontSize: 16))
              )])
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 1),
              child: Row(children: [Flexible(
                child: Text(
                  (['some', 'a lot'].contains(widget.data['report']['${widget.mealsList[i].replaceAll(' ', '')}_qty'])?
                    ('Ate ${widget.data['report']['${widget.mealsList[i].replaceAll(' ', '')}_qty']}'):'Did not eat') +
                  (textProcess(widget.data['report']['${widget.mealsList[i].replaceAll(' ', '')}_notes'])!=''?
                    ('; ${textProcess(widget.data['report']['${widget.mealsList[i].replaceAll(' ', '')}_notes'], isBeginUpper: true)}'):''),
                  style: const TextStyle(fontSize: 16)
                )
              )])
            )
          ],
        )
      );
    }
    return items;
  }

  List<Widget> milksProcess() {
    List<Widget> items = [];
    for(int i=0;i<widget.milks.length;i++) {
      if(items.isNotEmpty) {
        items.add(
            const Divider(
                color: Colors.black12
            )
        );
      }
      items.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: Row(children: [Flexible(
                  child: Text('${widget.milks[i]['time'].toString().split(':')[0]}:${widget.milks[i]['time'].toString().split(':')[1]} \u2022 ${widget.milks[i]['volume']} ml', style: const TextStyle(fontSize: 16))
                )])
              ),
              textProcess(widget.milks[i]['notes'])==''?Container():Container(
                margin: const EdgeInsets.only(bottom: 1),
                child: Row(children: [Flexible(
                  child: Text(textProcess(widget.milks[i]['notes'], isBeginUpper: true), style: const TextStyle(fontSize: 16))
                )])
              )
            ],
          )
      );
    }
    return items;
  }

  List<Widget> napsProcess() {
    List<Widget> items = [];
    for(int i=0;i<widget.naps.length;i++) {
      if(items.isNotEmpty) {
        items.add(
            const Divider(
                color: Colors.black12
            )
        );
      }
      items.add(
          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Row(children: [Flexible(
                                  child: Text(
                                      '${textProcess(widget.naps[i]['start']) != ''
                                          ?
                                      ('${widget.naps[i]['start'].toString().split(
                                          ':')[0]}:${widget.naps[i]['start'].toString().split(':')[1]}')
                                          : ''} - ${textProcess(
                                          widget.naps[i]['end']) != ''
                                          ?
                                      ('${widget.naps[i]['end'].toString().split(
                                          ':')[0]}:${widget.naps[i]['end'].toString().split(':')[1]}')
                                          : ''}'
                                      , style: const TextStyle(fontSize: 16))
                              )
                              ])
                          ),
                          textProcess(widget.naps[i]['notes'])==''?Container():Container(
                              margin: const EdgeInsets.only(bottom: 1),
                              child: Row(children: [Flexible(
                                  child: Text(textProcess(
                                      widget.naps[i]['notes'],
                                      isBeginUpper: true),
                                      style: const TextStyle(fontSize: 16))
                              )
                              ])
                          )
                        ],
                      )
      );
    }
    return items;
  }

  // List<Widget> napProcess() {
  //   List<Widget> items = [];
  //   for(int i=0;i<widget.napList.length;i++) {
  //     if(!(textProcess(widget.data['report']['${widget.napList[i]}_start'])=='' && textProcess(widget.data['report']['${widget.napList[i]}_end'])=='')) {
  //       if(items.isNotEmpty) {
  //         items.add(
  //             const Divider(
  //                 color: Colors.black12
  //             )
  //         );
  //       }
  //       items.add(
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                   margin: const EdgeInsets.only(bottom: 5),
  //                   child: Row(children: [Flexible(
  //                       child: Text(
  //                           '${textProcess(widget.data['report']['${widget
  //                               .napList[i]}_start']) != ''
  //                               ?
  //                           ('${widget.data['report']['${widget
  //                               .napList[i]}_start'].toString().split(
  //                               ':')[0]}:${widget.data['report']['${widget
  //                               .napList[i]}_start'].toString().split(':')[1]}')
  //                               : ''} - ${textProcess(
  //                               widget.data['report']['${widget
  //                                   .napList[i]}_end']) != ''
  //                               ?
  //                           ('${widget.data['report']['${widget
  //                               .napList[i]}_end'].toString().split(
  //                               ':')[0]}:${widget.data['report']['${widget
  //                               .napList[i]}_end'].toString().split(':')[1]}')
  //                               : ''}'
  //                           , style: const TextStyle(fontSize: 16))
  //                   )
  //                   ])
  //               ),
  //               textProcess(widget.data['report']['${widget.napList[i]}_notes'])==''?Container():Container(
  //                   margin: const EdgeInsets.only(bottom: 1),
  //                   child: Row(children: [Flexible(
  //                       child: Text(textProcess(
  //                           widget.data['report']['${widget.napList[i]}_notes'],
  //                           isBeginUpper: true),
  //                           style: const TextStyle(fontSize: 16))
  //                   )
  //                   ])
  //               )
  //             ],
  //           )
  //       );
  //     }
  //   }
  //   return items;
  // }

  String getVolumeMilk() {
    double totalVolume = 0;
    for(int i=0;i<widget.milks.length;i++){
      totalVolume += double.parse(widget.milks[i]['volume']);
    }
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return totalVolume.toString().replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () {
          if(widget.data['report']['is_submit_rating']=='1' || isSubmit) {
            return Future.value(true);
          }
          NavigationService.instance.navigateToRoute(MaterialPageRoute(
              builder: (BuildContext context){
                return Rating(rating_id: ratingId, report_id: widget.data['report']['id'], date: widget.data['report']['date'], nickname: widget.data['report']['nickname'], updateReport: widget.updateReport, setRatingSubmitted: _setRatingSubmitted, setRatingId: _setRatingId);
              }),
          );
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.0,
              leading: GestureDetector(
                  onTap: () {
                    (widget.data['report']['is_submit_rating']=='1' || isSubmit) ? NavigationService.instance.goBack() :
                    NavigationService.instance.navigateToRoute(MaterialPageRoute(
                        builder: (BuildContext context){
                          return Rating(rating_id: ratingId, report_id: widget.data['report']['id'], date: widget.data['report']['date'], nickname: widget.data['report']['nickname'], updateReport: widget.updateReport, setRatingSubmitted: _setRatingSubmitted, setRatingId: _setRatingId);
                        }),
                    );
                  },
                  child: const Icon(Icons.arrow_back)
              ),
              title: Row(
                  children: [
                    Text(DateFormat('EEEE, d MMM yyyy').format(DateTime.parse(widget.data['report']['date'].toString().split('.')[0])), style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16))
                  ]
              ),
              actions: [
                GestureDetector(
                    onTap: () {
                      NavigationService.instance.navigateToRoute(MaterialPageRoute(
                          builder: (BuildContext context){
                            return ReportPdfPreview(data: widget.data, milks: widget.milks, naps: widget.naps, thingsList: widget.thingsList, mealsList: widget.mealsList, napList: widget.napList);
                          }
                      ));
                      // reportPdf(context, _data, _milks, _setData, _formSubmit, widget.isToday);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.picture_as_pdf),
                    )
                )
              ],
            ),
            backgroundColor: Colors.white,
            body: ListView(
                //padding: const EdgeInsets.only(left: 5, right: 5),
                children: [
                  const Padding(padding: EdgeInsets.only(top:10, bottom:10, left: 15), child: Text('Important for tomorrow', style: TextStyle(fontSize: 24))),
                  DetailCard(title:"Things to bring tomorrow", leadIcon: const Icon(Icons.alarm, size: 30),
                      content: Column(
                          children: listThings()
                      )
                  ),
                  DetailCard(title:"Special notes", leadIcon: const Icon(Icons.message, size: 30),
                      content: Row(children: [Flexible(
                        child: Text(textProcess(widget.data['report']['special_notes'], isBeginUpper: true)!=''?textProcess(widget.data['report']['special_notes'], isBeginUpper: true):'N.A.', style: const TextStyle(fontSize: 16))
                      )])
                  ),
                  const Padding(padding: EdgeInsets.only(top:10, bottom:10, left: 15), child: Text('About today', style: TextStyle(fontSize: 24))),
                  DetailCard(title:"Attendance", leadIcon: const Icon(Icons.event_available, size: 30),
                      content: Row(children: [Flexible(
                          child: Text(widget.data['report']['attendance']=='1'?('Present${widget.data['report']['arrival_time']!=null?(
                              ', arrived at ${widget.data['report']['arrival_time'].toString().split(':')[0]}:${widget.data['report']['arrival_time'].toString().split(':')[1]}'):''}'):'Absent', style: const TextStyle(fontSize: 16))
                      )])
                  ),
                  DetailCard(title:"Mood and health", leadIcon: const Icon(Icons.tag_faces_rounded, size: 30),
                      content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textProcess(widget.data['report']['child_feeling'])==''?Container():Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(children: [Flexible(
                                  child: Text(textProcess(widget.data['report']['child_feeling'], isBeginUpper: true), style: const TextStyle(fontSize: 16))
                                )])
                            ),
                            textProcess(widget.data['report']['temperature'])==''?Container():Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(children: [Flexible(
                                  child: Text(widget.data['report']['temperature']!=null?(widget.data['report']['temperature']+" \u2103"):'', style: const TextStyle(fontSize: 16))
                                )])
                            ),
                            textProcess(widget.data['report']['condition'])==''?Container():Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(children: [Flexible(
                                  child: Text(textProcess(widget.data['report']['condition'])!=''?(textProcess(widget.data['report']['condition'], isBeginUpper: true)+
                                    (textProcess(widget.data['report']['condition_notes'])!=''?'; ${textProcess(widget.data['report']['condition_notes'])}':'')
                                  ):'', style: const TextStyle(fontSize: 16))
                              )])
                            ),
                            textProcess(widget.data['report']['weight'])==''?Container():Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(children: [Flexible(
                                  child: Text(widget.data['report']['weight']!=null?(widget.data['report']['weight']+" kg"):'', style: const TextStyle(fontSize: 16))
                              )])
                            )
                          ]
                      )
                  ),
                  DetailCard(title:"Meals", leadIcon: const Icon(Icons.fastfood, size: 30),
                      content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: mealsProcess()
                      )
                  ),
                  DetailCard(title:"${"Milk \u2022 ${getVolumeMilk()}"} ml", leadIcon: const Icon(Icons.local_drink, size: 30),
                      content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: milksProcess()
                      )
                  ),
                  DetailCard(title:"Nap times", leadIcon: const Icon(Icons.airline_seat_individual_suite, size: 30),
                      content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: napsProcess()
                      )
                  ),
                  DetailCard(title:"Potty", leadIcon: const Icon(Icons.wash, size: 30),
                      content: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(children: [Flexible(
                              child: Text(widget.data['report']['num_of_potty']!=null?(widget.data['report']['num_of_potty']+' times'):'', style: const TextStyle(fontSize: 16))
                            )])
                          ),
                          textProcess(widget.data['report']['potty_notes'])==''?Container():Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(children: [Flexible(
                              child: Text(textProcess(widget.data['report']['potty_notes'], isBeginUpper: true), style: const TextStyle(fontSize: 16))
                            )])
                          )
                        ]
                      )
                  ),
                  DetailCard(title:"Activities", leadIcon: const Icon(Icons.menu_book, size: 30),
                      content: Row(children: [Flexible(
                          child: Text(activitiesProcess(widget.data['report']['activities']), style: const TextStyle(fontSize: 16))
                      )])
                  ),
                  DetailCard(title:"Bath", leadIcon: const Icon(Icons.bathtub, size: 30),
                      content: Row(children: [Flexible(
                          child: Text(bathProcess(), style: const TextStyle(fontSize: 16))
                      )])
                  ),
                  DetailCard(title:"Medication", leadIcon: const Icon(Icons.medical_services, size: 30),
                      content: Row(children: [Flexible(
                          child: Text(medProcess(), style: const TextStyle(fontSize: 16))
                      )])
                  ),
                  widget.data['report']['is_submit_rating']=='1' || isSubmit ?Container():
                  GestureDetector(
                    onTap: () {
                      NavigationService.instance.navigateToRoute(MaterialPageRoute(
                        builder: (BuildContext context){
                          return Rating(rating_id: ratingId, report_id: widget.data['report']['id'], date: widget.data['report']['date'], nickname: widget.data['report']['nickname'], updateReport: widget.updateReport, setRatingSubmitted: _setRatingSubmitted, setRatingId: _setRatingId);
                        }),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                      color: const Color(0xFFf7e2a3),
                      child: Column(
                        children: [
                          const Text('Klik di sini untuk memberi masukan Anda', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getStars()
                          )
                        ],
                      )
                    )
                  )
                ]
            )
        ));
  }

  List<Widget> getStars() {
    List<Widget> stars = [];
    for(int i=1;i<=5;i++) {
      stars.add(GestureDetector(
        onTap: () {
          // setState(() {
          //   starTapped = i;
          // });
          // if(widget.data['report']['rating_id']=='0') {
          //   Api.addRating({'report_id': widget.data['report']['id'], 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(), 'rating': i});
          //   setState(() {
          //     widget.updateReport();
          //   });
          // } else {
          //   Api.editRating(widget.data['report']['rating_id'], {'rating': i});
          // }
          NavigationService.instance.navigateToRoute(MaterialPageRoute(
              builder: (BuildContext context){
                return Rating(rating_id: ratingId, report_id: widget.data['report']['id'], date: widget.data['report']['date'], nickname: widget.data['report']['nickname'], /*star: i,*/ updateReport: widget.updateReport, setRatingSubmitted: _setRatingSubmitted, setRatingId: _setRatingId);
              }),
          );
        },
        child: const Icon(Icons.star, color: /*i<=starTapped?Color(0xFFf8d464):*/Colors.white, size: 50),
      ));
    }
    return stars;
  }
}
