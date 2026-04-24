import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/app_version.dart';
import 'app/theme.dart';
import 'pages/login_page.dart';
import 'services/configuration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await AppVersion.init();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    _localization.init(
      mapLocales: [
        MapLocale(
          'en',
          AppLocale.en,
          countryCode: 'US',
          fontFamily: GoogleFonts.anuphan().fontFamily,
        ),
        MapLocale(
          'th',
          AppLocale.th,
          countryCode: 'TH',
          fontFamily: GoogleFonts.anuphan().fontFamily,
        ),
      ],
      initLanguageCode: 'en',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale("th", "TH"),
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      localizationsDelegates: _localization.localizationsDelegates,
      home: const LoginPage(),
    );
  }
}

mixin AppLocale {
  static const String title = 'title';
  static const String thisIs = 'thisIs';

  static const Map<String, dynamic> en = {
    title: 'Localization',
    thisIs: 'This is %a package, version %a.',
  };
  static const Map<String, dynamic> th = {
    title: 'ภาษาไทย',
    thisIs: 'นี่คือภาษาไทย',
  };
}
