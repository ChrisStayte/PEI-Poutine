import 'package:flutter/material.dart';
import 'package:peipoutine/screens/main_page.dart';
import 'package:peipoutine/screens/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEI Poutine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff8FC3BD),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xff00968C),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) {
          switch (settings.name) {
            case '/':
              return MainPage();
            case '/settings':
              return SettingsPage();
          }
          throw Exception('No route found -> ${settings.name}');
        });
      },
    );
  }
}
