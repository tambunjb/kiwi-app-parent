import 'package:flutter/material.dart';


class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation, required this.resend}) : super(key: key, listenable: animation);
  Animation<int> animation;
  Function resend;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText = '${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    // print('animation.value  ${animation.value} ');
    // print('inMinutes ${clockTimer.inMinutes.toString()}');
    // print('inSeconds ${clockTimer.inSeconds.toString()}');
    // print('inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');
    // log('====== $timerText');
    return timerText=='00:00'? GestureDetector(
      onTap: () async {
        await resend();
      },
      child: const Text('Kirim\nUlang', style: TextStyle(color: Colors.blue/*, fontWeight: FontWeight.bold*/)),
    ) : Text(timerText, style: const TextStyle(color: Colors.grey));
  }
}