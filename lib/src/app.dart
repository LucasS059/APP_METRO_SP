import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/TelaScanQR.dart';
import 'telas/Tela_Login.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      initialRoute: '/',
      routes: {
        '/': (context) => TelaLogin(),
        '/scan-qr': (context) => ScannerQRCODE(),
      },
    );
  }
}
