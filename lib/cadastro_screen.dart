import 'package:flutter/material.dart';
import 'database_helper.dart';

class CadastroScreen extends StatefulWidget {
  final int? contatoId;

  CadastroScreen({this.contatoId});

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Carregar os dados se for edição
    if (widget.contatoId != null) {
      _carregarContato(widget.contatoId!);
    }
  }

  // Carregar dados de um contato para edição
  _carregarContato(int id) async {
    var contato = await DatabaseHelper.instance.getContato(id);
    _nomeController.text = contato['nome'];
    _emailController.text = contato['email'];
    _telefoneController.text = contato['telefone'];
  }

  // Função para salvar ou atualizar o contato
  _salvarContato() async {
    if (_formKey.currentState!.validate()) {
      String telefone = _telefoneController.text.replaceAll(RegExp(r'\D'), ''); // Remover caracteres não numéricos

      // Verifica se o número de telefone tem exatamente 11 dígitos
      if (telefone.length != 11) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O número de telefone deve ter 11 dígitos.')),
        );
        return; // Impede o salvamento ou atualização
      }

      // Salvar ou atualizar o contato no banco de dados
      if (widget.contatoId == null) {
        // Criar novo contato
        await DatabaseHelper.instance.adicionarContato({
          'nome': _nomeController.text,
          'email': _emailController.text,
          'telefone': _telefoneController.text,
        });
      } else {
        // Atualizar contato existente
        await DatabaseHelper.instance.atualizarContato({
          'id': widget.contatoId,
          'nome': _nomeController.text,
          'email': _emailController.text,
          'telefone': _telefoneController.text,
        });
      }

      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contatoId == null ? 'Novo Contato' : 'Editar Contato'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // Cor do título diretamente na AppBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número de telefone';
                  }

                  String telefone = value.replaceAll(RegExp(r'\D'), '');
                  if (telefone.length != 11) {
                    return 'O número de telefone deve ter 11 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarContato,
                child: Text(widget.contatoId == null ? 'Adicionar' : 'Atualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.contatoId == null ? Colors.deepPurple : Colors.deepPurple, // Cor de fundo
                  foregroundColor: widget.contatoId == null ? Colors.white : Colors.white, // Cor do texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
