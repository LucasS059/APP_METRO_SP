import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

    final response = await http.get(Uri.parse('http://10.0.2.2:3001/extintor/$patrimonio'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['extintor'];
      if (data != null) {
        setState(() {
          _codigoFabricanteController.text = data['Codigo_Fabricante'] ?? '';
          _dataFabricacaoController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Data_Fabricacao']));
          _dataValidadeController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Data_Validade']));
          _ultimaRecargaController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Ultima_Recarga']));
          _proximaInspecaoController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['Proxima_Inspecao']));
          _tipoSelecionado = data['Tipo']; // Atribua o ID correto
          _linhaSelecionada = data['Linha_Nome']; // Atribua o ID correto
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

  Future<void> _atualizarExtintor() async {
    final patrimonio = _patrimonioController.text;
    if (patrimonio.isEmpty) {
      _showErrorDialog('Por favor, insira o patrimônio do extintor.');
      return;
    }

    if (_codigoFabricanteController.text.isEmpty || _dataFabricacaoController.text.isEmpty ||
        _dataValidadeController.text.isEmpty || _ultimaRecargaController.text.isEmpty ||
        _proximaInspecaoController.text.isEmpty || _tipoSelecionado == null ||
        _linhaSelecionada == null || _statusSelecionado == null) {
      _showErrorDialog('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    final extintorData = {
      "patrimonio": patrimonio,
      "tipo_id": _tipoSelecionado,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dataFabricacaoController.text)),
      "data_validade": DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dataValidadeController.text)),
      "ultima_recarga": DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_ultimaRecargaController.text)),
      "proxima_inspecao": DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_proximaInspecaoController.text)),
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
              TextField(
                controller: _patrimonioController,
                decoration: InputDecoration(labelText: 'Patrimônio'),
              ),
              ElevatedButton(
                onPressed: _buscarExtintor,
                child: const Text('Buscar Extintor'),
              ),
              const SizedBox(height : 20),
              TextField(
                controller: _codigoFabricanteController,
                decoration: InputDecoration(labelText: 'Código do Fabricante'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dataFabricacaoController,
                decoration: InputDecoration(labelText: 'Data de Fabricação'),
                readOnly: true,
                onTap: () => _selectDate(_dataFabricacaoController),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dataValidadeController,
                decoration: InputDecoration(labelText: 'Data de Validade'),
                readOnly: true,
                onTap: () => _selectDate(_dataValidadeController),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ultimaRecargaController,
                decoration: InputDecoration(labelText: 'Última Recarga'),
                readOnly: true,
                onTap: () => _selectDate(_ultimaRecargaController),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _proximaInspecaoController,
                decoration: InputDecoration(labelText: 'Próxima Inspeção'),
                readOnly: true,
                onTap: () => _selectDate(_proximaInspecaoController),
              ),
              const SizedBox(height: 12),
              // Dropdowns para Tipo, Linha e Status
              // Adicione os widgets de dropdown aqui
              const SizedBox(height: 12),
              TextField(
                controller: _estacaoController,
                decoration: InputDecoration(labelText: 'Estação'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descricaoLocalController,
                decoration: InputDecoration(labelText: 'Descrição do Local'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _observacaoLocalController,
                decoration: InputDecoration(labelText: 'Observação sobre o local'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _observacoesController,
                decoration: InputDecoration(labelText: 'Observações do Extintor'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _atualizarExtintor,
                child: const Text('Atualizar Extintor'),
              ),
            ],
          ),
        ),
      ),
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

class _gerarQRCode {
  _gerarQRCode(String patrimonio);
}