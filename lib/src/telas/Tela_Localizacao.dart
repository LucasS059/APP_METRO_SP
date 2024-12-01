import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaConsultaLocalizacaoExtintor extends StatefulWidget {
  const TelaConsultaLocalizacaoExtintor({Key? key}) : super(key: key);

  @override
  _TelaConsultaLocalizacaoExtintorState createState() =>
      _TelaConsultaLocalizacaoExtintorState();
}

class _TelaConsultaLocalizacaoExtintorState
    extends State<TelaConsultaLocalizacaoExtintor> {
  final TextEditingController _patrimonioController = TextEditingController();
  String _patrimonio = "";
  bool _isLoading = false;
  Map<String, dynamic>? _localizacaoData;
  String _errorMessage = "";

  Future<void> _buscarLocalizacao() async {
    if (_patrimonio.isEmpty) {
      _showSnackBar("Por favor, insira o número do patrimônio.");
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final url = Uri.parse(
        'http://localhost:3001/extintor/localizacao/$_patrimonio'); // Substitua localhost pelo IP da sua máquina

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _localizacaoData = data['localizacao'];
            _showSnackBar("Localização encontrada!", color: Colors.green);
          });
        } else {
          setState(() {
            _errorMessage = "Extintor não encontrado.";
            _showSnackBar(_errorMessage);
          });
        }
      } else {
        setState(() {
          _errorMessage = "Erro ao buscar localização.";
          _showSnackBar(_errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro na conexão. Verifique sua internet.";
        _showSnackBar(_errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Localização do Extintor'),
        backgroundColor: const Color(0xFF011689),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _patrimonioController,
              decoration: InputDecoration(
                labelText: 'Número do Patrimônio',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _patrimonio = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarLocalizacao,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Buscar Localização'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (_localizacaoData != null) _buildLocalizacaoDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizacaoDetails() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Localização do Extintor',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Área: ${_localizacaoData!['Area']}'),
            Text('Subárea: ${_localizacaoData!['Subarea'] ?? 'N/A'}'),
            Text('Detalhes: ${_localizacaoData!['Local_Detalhado']}'),
            Text('Observações: ${_localizacaoData!['Observacoes'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
