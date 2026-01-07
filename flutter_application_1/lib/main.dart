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
      debugShowCheckedModeBanner: false,
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
  int _pontos = 0;
  String _estadoPlanta = "assets/planta_pequena.png"; // Placeholder

  // Controladores
  final TextEditingController _diarioController = TextEditingController();
  final TextEditingController _userController =
      TextEditingController(); // <--- NOVO

  double _sonoNivel = 3.0;
  bool _humorOscilacao = false;
  String _feedbackBackend = "";

  Future<void> enviarDados() async {
    // Validação simples: Usuário precisa ter nome
    if (_userController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, digite seu nome de usuário!")),
      );
      return;
    }

    var url = Uri.parse('http://127.0.0.1:8000/analisar');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": _userController.text, // <--- ENVIANDO O NOME
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
            // --- Área de Identificação (NOVO) ---
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Quem é você?",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // --- Gamificação ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    _estadoPlanta,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ), // Simplifiquei para texto por enquanto
                  const SizedBox(height: 10),
                  Text(
                    "Pontos de Vida: $_pontos",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Monitoramento ---
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
              onChanged: (v) => setState(() => _sonoNivel = v),
            ),

            SwitchListTile(
              title: const Text("Oscilação de humor repentina?"),
              value: _humorOscilacao,
              onChanged: (v) => setState(() => _humorOscilacao = v),
            ),

            const SizedBox(height: 20),

            // --- Diário ---
            const Text(
              "Diário",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _diarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva seus sentimentos...',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: enviarDados,
              icon: const Icon(Icons.save),
              label: const Text("Salvar Diário"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            if (_feedbackBackend.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Resultado ML: $_feedbackBackend"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
