import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class TelaInfoExtintor extends StatelessWidget {
  final String patrimonio;

  TelaInfoExtintor({required this.patrimonio});

  Future<Map<String, dynamic>> fetchExtintorInfo() async {
    final response = await http.get(
      Uri.parse('http://localhost:3001/extintor/$patrimonio'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar dados do extintor.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações do Extintor'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchExtintorInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhuma informação disponível'));
          } else {
            final extintor = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patrimônio: ${extintor['patrimonio']}'),
                  Text('Tipo: ${extintor['tipo']}'),
                  Text('Capacidade: ${extintor['capacidade']}'),
                  Text(
                      'Código do Fabricante: ${extintor['codigo_fabricante']}'),
                  // Inclua outros campos conforme necessário
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
