import 'dart:convert';
import 'dart:developer';

import 'package:flutter_med_flow_user_app/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static Future<String> getUsername() async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final values = prefs.getString("USERNAME") ?? "";
    return values;
  }

  static Future<void> setUsername(String user) async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final set = await prefs.setString("USERNAME", user);
    log("PRE-REGISTER $set");
  }

  static Future<String> getPassword() async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final values = prefs.getString("PASSWORD") ?? "";
    return values;
  }

  static Future<void> setPassword(String user) async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final set = await prefs.setString("PASSWORD", user);
    log("PRE-REGISTER $set");
  }

  static Future<LoginModel> getLoginModel() async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final values = prefs.getString("LOGIN") ?? "{}";
    final js = jsonDecode(values);
    return LoginModel(data: js);
  }

  static Future<void> setLoginModel(LoginModel loginModel) async {
    Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final SharedPreferences prefs = await prefs0;
    final user = jsonEncode(loginModel.data);
    final set = await prefs.setString("LOGIN", user);
    log("PRE-REGISTER $set");
  }
}
