import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

import 'package:flutter/material.dart';

import 'api.dart';
import 'config.dart';
import 'navigationService.dart';


class Rating extends StatefulWidget {
  String rating_id;
  String report_id;
  int star;
  String date;
  String nickname;
  Function updateReport;
  Function setRatingSubmitted;
  Function setRatingId;

  Rating({Key? key, required this.rating_id, required this.report_id, required this.date, required this.nickname, this.star = 0, required this.updateReport, required this.setRatingSubmitted, required this.setRatingId}) : super(key: key);

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  Future? _dataRf;
  late int starForm;
  bool isSubmit = false;
  String ratingId = '0';
  List<String> items = [];

  @override
  void initState() {
    starForm = widget.star;
    if(widget.rating_id != '0') {
      ratingId = widget.rating_id;
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _dataRf = Api.getRatingLabelsItems();

    super.didChangeDependencies();
  }

  Widget formRating(BuildContext context, Map data) {
    if(!isSubmit && starForm==0) {
      Config().eventRatingOverview(widget.report_id);
    }


    return isSubmit?

    // rating thanks
    Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
                  children: [
                    const Flexible(
                        child: Text('Terima kasih~\nMasukan Anda sudah kami terima', style: TextStyle(fontSize: 24, height: 1.5), textAlign: TextAlign.center)
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        height: 250,
                        child: Image.asset("images/app-logo.jpg")
                    ),
                    const SizedBox(height: 30),
                    Flexible(
                        child: Text('Masukan Anda akan selalu ditanggapi secara serius, dan akan membantu kami mengasuh ${widget.nickname} dan anak-anak lainnya.', style: const TextStyle(height: 1.5), textAlign: TextAlign.center)
                    ),
                  ]
              )
          ),
          Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              NavigationService.instance.goBack();
                            },
                            style: ElevatedButton.styleFrom(primary: const Color(0xFF197CD0)),
                            child: Container(
                                padding: const EdgeInsets.all(16),
                                child:
                                // _loginClicked ? const SizedBox(
                                //   height: 21.0,
                                //   width: 21.0,
                                //   child: CircularProgressIndicator(color: Colors.white),
                                // )
                                //     :
                                const Text('SELESAI', style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 16))
                            )
                        )
                    )
                  ]
              )
          )
        ]
    )) : (starForm==0 ?

    // rating overview
    Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              child: Text('Seberapa puaskah Anda\ndengan pelayanan\nKinderCastle hari ini?', style: TextStyle(fontSize: 24, /*fontWeight: FontWeight.bold,*/ height: 1.5), textAlign: TextAlign.center)
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getStars(65)
            ),
            const SizedBox(height: 30),
            Flexible(
                child: Text('Masukan Anda akan selalu ditanggapi secara serius, dan akan membantu kami mengasuh ${widget.nickname} dan anak-anak lainnya.', style: const TextStyle(height: 1.5), textAlign: TextAlign.center)
            ),
          ],
        )
    ):

    // rating form
    Column(children: [Expanded(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Text(data['labels'].toString().split(',')[starForm-1].split(" ").map((str) => toBeginningOfSentenceCase(str)).join(" "), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: getStars(50) //[
                  //   for(int i=1;i<=5;i++)
                  //     Icon(i<=starForm?Icons.star:Icons.star_border, color: const Color(0xFFf8d464), size: 50)
                  // ]
                )
              ]
            ),
            const Divider(color: Colors.black12, thickness: 2),
            const SizedBox(height: 15),
            const Flexible(
              child: Text('Apakah alasan utama Anda dalam memberikan rating di atas? (Boleh pilih lebih dari satu)', style: TextStyle(color: Colors.grey))
            ),
            const SizedBox(height: 25),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Flexible(
              child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 10,
                  spacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    for(String item in (data['items_$starForm']!=null ? data['items_$starForm'].split(',') : data['items_0'].split(',')))
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              if(items.contains(item)) {
                                items.remove(item);
                              } else {
                                items.add(item);
                              }
                            });
                            Api.editRating(ratingId, {'items': items.join(',')});
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                  color: items.contains(item)?const Color(0xFFdcfbe4):Colors.black12,
                                  // border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.all(Radius.circular(30))
                              ),
                              child: Text(item.split(' ').map((str) => toBeginningOfSentenceCase(str)).join(' '), style: const TextStyle(fontSize: 17))
                          )
                      )
                  ]
              ),
            )]),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 5,
              onChanged: (text) {
                Api.editRating(ratingId, {'review': text.trim()});
              },
              // controller: _notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Masukan lainnya (opsional)',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey),
                ),
              ),
            )
          ]
        )
    )),
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Api.editRating(ratingId, {'is_submit': '1'});
                    widget.updateReport();
                    widget.setRatingSubmitted();
                    setState(() {
                      isSubmit = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: const Color(0xFF197CD0)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child:  const Text('KIRIM', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 16
                    )
                  )
                )
              )
            )
          ]
        )
    )]));
  }

  List<Widget> getStars(double size) {
    List<Widget> stars = [];
    for(int i=1;i<=5;i++) {
      stars.add(GestureDetector(
        onTap: () {
          setState(() {
            starForm = i;
          });
          if(ratingId == '0') {
            Api.addRating({'report_id': widget.report_id, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(), 'rating': i}).then((value) {
              setState((){
                ratingId = value.toString();
              });
              widget.setRatingId(ratingId);
              widget.updateReport();
            });
          } else {
            Api.editRating(ratingId, {'rating': i});
          }
        },
        child: Icon(i<=starForm?Icons.star:Icons.star_outline, color: const Color(0xFFf8d464), size: size)
      ));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if(starForm == 0) {
            while(NavigationService.instance.canBack()) {
              NavigationService.instance.goBack();
            }
          } else {
            NavigationService.instance.goBack();
          }
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.0,
            leading: GestureDetector(
                onTap: () {
                  if(starForm == 0) {
                    while(NavigationService.instance.canBack()) {
                      NavigationService.instance.goBack();
                    }
                  } else {
                    NavigationService.instance.goBack();
                  }
                },
                child: const Icon(Icons.arrow_back)
            ),
            title: Row(
                children: [
                  Text(DateFormat('EEEE, d MMM yyyy').format(DateTime.parse(widget.date.split('.')[0])), style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16))
                ]
            ),
          ),
          backgroundColor: Colors.white,
          body: FutureBuilder(
            future: _dataRf,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return formRating(context, snapshot.data as Map);
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

}