import 'dart:io';

class MedConfig {
  // Production
  static String server = "https://med3.medflow.in.th";

  static String https({required String service, required String path}) {
    return "$server/api/api/v1/$service/$path";
  }

  static String httpsWithPublic({
    required String service,
    required String path,
  }) {
    return "$server/api/api/public/$service/$path";
  }
}

class PortConfig {
  static const String authPort = "auth";
  static const String telemedPort = "telemed";
  static const String clinicPort = "clinical";
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
