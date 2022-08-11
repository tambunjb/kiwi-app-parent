import 'dart:async';
import 'dart:developer';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'api.dart';
import 'config.dart';
import 'countdown.dart';
import 'navigationService.dart';

class PhoneVerify extends StatefulWidget {
  String phone;
  PhoneVerify({Key? key, required this.phone}) : super(key: key);

  @override
  _PhoneVerifyState createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> with TickerProviderStateMixin {
  bool _confirmationClicked = false;
  TextEditingController _codeCtrl = TextEditingController();
  bool _hasError = false;
  String _errorText = '';
  late AnimationController _timerCtrl;
  final int _duration = 120;
  String _verificationId = '';
  bool _canConfirm = false;

  @override
  void initState() {
    sendAuth();
    _timerCtrl = AnimationController(
      vsync: this,
        duration: Duration(
              seconds: _duration
          )
      );
      _timerCtrl.forward();

    super.initState();
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    super.dispose();
  }

  Future<void> resend() async {
    await sendAuth();
    setState(() {
        _timerCtrl = AnimationController(
            vsync: this,
            duration: Duration(
                seconds: _duration
            )
        );
        _timerCtrl.forward();
      });
  }

  Future<void> loginSuccess() async {
    try {
      await Config().setToken();

      if (await Config().getFirstLaunch() == null) {
        await Config().eventLaunch();
        await Config().setFirstLaunch();
      }

      NavigationService.instance.navigateUntil("home");
    } catch(e, stacktrace) {
      logErrApi(e, stacktrace);
    }
  }

  Future<bool> verifyCode(String code) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // play store release access review
    if(widget.phone == '+6281381301302' && code == '220210') {
      return true;
    }

    AuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
    return auth.signInWithCredential(credential).then((UserCredential result) {
      return true;
    }).catchError((e, stacktrace) {
      // log(e.toString());
      setState(() {
        _hasError = true;
        _confirmationClicked = false;
        _errorText = e.toString();
      });
      logErrApi(e, stacktrace);

      return false;
    });
  }

  Future<void> sendAuth() async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.verifyPhoneNumber(
        phoneNumber: widget.phone,
        timeout: Duration(seconds: _duration),
        verificationCompleted: (AuthCredential authCredential) {
          // log("authCredential.asMap()['smsCode'] ==== ${authCredential.asMap()['smsCode']}");
          setState(() {
            _hasError = false;
            _codeCtrl.text = authCredential.asMap()['smsCode'];
            _confirmationClicked = true;
          });
          _auth.signInWithCredential(authCredential).then((UserCredential result){
            loginSuccess();
          }).catchError((e, stacktrace) {
            // log(e);
            setState(() {
              _hasError = true;
              _confirmationClicked = false;
              _errorText = e.toString();
            });
            logErrApi(e, stacktrace);
          });
        },
        verificationFailed: (FirebaseAuthException authException){
          // log("send auth verificationFailed ======= ${authException.message!}");
          setState(() {
            _hasError = true;
            _errorText = authException.message!;
          });
        },
        codeSent: (String verificationId, [int? forceResendingToken]){
          // log("send auth codeSent verificationId ====== $verificationId");
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId){
          // verificationId = verificationId;
          // log("send auth codeAutoRetrievalTimeout ====== $verificationId Timeout");
        }
    );
  }

  Future<void> logErrApi(var e, var stacktrace) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map desc = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    Api.addConfig(name: 'log_kidparent_otpconfirm_${(desc['model'].toString()+desc['board'].toString()).replaceAll(RegExp(r"\s+"), "")}_${DateTime.now().millisecondsSinceEpoch}', value: "$e\n$stacktrace", desc: desc.toString()).toString();
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              Expanded(
                child:
                ListView(
                    padding: EdgeInsets.only(top: MediaQuery
                        .of(context)
                        .size
                        .height / 12),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: const Text('Kode verifikasi sudah dikirim!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                              ),
                              Container(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  child: Text('Masukkan kode yang kami SMS ke ${widget.phone}', style: TextStyle(fontSize: 17))
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: PinCodeTextField(
                                      enablePinAutofill: true,
                                      useExternalAutoFillGroup: true,
                                      autoFocus: true,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      appContext: context,
                                      // pastedTextStyle: TextStyle(
                                      //   color: Colors.green.shade600,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                      length: 6,
                                      obscureText: false,
                                      // obscuringCharacter: '*',
                                      // obscuringWidget: const FlutterLogo(
                                      //   size: 24,
                                      // ),
                                      // blinkWhenObscuring: true,
                                      // animationType: AnimationType.fade,
                                      // validator: (v) {
                                      //   return null;
                                      // },
                                      textStyle: TextStyle(color: _hasError ? Colors.red :Colors.black ),
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.underline,
                                        // borderRadius: BorderRadius.circular(5),
                                        // fieldHeight: 50,
                                        // fieldWidth: 40,
                                        // activeFillColor: Colors.white,
                                        selectedColor: _hasError ? Colors.red : Colors.black,
                                        inactiveFillColor: Colors.white,
                                        activeColor: _hasError ? Colors.red : Colors.black,
                                        selectedFillColor: Colors.white,
                                        errorBorderColor: _hasError ? Colors.red : Colors.white,
                                        inactiveColor: _hasError ? Colors.red : Colors.black,
                                      ),
                                      cursorColor: Colors.black,
                                      // animationDuration: const Duration(milliseconds: 300),
                                      animationType: AnimationType.none,
                                      enableActiveFill: false,
                                      // errorAnimationController: _errorCtrl,
                                      controller: _codeCtrl,
                                      keyboardType: TextInputType.number,
                                      // boxShadows: const [
                                      //   BoxShadow(
                                      //     offset: Offset(0, 1),
                                      //     color: Colors.black12,
                                      //     blurRadius: 10,
                                      //   )
                                      // ],
                                      // onCompleted: (v) {
                                      //   log("Completed");
                                      // },
                                      // onTap: () {
                                      //   print("Pressed");
                                      // },
                                      onChanged: (value) {
                                        if (value.length == 6) {
                                          setState(() {
                                            _canConfirm = true;
                                          });
                                        } else {
                                          setState(() {
                                            _canConfirm = false;
                                          });
                                        }
                                      },
                                      beforeTextPaste: (text) {
                                        //log("Allowing to paste $text");
                                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                        return true;
                                      },
                                    )
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width / 10,
                                    alignment: Alignment.centerRight,
                                    child: Countdown(
                                        animation: StepTween(
                                          begin: _duration,
                                          end: 0,
                                        ).animate(_timerCtrl),
                                        resend: resend
                                      ),
                                  )
                                ]
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(_hasError ? _errorText : "", style: const TextStyle(color: Colors.red))
                                      )
                                    ]
                                )
                              )
                            ]
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if(_canConfirm && !_confirmationClicked) {
                                    setState(() {
                                      _hasError = false;
                                      _confirmationClicked = true;
                                    });
                                    if (await verifyCode(_codeCtrl.text)) {
                                      // log("_codeCtrl.text ==== ${_codeCtrl.text}");
                                      loginSuccess();
                                    } else {
                                      setState(() {
                                        _hasError = true;
                                        _errorText = "Mohon masukkan kode yang benar";
                                      });
                                    }
                                    setState(() {
                                      _confirmationClicked = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(primary: _canConfirm ? const Color(0xFF197CD0) : Colors.grey),
                                child: Container(
                                    padding: const EdgeInsets.all(15),
                                    child:
                                    _confirmationClicked ? const SizedBox(
                                      height: 18.0,
                                      width: 18.0,
                                      child: CircularProgressIndicator(color: Colors.white),
                                    )
                                        :
                                    const Text('KONFIRMASI', style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        fontSize: 15))
                                )
                            )
                        )
                      ]
                  )
              )
            ]
        )
    );
  }

}