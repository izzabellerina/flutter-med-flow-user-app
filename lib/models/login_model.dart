import 'package:flutter_med_flow_user_app/models/hospital_model.dart';
import 'package:flutter_med_flow_user_app/models/user_model.dart';

class LoginModel {
  final Map data;

  LoginModel({required this.data});

  String get accessToken => data['access_token'] ?? '';

  String get refreshToken => data['refresh_token'] ?? '';

  UserModel get user => UserModel(data: data['user'] ?? {});

  HospitalModel get hospital => HospitalModel(data: data['hospital'] ?? {});
}
