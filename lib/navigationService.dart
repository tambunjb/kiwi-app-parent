import 'package:flutter/material.dart';

class NavigationService{
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  static NavigationService instance = NavigationService();

  Future<dynamic> navigateToReplacement(String _rn){
    return navigationKey.currentState!.pushReplacementNamed(_rn);
  }
  Future<dynamic> navigateTo(String _rn){
    return navigationKey.currentState!.pushNamed(_rn);
  }
  Future<dynamic> navigateToRoute(MaterialPageRoute _rn){
    return navigationKey.currentState!.push(_rn);
  }
  Future<dynamic> navigateUntil(String _rn, {String? args}){
    return navigationKey.currentState!.pushNamedAndRemoveUntil(_rn, (route) => false, arguments: args);
  }
  goBack(){
    return navigationKey.currentState!.pop();
  }
  bool canBack(){
    return navigationKey.currentState!.canPop();
  }
}