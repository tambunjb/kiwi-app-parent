import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kiwi_app_parent/phoneVerify.dart';

import 'api.dart';
import 'navigationService.dart';

class Login extends StatefulWidget {

  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{
  TextEditingController _phone = TextEditingController();
  String? _completePhone;
  String? _errorText;
  bool _loginClicked = false;

  bool _validateMobile() {
    String pattern = r'(^(?:[+0]9)?[0-9]{9,15}$)';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(_phone.text.trim())) {
      setState(() {
        _errorText = 'Mohon masukkan nomor yang benar';
      });
      return false;
    }
    setState(() {
      _errorText = null;
    });
    return true;
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
                        .height / 9),
                    children: [
                      Column(
                          children: [
                            SizedBox(
                                height: 250,
                                child: Image.asset("images/app-logo.jpg")
                            ),
                            const Padding(
                                padding: EdgeInsets.only(left: 5, top: 25),
                                child: Text('PARENT', style: TextStyle(color: Color(0xFF5A96CC), // 5996CB
                                letterSpacing: 4,
                                fontSize: 28,
                                fontWeight: FontWeight.w900
                              )),
                            ),
                            Container(
                                padding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 48),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: const Text('Login dengan nomor handphone', style: TextStyle(fontSize: 16))
                                      ),
                                      IntlPhoneField(
                                          decoration: InputDecoration(
                                                  focusedBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 2,
                                                        color: Color(0xFF197CD0)
                                                    ),
                                                  ),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color(0xFFE5E5E5)),
                                                  ),
                                                  focusedErrorBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red),
                                                  ),
                                                  hintText: 'Tap to enter phone number',
                                                  errorText: _errorText
                                              ),
                                          initialCountryCode: 'ID',
                                          onChanged: (phone) {
                                            _completePhone = phone.completeNumber.trim();
                                            },
                                          controller: _phone,
                                          keyboardType: TextInputType.number,
                                          autovalidateMode: AutovalidateMode.disabled,
                                          flagsButtonPadding: const EdgeInsets.only(bottom: 2),
                                          dropdownTextStyle: const TextStyle(fontSize: 16)
                                      ),
                                    ]
                                )
                            )
                          ]
                      )
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
                                  if(!_loginClicked) {
                                    setState(() {
                                      _loginClicked = true;
                                    });
                                    if (_validateMobile()) {
                                      final login = await Api.login(
                                          _completePhone!);
                                      if (login) {
                                        NavigationService.instance.navigateToRoute(MaterialPageRoute(
                                            builder: (BuildContext context){
                                              return PhoneVerify(phone: _completePhone!);
                                            })
                                        );
                                      } else {
                                        setState(() {
                                          _errorText = 'Authentication failed';
                                        });
                                      }
                                    }
                                    setState(() {
                                      _loginClicked = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(primary: const Color(0xFF197CD0)),
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child:
                                    _loginClicked ? const SizedBox(
                                      height: 19.0,
                                      width: 19.0,
                                      child: CircularProgressIndicator(color: Colors.white),
                                    )
                                    :
                                    const Text('LOG IN', style: TextStyle(
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
        )
    );
  }
}