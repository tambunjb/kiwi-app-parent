import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'config.dart';

class Api {
  static const String _baseUrl = 'https://api.kindercastle.co.id/'; // 'http://192.168.1.3/'
  static const String _contentType = 'application/x-www-form-urlencoded; charset=UTF-8';

  static Future<Map<String, String>> _buildHeaders({bool token = true}) async {
    Map<String, String> headers = {
      'Content-Type': _contentType,
    };
    if(token){
      headers.addAll({'Authorization': 'Bearer ${await Config().getToken()}'});
    }

    return headers;
  }

  static Future<dynamic> _processBody(dynamic body) async {
    body.updateAll((key, value) => value.toString());
    return body;
  }

  static Future<bool> login(String phone) async {
    final response = await http.post(
        Uri.parse('${_baseUrl}login-guardian'),
        headers: await _buildHeaders(token: false),
        body: await _processBody({'phone': phone })
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      Config().setPreToken(body['token'], body['child_subscribes'], body['phone']);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static dynamic _processReturn(http.Response response){
    if (response.statusCode == 401) {
      Config().logout();
    } else if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body;
    } else {
      log(response.body);
    }

    return Future.value(false);
  }

  static Future<bool> addLogConfig({required String name, required String value, String desc = ''}) async {
    final response = await http.post(
        Uri.parse('${_baseUrl}config/add-log'),
        headers: await _buildHeaders(token: false),
        body: await _processBody({ 'name': name, 'value': value, 'desc': desc })
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> addConfig({required String name, required String value, String desc = ''}) async {
    final response = await http.post(
        Uri.parse('${_baseUrl}config/add'),
        headers: await _buildHeaders(),
        body: await _processBody({ 'name': name, 'value': value, 'desc': desc })
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<dynamic> getVersionUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<String, String> queryParams = {
      'appid': 'kidparent',
      'version': packageInfo.buildNumber.toString()
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}config/get-version-update')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getRatingLabelsItems() async {
    Map<String, String> queryParams = {
      'appid': 'kidparent',
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}config/get-rating-labels-items')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> addRating(Map<String, dynamic> rating) async {
    final response = await http.post(
        Uri.parse('${_baseUrl}rating/add'),
        headers: await _buildHeaders(),
        body: await _processBody(rating)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['id'];
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> editRating(String id, Map<String, dynamic> rating) async {
    final response = await http.post(
        Uri.parse('${_baseUrl}rating/edit/$id'),
        headers: await _buildHeaders(),
        body: await _processBody(rating)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<dynamic> getReportByYearMonth(String date) async {
    Map<String, String> queryParams = {
      'date': date
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}report/get-by-guardian')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getThingsToBringTmrList() async {
    Map<String, String> queryParams = {
      'name': 'kindercastleid_report_thingstobringtmr_list'
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}config')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getMealsList() async {
    Map<String, String> queryParams = {
      'name': 'kindercastleid_report_meals_list'
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}config')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getNapList() async {
    Map<String, String> queryParams = {
      'name': 'kindercastleid_report_nap_list'
    };

    final response = await http.get(
        Uri.parse('${_baseUrl}config')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }
}