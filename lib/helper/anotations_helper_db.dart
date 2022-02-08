import 'package:db_sqflite_notas_diarias/models/anotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AnotacoesHelperDb {
  //Sempre que tenta criar uma instância dessa classe, chama o factory primeiro.
  //Da primeira vez que é chamado, como não há uma instância criada, acaba chamando o
  //"AnotacoesHelperDb._internal() {}" para criar a instância. Nas próximas vezes que
  //chamar a classe, o AnotacoesHelperDb._internal() {} não será chamado porque já há
  //uma instância criada. Então o factory chamará direto o "_anotacoesHelperDb"

  //o ideal é sempre que for mexer com o sqflite, usar o modo singleton de criação
  //de classes porque a instância só precisa ser criada uma vez. Não há necessidade
  //de criar mais de uma instância do banco de dados. O método singleton é esse
  //que possui um construtor de modo static e é retornado no factory.

  static final AnotacoesHelperDb _anotacoesHelperDb =
      AnotacoesHelperDb._internal();

  Database? _db;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await createDatabase();
    }
    return _db;
  }

  createDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String databaseLocal = join(databasePath, 'anotatios.db');

    Database db = await openDatabase(
      databaseLocal,
      version: 1,
      onCreate: _createTable,
      //aqui é onde realmente cria o banco de dados
    );

    return db;
  }

  _createTable(Database db, int version) async {
    await db.execute(
      'CREATE TABLE anotations (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR, description TEXT, date DATETIME)',
      //O tipo VARCHAR possui um limite de caracteres menor do que o TEXT.
      //Mesmo a coluna sendo do time datetime, pode passar como String que ele
      //salva corretamente como data
    );
  }

  Future<int> saveAnotation(Anotation anotation) async {
    Database database = await db;

    int resultId = await database.insert('anotations', anotation.toMap());

    return resultId;
    //retorna o ID do dado adicionado no banco de dados
  }

  getAnotations() async {
    Database database = await db;

    String sql = 'Select * from anotations order by date DESC';
    List<Map<String, Object?>> anotations = await database.rawQuery(
      sql,
    );

    return anotations;
  }

  updateAnotation(Anotation anotation) async {
    Database database = await db;
    int count = await database.update(
      'anotations',
      anotation.toMap(),
      where: 'title = ?, description = ?',
      whereArgs: [anotation.title, anotation.description],
    );
  }

  //Construtor interno. Ele é chamado somente na primeira vez que a classe é chamada
  AnotacoesHelperDb._internal() {}

//CONSTRUTOR PADRÃO
  factory AnotacoesHelperDb() {
    return _anotacoesHelperDb;
  }
}
