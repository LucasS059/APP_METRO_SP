import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Add this line
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaRegistrarExtintor extends StatefulWidget {
  const TelaRegistrarExtintor({super.key});

  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  final _patrimonioController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _dataFabricacaoController = TextEditingController();
  final _dataValidadeController = TextEditingController();
  final _ultimaRecargaController = TextEditingController();
  final _proximaInspecaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _localizacaoSelecionada;
  String? _statusSelecionado;
  String? _qrCodeUrl;
  String? _capacidadeSelecionada;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> localizacoesFiltradas = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> capacidades = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {});
    await Future.wait(
        [fetchTipos(), fetchLinhas(), fetchStatus(), fetchCapacidades()]);
    setState(() {});
  }

  Future<void> fetchCapacidades() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3001/capacidades'));
    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            capacidades = List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
          print('Capacidades carregadas: $capacidades'); // Verifique a resposta
        } else {
          _showErrorDialog('Capacidades não encontradas.');
        }
      } catch (e) {
        _showErrorDialog('Erro ao decodificar a resposta: $e');
      }
    } else {
      _showErrorDialog('Erro ao carregar capacidades: ${response.statusCode}');
    }
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    String? value,
    required Function(String?) onChanged,
    String Function(Map<String, dynamic>)? displayItem,
  }) {
    return DropdownButtonFormField(
      isExpanded: true,
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item['id'].toString(),
                child: Text(
                  displayItem != null
                      ? displayItem(item)
                      : (item['descricao'] ?? 'Descrição não disponível'),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF4F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Future<void> fetchTipos() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedTipos = prefs.getString('tipos');

    if (cachedTipos != null) {
      setState(() {
        tipos =
            List<Map<String, dynamic>>.from(json.decode(cachedTipos)['data']);
      });
      print('Tipos carregados do cache: $tipos');
    } else {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3001/tipos-extintores'));

      if (response.statusCode == 200) {
        print(
            'Tipos retornados da API: ${response.body}'); // Verifique a resposta
        prefs.setString('tipos', response.body);
        setState(() {
          tipos = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data']);
        });
      } else {
        print('Erro ao carregar tipos: ${response.statusCode}');
      }
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLocalizacoes(String linhaId) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3001/localizacoes?linhaId=$linhaId'));
    if (response.statusCode == 200) {
      setState(() {
        localizacoesFiltradas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/status'));
    if (response.statusCode == 200) {
      setState(() {
        status =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _registrarExtintor() async {
    if (_patrimonioController.text.isEmpty ||
        _tipoSelecionado == null ||
        _tipoSelecionado!.isEmpty ||
        _capacidadeSelecionada == null ||
        _capacidadeSelecionada!.isEmpty ||
        _linhaSelecionada == null ||
        _linhaSelecionada!.isEmpty ||
        _localizacaoSelecionada == null ||
        _localizacaoSelecionada!.isEmpty ||
        _statusSelecionado == null ||
        _statusSelecionado!.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    final extintorData = {
      "patrimonio": _patrimonioController.text,
      "tipo_id": _tipoSelecionado,
      "capacidade_id": _capacidadeSelecionada, // Envia diretamente o valor
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "linha_id": _linhaSelecionada,
      "id_localizacao": _localizacaoSelecionada,
      "status": _statusSelecionado,
      "observacoes": _observacoesController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          _qrCodeUrl = responseData['qrCodeUrl'];
        });
        _showSuccessDialog('Extintor registrado com sucesso!');
      } else {
        _showErrorDialog('Erro ao registrar extintor: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isDate = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isDate,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF4F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onTap: isDate ? () => _selectDate(controller) : null,
    );
  }

  Future<void> _printQRCode() async {
    if (_qrCodeUrl == null) return;

    try {
      final response = await http.get(Uri.parse(_qrCodeUrl!));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final pdf = pw.Document();

        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(imageBytes)),
            );
          },
        ));

        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
          return pdf.save();
        });
      } else {
        _showErrorDialog('Falha ao carregar o QR Code.');
      }
    } catch (e) {
      _showErrorDialog('Erro ao tentar baixar a imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF011689),
        title: const Text('Registrar Extintor'),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildTextField(
                      controller: _patrimonioController,
                      label: 'Patrimônio',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Tipo',
                      items: tipos,
                      value: _capacidadeSelecionada?.isNotEmpty ?? false
                          ? _capacidadeSelecionada
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value;
                        });
                      },
                      displayItem: (item) =>
                          item['nome'] ??
                          'Descrição não disponível', // Aqui foi ajustado para 'nome'
                    ),
                    _buildDropdown(
  label: 'Capacidade',
  items: capacidades.map((item) {
    return DropdownMenuItem(
      value: item['id'].toString(), // Converte os IDs para String
      child: Text(
        item['descricao'] ?? 'Descrição não disponível',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList(),
  value: capacidades.any((item) => item['id'].toString() == _capacidadeSelecionada)
      ? _capacidadeSelecionada
      : null, // Garante que o valor seja válido
  onChanged: (value) {
    setState(() {
      _capacidadeSelecionada = value;
    });
  },
  displayItem: (item) => item['descricao'] ?? 'Descrição não disponível',
),

                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _codigoFabricanteController,
                      label: 'Código do Fabricante',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataFabricacaoController,
                      label: 'Data de Fabricação',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataValidadeController,
                      label: 'Data de Validade',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _ultimaRecargaController,
                      label: 'Última Recarga',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _proximaInspecaoController,
                      label: 'Próxima Inspeção',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Linha',
                      items: linhas,
                      value: _linhaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _linhaSelecionada = value;
                          _localizacaoSelecionada = null;
                          fetchLocalizacoes(value!);
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Localização',
                      items: localizacoesFiltradas,
                      value: _localizacaoSelecionada,
                      onChanged: (value) {
                        setState(() {
                          if (!localizacoesFiltradas
                              .any((item) => item['id'].toString() == value)) {
                            _localizacaoSelecionada = null;
                          } else {
                            _localizacaoSelecionada = value;
                          }
                        });
                      },
                      displayItem: (item) =>
                          '${item['subarea']} - ${item['local_detalhado']}',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Status',
                      items: status,
                      value: _statusSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _statusSelecionado = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _observacoesController,
                      label: 'Observações',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registrarExtintor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011689),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_qrCodeUrl != null)
                      Column(
                        children: [
                          Image.network(_qrCodeUrl!),
                          ElevatedButton(
                            onPressed: _printQRCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF011689),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Imprimir QR Code'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
