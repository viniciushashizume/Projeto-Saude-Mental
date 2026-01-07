// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MindGardenApp());
}

class MindGardenApp extends StatelessWidget {
  const MindGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Garden',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado da Gamificação
  int _pontos = 0;
  String _estadoPlanta =
      "assets/planta_pequena.png"; // Você precisaria adicionar imagens

  // Controladores do Formulário
  final TextEditingController _diarioController = TextEditingController();
  double _sonoNivel = 3.0;
  bool _humorOscilacao = false;
  String _feedbackBackend = "";

  // Função para enviar dados ao Python
  Future<void> enviarDados() async {
    // 10.0.2.2 é o endereço do localhost do PC dentro do emulador Android
    var url = Uri.parse('http://127.0.0.1:8000/analisar');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "texto": _diarioController.text,
          "sono_nivel": _sonoNivel.toInt(),
          "humor_oscilacao": _humorOscilacao,
        }),
      );

      if (response.statusCode == 200) {
        var dados = jsonDecode(response.body);
        setState(() {
          _pontos += (dados['pontos_gamificacao'] as int);
          _feedbackBackend = dados['resultado'];
          _diarioController.clear();
          // Lógica simples de gamificação visual
          if (_pontos > 20)
            _estadoPlanta = "Planta Cresceu! 🌻";
          else
            _estadoPlanta = "Planta Brotando 🌱";
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(dados['mensagem'])));
      }
    } catch (e) {
      print("Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao conectar com o servidor Python")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mind Garden 🌿")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Área de Gamificação ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(_estadoPlanta, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    "Pontos de Vida: $_pontos",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Registre seu dia para regar a planta!",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Monitoramento (Baseado no Dataset) ---
            const Text(
              "Como foi seu sono?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _sonoNivel,
              min: 1,
              max: 5,
              divisions: 4,
              label: _sonoNivel.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _sonoNivel = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Teve oscilação de humor repentina?"),
              value: _humorOscilacao,
              onChanged: (bool value) {
                setState(() {
                  _humorOscilacao = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // --- Diário (NLP) ---
            const Text(
              "Diário de Emoções",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _diarioController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Escreva como você se sente hoje... (tente usar palavras em inglês para testar o modelo: anxious, happy, etc)',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: enviarDados,
              icon: const Icon(Icons.water_drop),
              label: const Text("Registrar e Regar Planta"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            if (_feedbackBackend.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AlertCard(status: _feedbackBackend),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget personalizado para exibir o alerta
class AlertCard extends StatelessWidget {
  final String status;
  const AlertCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    if (status.contains("Risco")) color = Colors.red;
    if (status.contains("Atenção")) color = Colors.orange;

    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info, color: color),
            const SizedBox(width: 10),
            Text(
              "Análise ML: $status",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
