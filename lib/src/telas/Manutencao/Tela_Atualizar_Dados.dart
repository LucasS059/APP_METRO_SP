import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TelaAtualizarExtintor extends StatefulWidget {
  @override
  _TelaAtualizarExtintorState createState() => _TelaAtualizarExtintorState();
}

class _TelaAtualizarExtintorState extends State<TelaAtualizarExtintor> {
  final _patrimonioController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _dataFabricacaoController = TextEditingController();
  final _dataValidadeController = TextEditingController();
  final _ultimaRecargaController = TextEditingController();
  final _proximaInspecaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _descricaoLocalController = TextEditingController();
  final _observacaoLocalController = TextEditingController();
  final _estacaoController = TextEditingController();

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _statusSelecionado;
  String? _qrCodeUrl;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> status = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([fetchTipos(), fetchLinhas(), fetchStatus()]);
  }

  Future<void> fetchTipos() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/tipos-extintores'));
    if (response.statusCode == 200) {
      setState(() {
        tipos = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/status'));
    if (response.statusCode == 200) {
      setState(() {
        status = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> _buscarExtintor() async {
  final patrimonio = _patrimonioController.text;
  if (patrimonio.isEmpty) {
    _showErrorDialog('Por favor, insira o patrimônio do extintor.');
    return;
  }
  print('Buscando extintor com patrimônio: $patrimonio');

  final response = await http.get(Uri.parse('http://10.0.2.2:3001/extintor/$patrimonio'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body)['extintor']; // Acesse a chave correta
    if (data != null) {
      setState(() {
        _codigoFabricanteController.text = data['Codigo_Fabricante'] ?? '';
        _dataFabricacaoController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Data_Fabricacao']));
        _dataValidadeController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Data_Validade']));
        _ultimaRecargaController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Ultima_Recarga']));
        _proximaInspecaoController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Proxima_Inspecao']));
        
        // Atribuindo os IDs corretos para os dropdowns
        _tipoSelecionado = data['Tipo']; // Aqui você pode precisar do ID correspondente
        _linhaSelecionada = data['Linha_Nome']; // Aqui você pode precisar do ID correspondente
        _statusSelecionado = data['Status'];

        _descricaoLocalController.text = data['Localizacao_Subarea'] ?? '';
        _observacaoLocalController.text = data['Observacoes_Local'] ?? '';
        _observacoesController.text = data['Observacoes_Extintor'] ?? '';
        _estacaoController.text = data['Localizacao_Area'] ?? '';
        _qrCodeUrl = data['QR_Code'] ?? '';
      });
    } else {
      _showErrorDialog('Extintor não encontrado.');
    }
  } else {
    _showErrorDialog('Erro ao buscar extintor: ${response.statusCode}');
  }
}

Widget _buildDropdown({
  required String label,
  required List<Map<String, dynamic>> items,
  String? value,
  required Function(String?) onChanged,
  required String Function(Map<String, dynamic>) displayItem,
}) {
  return DropdownButtonFormField<String>(
    isExpanded: true,
    value: value,
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'].toString(), // Certifique-se de que o valor é o ID
        child: Text(displayItem(item)),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFE3F2FD), // Azul claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF011689)), // Azul da AppBar
      ),
    ),
  );
}

  Future<void> _atualizarExtintor() async {
    final patrimonio = _patrimonioController.text;
    if (patrimonio.isEmpty) {
      _showErrorDialog('Por favor, insira o patrimônio do extintor.');
      return;
    }

    final extintorData = {
      "patrimonio": patrimonio,
      "tipo_id": _tipoSelecionado,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "linha_id": _linhaSelecionada,
      "estacao": _estacaoController.text,
      "descricao_local": _descricaoLocalController.text,
      "observacoes_local": _observacaoLocalController.text,
      "observacoes": _observacoesController.text,
      "status": _statusSelecionado,
    };

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3001/atualizar_extintor/$patrimonio'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 200) {
        await _gerarQRCode(patrimonio);
        _showSuccessDialog('Extintor atualizado com sucesso!');
      } else {
        _showErrorDialog('Erro ao atualizar extintor: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  Future<void> _gerarQRCode(String patrimonio) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3001/gerar_qrcode'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"patrimonio": patrimonio}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _qrCodeUrl = data['qrCodeUrl'] ?? '';
      });
    } else {
      _showErrorDialog('Erro ao gerar QR Code: ${response.body}');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Extintor'),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildOptionCard(
                title: "Buscar Extintor",
                description: "Insira o patrimônio do extintor para buscar suas informações.",
                child: _buildTextField(controller: _patrimonioController, label: 'Patrimônio'),
                onPressed: _buscarExtintor,
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                title: "Atualizar Dados do Extintor",
                description: "Atualize as informações do extintor após a busca.",
                child: Column(
                  children: [
                    _buildTextField(controller: _codigoFabricanteController, label: 'Código do Fabricante'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _dataFabricacaoController, label: 'Data de Fabricação', isDate: true),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _dataValidadeController, label: 'Data de Validade', isDate: true),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _ultimaRecargaController, label: 'Última Recarga', isDate: true),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _proximaInspecaoController, label: 'Próxima Inspeção', isDate: true),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Tipo',
                      items: tipos,
                      value: _tipoSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Linha',
                      items: linhas,
                      value: _linhaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _linhaSelecionada = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _estacaoController, label: 'Estação'),
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
                    _buildTextField(controller: _descricaoLocalController, label: 'Descrição do Local'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _observacaoLocalController, label: 'Observação sobre o local'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _observacoesController, label: 'Observações do Extintor'),
                  ],
                ),
                onPressed: _atualizarExtintor,
              ),
              const SizedBox(height: 20),
              if (_qrCodeUrl != null) ...[
                Image.network(
                  _qrCodeUrl!,
                  errorBuilder: (context, error, stackTrace) {
                    print("Erro ao carregar imagem: $error");
                    return const Text("Erro ao carregar QR Code.");
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _printQRCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011689),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Imprimir QR Code', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF011689),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF011689),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
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
        filled: true,
        fillColor: const Color(0xFFE3F2FD), // Azul claro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF011689)), // Azul da AppBar
        ),
      ),
      onTap: isDate ? () => _selectDate(controller) : null,
    );
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
}