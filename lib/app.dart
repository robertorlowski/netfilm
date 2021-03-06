import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netfilm/i18/app_localizations.dart';
import 'package:netfilm/model/app_model.dart';
import 'package:netfilm/widgets/main/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:ui' as ui;

class FilmApp extends StatelessWidget {
  // This widget is the root of your application.
  FilmApp();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) => MaterialApp(
        locale: Locale(ui.window.locale.languageCode),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('pl', 'PL'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        title: 'netFilm',
        theme: model.theme,
        home: MainPage(),
      ),
    );
  }
}
