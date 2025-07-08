import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/message_model.dart';

class LocalDBService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _database = await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chat_messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE messages (
    messageId TEXT PRIMARY KEY,
    senderId TEXT,
    receiverId TEXT,
    message TEXT,
    timestamp TEXT
  )
''');
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatMessage>> getMessagesBetween(
      String user1, String user2) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [user1, user2, user2, user1],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  Future<bool> messageExists(String messageId) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
    return result.isNotEmpty;
  }
}
