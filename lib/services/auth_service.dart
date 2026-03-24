import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_med_flow_user_app/models/login_model.dart';
import 'package:flutter_med_flow_user_app/models/response_model.dart';
import 'package:flutter_med_flow_user_app/models/user_model.dart';
import 'package:flutter_med_flow_user_app/provider/common_provider.dart';
import 'package:flutter_med_flow_user_app/services/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class AuthService {
  static Future<ResponseModel<LoginModel>> login({
    required String username,
    required String password,
  }) async {
    log("login");

    final httpString = MedConfig.https(
      service: PortConfig.authPort,
      path: 'login',
    );

    log("http = $httpString");

    final uri = Uri.parse(httpString);
    final httpGetResponse = post(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"username": username, "password": password}),
    );

    final response = await httpGetResponse;

    log("response = ${response.body}");
    log("response.statusCode = ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      return ResponseModel(
        data: LoginModel(data: responseJS['data']),
        responseEnum: ResponseEnum.success,
      );
    } else {
      return ResponseModel(
        data: LoginModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel<UserModel>> me(BuildContext context) async {
    log("me");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.authPort,
      path: 'me',
    );

    log("http = $httpString");

    final uri = Uri.parse(httpString);
    final httpGetResponse = get(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${login.accessToken}',
      },
    );

    final response = await httpGetResponse;

    log("response = ${response.body}");
    log("response.statusCode = ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      return ResponseModel(
        data: UserModel(data: responseJS['data']['user']),
        responseEnum: ResponseEnum.success,
      );
    } else {
      return ResponseModel(
        data: UserModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }
}
