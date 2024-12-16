import 'package:flutter/material.dart';
import 'cadastro_screen.dart';
import 'listagem_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: ListagemScreen(),
      routes: {
        '/cadastro': (context) => CadastroScreen(),
      },
    );
  }
}
