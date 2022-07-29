import 'package:flutter/material.dart';

class DetailCard extends StatefulWidget {
  final String title;
  final Icon leadIcon;
  final Widget content;

  const DetailCard({Key? key, required this.title, required this.leadIcon, required this.content})
      : super(key: key);

  @override
  _DetailCardState createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10, right: 5, left: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black12, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              textColor: Colors.black,
              contentPadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              title: Text(widget.title, style: const TextStyle(fontSize: 20)),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFADD9FF),
                foregroundColor: const Color(0xFF3F3E40),
                radius: 28,
                child: widget.leadIcon,
              )
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 15, right: 15, left: 88),
              child: widget.content
            )
          ]
      )
    );
  }
}