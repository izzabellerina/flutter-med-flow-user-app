import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_med_flow_user_app/models/appointment_model.dart';
import 'package:flutter_med_flow_user_app/models/request_models/create_vital_sign_model.dart';
import 'package:flutter_med_flow_user_app/models/response_model.dart';
import 'package:flutter_med_flow_user_app/models/vital_sign.dart';
import 'package:flutter_med_flow_user_app/provider/common_provider.dart';
import 'package:flutter_med_flow_user_app/services/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class TelemedService {
  static Future<ResponseModel<List<AppointmentModel>>> appointment(
    BuildContext context, {
    required String date,
  }) async {
    log("appointment");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.telemedPort,
      path: 'sessions?page=1&limit=20&date=$date',
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
      final list = List.from(
        responseJS['data'] ?? [],
      ).map((e) => AppointmentModel(data: e)).toList();
      return ResponseModel(data: list, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: [], responseEnum: ResponseEnum.fail);
    }
  }

  static Future<ResponseModel<AppointmentModel>> findOneAppointment(
    BuildContext context, {
    required String id,
  }) async {
    log("findOneAppointment");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.telemedPort,
      path: 'sessions/$id',
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
        data: AppointmentModel(data: responseJS['data']),
        responseEnum: ResponseEnum.success,
      );
    } else {
      return ResponseModel(
        data: AppointmentModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel<List<VitalSign>>> vitalSigns(
    BuildContext context, {
    required String token,
  }) async {
    log("vitalSigns");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.httpsWithPublic(
      service: PortConfig.telemedPort,
      path: 'join/$token/vitals',
    );

    log("http = $httpString");

    final uri = Uri.parse(httpString);
    final response = await get(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${login.accessToken}',
      },
    );

    log("response = ${response.body}");
    log("response.statusCode = ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseJS = Map.from(jsonDecode(response.body));
      final list = List.from(
        responseJS['data'] ?? [],
      ).map((e) => VitalSign.fromJson(Map<String, dynamic>.from(e))).toList();
      return ResponseModel(data: list, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: [], responseEnum: ResponseEnum.fail);
    }
  }

  static Future<ResponseModel> createVitalSign(
    BuildContext context, {
    required String token,
    required CreateVitalSignModel createVitalSignModel,
  }) async {
    log("createVitalSign");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.httpsWithPublic(
      service: PortConfig.telemedPort,
      path: 'join/$token/vitals',
    );

    // final httpString = MedConfig.https(
    //   service: PortConfig.telemedPort,
    //   path: 'join/$token/vitals',
    // );

    log("http = $httpString");
    log("model = ${jsonEncode(createVitalSignModel.toJson())}");

    final uri = Uri.parse(httpString);
    final httpGetResponse = post(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${login.accessToken}',
      },
      body: jsonEncode(createVitalSignModel.toJson()),
    );

    final response = await httpGetResponse;

    log("response = ${response.body}");
    log("response.statusCode = ${response.statusCode}");

    if (response.statusCode == 200) {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.fail);
    }
  }
}
