import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_med_flow_user_app/models/physical_exam_model.dart';
import 'package:flutter_med_flow_user_app/models/request_models/physical_exam_request_model.dart';
import 'package:flutter_med_flow_user_app/models/response_model.dart';
import 'package:flutter_med_flow_user_app/models/vital_sign_model.dart';
import 'package:flutter_med_flow_user_app/provider/common_provider.dart';
import 'package:flutter_med_flow_user_app/services/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class ClinicalService {
  static Future<ResponseModel<List<VitalSignModel>>> getAllVitalSign(
    BuildContext context, {
    required String patientId,
  }) async {
    log("vitalSigns");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.clinicPort,
      path: 'vital-signs?patient_id=$patientId&limit=30',
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
      ).map((e) => VitalSignModel(data: e)).toList();
      return ResponseModel(data: list, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: [], responseEnum: ResponseEnum.fail);
    }
  }

  static Future<ResponseModel<PhysicalExamModel>> getPhysicalExam(
    BuildContext context, {
    required String visitId,
  }) async {
    log("getPhysicalExam");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.clinicPort,
      path: 'physical-exams/visit/$visitId',
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
        data: PhysicalExamModel(data: responseJS['data']),
        responseEnum: ResponseEnum.success,
      );
    } else {
      return ResponseModel(
        data: PhysicalExamModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }
  }

  static Future<ResponseModel> savePhysicalExam(
    BuildContext context, {
    required String physicalExamId,
    required PhysicalExamRequestModel body,
  }) async {
    log("savePhysicalExam");

    final container = ProviderScope.containerOf(context, listen: false);
    final login = container.read(loginProvider);

    final httpString = MedConfig.https(
      service: PortConfig.clinicPort,
      path: 'physical-exams/$physicalExamId',
    );

    log("http = $httpString");
    log("body = ${jsonEncode(body)}");

    final uri = Uri.parse(httpString);
    final response = await put(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${login.accessToken}',
      },
      body: jsonEncode(body),
    );

    log("response = ${response.body}");
    log("response.statusCode = ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.success);
    } else {
      return ResponseModel(data: {}, responseEnum: ResponseEnum.fail);
    }
  }
}
