import 'package:flutter/material.dart';

class TelaReportarErro extends StatefulWidget {
  const TelaReportarErro({super.key});

  @override
  _TelaReportarErroState createState() => _TelaReportarErroState();
}

class _TelaReportarErroState extends State<TelaReportarErro> {
  final TextEditingController _controller = TextEditingController();

  void _enviarErro() {
    final erro = _controller.text.trim();
    if (erro.isNotEmpty) {
      // Aqui você pode enviar a mensagem para um servidor ou outro sistema de feedback
      // Exemplo de exibição de uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro reportado: $erro')),
      );
      _controller.clear(); // Limpa o campo de texto após o envio
    } else {
      // Caso o campo esteja vazio, avisa o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, descreva o erro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Erro', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)), // Cor da seta (ícone de voltar)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente o conteúdo
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente o conteúdo
          children: [
            // Título dentro de um retângulo
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9), // Cor de fundo do retângulo
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Caso tenha identificado algum erro, favor reportar abaixo',
                  style: TextStyle(
                    fontSize: 18, // Tamanho do texto
                  ),
                  textAlign: TextAlign.center, // Centraliza o texto no contêiner
                ),
              ),
            ),
            const SizedBox(height: 16), // Espaço entre o título e o campo de texto
            // Caixa de texto dentro de um retângulo cinza claro
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9), // Cor de fundo do retângulo
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Descreva o erro...',
                    border: InputBorder.none, // Removendo borda padrão
                  ),
                  maxLines: 5, // Permite múltiplas linhas de texto
                  keyboardType: TextInputType.multiline, // Tipo de teclado para múltiplas linhas
                ),
              ),
            ),
            const SizedBox(height: 16), // Espaço entre o campo de texto e o botão
            // Botão centralizado
            Center(
              child: ElevatedButton(
                onPressed: _enviarErro,
                child: const Text(
                  'Enviar Erro',
                  style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 20), // Cor do texto do botão
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF011689), // Cor de fundo do botão
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40), // Aumentando o tamanho do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Logo opaca centralizada
            const Spacer(), // Espaço para empurrar a logo para o fundo
            Opacity(
              opacity: 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5, // 50% da largura
                height: MediaQuery.of(context).size.height * 0.1, // 10% da altura
                child: FittedBox(
                  fit: BoxFit.contain, // Ajusta a imagem sem distorção
                  child: Image.asset(
                    'assets/images/logo.jpeg', // Caminho da imagem
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}