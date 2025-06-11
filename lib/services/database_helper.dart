import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/allenamento.dart';

//si occupa della gestione del database
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal(); //crea l'istanza (final così non si può cambiare)
  static Database? _database; //l'oggetto che contiene il db

  factory DatabaseHelper() => _instance; //invece di costruire una nuova istanza ogni volta, da quella già creata

  DatabaseHelper._internal();

  Future<Database> get database async { //ottengo l'istanza del database
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async { //che viene poi inizializzato
    final path = join(await getDatabasesPath(), 'allenamenti.db'); //costruisce il percorso dei file
    return await openDatabase(
      path,
      version: 1, //specifica la versione del database. Mai usato perché è andato tutto bene alla prima botta. Grazie Redbull
      onCreate: (db, version) { //viene chiamato solo la prima volta che il database viene creato
        return db.execute('''
          CREATE TABLE allenamenti (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            tipo TEXT,
            data TEXT,
            durata INTEGER,
            calorie INTEGER,
            note TEXT
          )
        ''');
      },
    );
  }

  Future<List<Allenamento>> getAllenamenti() async { //prende tutti gli allenamenti dal database
    final db = await database;
    final result = await db.query('allenamenti', orderBy: 'data DESC');
    return result.map((map) => Allenamento.fromMap(map)).toList();
  }

  Future<int> insertAllenamento(Allenamento allenamento) async { //inserisce un nuovo allenamento nel database
    final db = await database;
    return await db.insert('allenamenti', allenamento.toMap());
  }

  Future<int> updateAllenamento(Allenamento allenamento) async { //aggiorna un allenamento nel database
    final db = await database;
    return await db.update('allenamenti', allenamento.toMap(), where: 'id = ?', whereArgs: [allenamento.id]); //specificano quale allenamento deve essere aggiornato in base all'id
  }

  Future<int> deleteAllenamento(int id) async { //elimina un allenamento dal database
    final db = await database;
    return await db.delete('allenamenti', where: 'id = ?', whereArgs: [id]); //idem sopra
  }
}