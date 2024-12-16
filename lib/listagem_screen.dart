import 'package:flutter/material.dart';
import 'cadastro_screen.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart'; // Para a formatação do número

class ListagemScreen extends StatefulWidget {
  @override
  _ListagemScreenState createState() => _ListagemScreenState();
}

class _ListagemScreenState extends State<ListagemScreen> {
  List<Map<String, dynamic>> _contatos = [];
  List<Map<String, dynamic>> _contatosFiltrados = [];
  TextEditingController _controllerBusca = TextEditingController();

  @override
  void initState() {
    super.initState();
    _atualizarContatos();
  }

  // Método para buscar os contatos no banco de dados
  _atualizarContatos() async {
    var contatos = await DatabaseHelper.instance.getContatos();
    setState(() {
      _contatos = contatos;
      _contatosFiltrados = List.from(_contatos)..sort((a, b) => a['nome'].compareTo(b['nome'])); // Ordena os contatos
    });
  }

  // Método para excluir um contato
  _excluirContato(int id) async {
    await DatabaseHelper.instance.deletarContato(id);
    _atualizarContatos();
  }

  // Método para editar um contato
  _editarContato(int id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroScreen(contatoId: id),
      ),
    ).then((_) => _atualizarContatos());
  }

  // Método para filtrar os contatos com base no texto digitado
  _filtrarContatos(String query) {
    if (query.isEmpty) {
      setState(() {
        _contatosFiltrados = List.from(_contatos)..sort((a, b) => a['nome'].compareTo(b['nome'])); // Ordena após filtrar
      });
    } else {
      setState(() {
        _contatosFiltrados = _contatos
            .where((contato) =>
        contato['nome'].toLowerCase().contains(query.toLowerCase()) ||
            contato['email'].toLowerCase().contains(query.toLowerCase()) ||
            contato['telefone'].contains(query))
            .toList()
          ..sort((a, b) => a['nome'].compareTo(b['nome'])); // Ordena após a filtragem
      });
    }
  }

  // Função para formatar o número de telefone
  String _formatarTelefone(String telefone) {
    // Remove caracteres não numéricos
    String numero = telefone.replaceAll(RegExp(r'\D'), '');

    // Verifica se o número tem 11 caracteres e formata corretamente
    if (numero.length == 11) {
      return '(${numero.substring(0, 2)}) ${numero.substring(2, 7)}-${numero.substring(7)}';
    } else {
      return 'Número inválido'; // Ou qualquer outra mensagem de erro que você preferir
    }
  }

  // Método para exibir detalhes do contato em uma modal
  void _mostrarDetalhesContato(Map<String, dynamic> contato) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                contato['nome'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: ${contato['email']}'),
              SizedBox(height: 8),
              Text('Telefone: ${_formatarTelefone(contato['telefone'])}'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editarContato(contato['id']);
                    },
                    child: Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Altere para backgroundColor
                      foregroundColor: Colors.white, // Cor do título diretamente na AppBar
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _excluirContato(contato['id']);
                    },
                    child: Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Altere para backgroundColor
                      foregroundColor: Colors.white, // Cor do título diretamente na AppBar
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Contatos'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // Cor do título diretamente na AppBar
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/cadastro').then((_) => _atualizarContatos());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de busca para filtrar contatos
            TextField(
              controller: _controllerBusca,
              onChanged: _filtrarContatos,
              decoration: InputDecoration(
                labelText: 'Buscar Contato',
                hintText: 'Digite o nome, email ou telefone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            // Se não houver contatos, exibe uma mensagem
            _contatosFiltrados.isEmpty
                ? Center(
              child: Text(
                'Nenhum contato encontrado.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _contatosFiltrados.length,
                itemBuilder: (context, index) {
                  var contato = _contatosFiltrados[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Icon(Icons.person, size: 50, color: Colors.blue),
                      title: Text(
                        contato['nome'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _mostrarDetalhesContato(contato), // Exibe os detalhes ao clicar
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
