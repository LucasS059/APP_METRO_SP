import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/TelaScanQR.dart';
import 'telas/Tela_Login.dart';
import 'telas/tela_info_extintor.dart';


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
      // Aqui configuramos a rota dinâmica para passar 'patrimonio' como argumento
      onGenerateRoute: (settings) {
        if (settings.name == '/info-extintor') {
          final patrimonio = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TelaInfoExtintor(patrimonio: patrimonio),
          );
        }
        return null;
      },
    );
  }
}
