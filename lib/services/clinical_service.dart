import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_med_flow_user_app/models/response_model.dart';
import 'package:flutter_med_flow_user_app/models/vital_sign_model.dart';
import 'package:flutter_med_flow_user_app/provider/common_provider.dart';
import 'package:flutter_med_flow_user_app/services/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class ClinicalService {
  static Future<ResponseModel<List<VitalSignModel>>> vitalSigns(
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
}
