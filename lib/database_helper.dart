import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contatos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contatos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT,
        telefone TEXT
      )
    ''');
  }

  Future<int> adicionarContato(Map<String, dynamic> contato) async {
    final db = await instance.database;
    return await db.insert('contatos', contato);
  }

  Future<int> atualizarContato(Map<String, dynamic> contato) async {
    final db = await instance.database;
    return await db.update(
      'contatos',
      contato,
      where: 'id = ?',
      whereArgs: [contato['id']],
    );
  }

  Future<int> deletarContato(int id) async {
    final db = await instance.database;
    return await db.delete(
      'contatos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getContatos() async {
    final db = await instance.database;
    return await db.query('contatos');
  }

  Future<Map<String, dynamic>> getContato(int id) async {
    final db = await instance.database;
    var res = await db.query('contatos', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : {};
  }
}
