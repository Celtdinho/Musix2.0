import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

class GameDatabase {
  static final GameDatabase _instance = GameDatabase._internal();
  static Database? _database;

  GameDatabase._internal();

  factory GameDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_quiz.db');
    return await openDatabase(
      path,
      version: 3, // <-- Naikkan ke 3
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertSampleSongs(db);
    await db.insert('stage_progress', {'stage_id': 1, 'is_unlocked': 1});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE songs ADD COLUMN audio_path TEXT');
    }
    if (oldVersion < 3) {
      // Perbaiki path: hapus 'assets/' di awal, karena seharusnya hanya 'audio/...'
      await db.execute(
          "UPDATE songs SET audio_path = REPLACE(audio_path, 'assets/', '') WHERE audio_path LIKE 'assets/%'"
      );
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE songs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album_art TEXT,
        audio_path TEXT,
        year INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE stage_progress(
        stage_id INTEGER PRIMARY KEY,
        is_unlocked INTEGER DEFAULT 0,
        high_score INTEGER DEFAULT 0,
        best_time INTEGER DEFAULT 0,
        completed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE high_scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        score INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _insertSampleSongs(Database db) async {
    final List<Song> songs = [
      Song(title: 'Always', artist: 'Daniel Caesar', year: 2017, audioPath: 'audio/Always.mp3'),
      Song(title: 'Apple Cider', artist: 'Beabadoobee', year: 2020, audioPath: 'audio/Apple_Cider.mp3'),
      Song(title: 'Bad', artist: 'Wave to Earth', year: 2023, audioPath: 'audio/Bad.mp3'),
      Song(title: 'Birch Tree', artist: 'Strawberry Guy', year: 2019, audioPath: 'audio/Birch_Tree.mp3'),
      Song(title: 'Blue Hair', artist: 'TV Girl', year: 2023, audioPath: 'audio/Blue_Hair.mp3'),
      Song(title: 'Chamber Of Reflection', artist: 'Mac DeMarco', year: 2014, audioPath: 'audio/Chamber_Of_Reflection.mp3'),
      Song(title: 'Cigarette Daydreams', artist: 'Cage The Elephant', year: 2015, audioPath: 'audio/Cigarette_Daydreams.mp3'),
      Song(title: 'Cigarettes Out The Window', artist: 'TV Girl', year: 2014, audioPath: 'audio/Cigarettes_Out_Of_The_Window.mp3'),
      Song(title: 'Eventually', artist: 'Tame Impala', year: 2015, audioPath: 'audio/Eventually.mp3'),  // ganti file lagu
      Song(title: 'F Song', artist: 'Strawberry Guy', year: 2019, audioPath: 'audio/F_Song.mp3'),
      Song(title: 'Falling Behind', artist: 'Laufey', year: 2022, audioPath: 'audio/Falling_Behind.mp3'),
      Song(title: 'For The First Time', artist: 'Mac DeMarco', year: 2017, audioPath: 'audio/For_The_First_Time.mp3'),
      Song(title: 'Freaking Out The Neighborhood', artist: 'Mac DeMarco', year: 2017, audioPath: 'audio/Freaking_Out_The_Neighborhood.mp3'),
      Song(title: 'From The Start', artist: 'Laufey', year: 2023, audioPath: 'audio/From_The_Start.mp3'),
      Song(title: 'Glue Song', artist: 'Beabadoobee', year: 2020, audioPath: 'audio/Glue_Song.mp3'),
      Song(title: 'Harvey', artist: "Her's", year: 2018, audioPath: 'audio/Harvey.mp3'),
      Song(title: 'Heart To Heart', artist: 'Mac DeMarco', year: 2019, audioPath: 'audio/Heart_To_Heart.mp3'),
      Song(title: 'Heavy', artist: 'The Marías', year: 2021, audioPath: 'audio/Heavy.mp3'),
      Song(title: 'Hurts Me Too', artist: 'Faye Webster', year: 2021, audioPath: 'audio/Hurts_Me_Too.mp3'),
      Song(title: 'I Know You', artist: 'Faye Webster', year: 2021, audioPath: 'audio/I_Know_You.mp3'),
      Song(title: 'I Must Apologise', artist: 'PinkPantheress', year: 2021, audioPath: 'audio/I_Must_Apologise.mp3'),
      Song(title: 'In A Good Way', artist: 'Faye Webster', year: 2019, audioPath: 'audio/In_A_Good_Way.mp3'),
      Song(title: 'Infrunami', artist: 'Steve Lacy', year: 2020, audioPath: 'audio/Infrunami.mp3'),
      Song(title: 'Jealous', artist: 'Eyedress', year: 2021, audioPath: 'audio/Jealous.mp3'),
      Song(title: 'Kingston', artist: 'Faye Webster', year: 2019, audioPath: 'audio/Kingston.mp3'),
      Song(title: 'Let It Happen', artist: 'Tame Impala', year: 2015, audioPath: 'audio/Let_It_Happen.mp3'),
      Song(title: 'Linger', artist: 'The Cranberries', year: 1993, audioPath: 'audio/Linger.mp3'),
      Song(title: 'Looking Out For You', artist: 'Joy Again', year: 2020, audioPath: 'audio/Looking_Out_For_You.mp3'),
      Song(title: 'Love', artist: 'Wave to Earth', year: 2023, audioPath: 'audio/Love.mp3'),
      Song(title: 'Lovers Rock', artist: 'TV Girl', year: 2014, audioPath: 'audio/Lovers_Rock.mp3'),
      Song(title: 'Mrs Magic', artist: 'Strawberry Guy', year: 2019, audioPath: 'audio/Mrs_Magic.mp3'),
      Song(title: 'New Person Same Old Mistake', artist: 'Tame Impala', year: 2015, audioPath: 'audio/New_Person_Same_Old_Mistake.mp3'),
      Song(title: 'No One Noticed', artist: 'The Marías', year: 2021, audioPath: 'audio/No_One_Noticed.mp3'),
      Song(title: 'No Other Heart', artist: 'Mac DeMarco', year: 2019, audioPath: 'audio/No_Other_Heart.mp3'),
      Song(title: 'Notion', artist: 'The Rare Occasions', year: 2016, audioPath: 'audio/Notion.mp3'),
      Song(title: 'Promise', artist: 'Laufey', year: 2023, audioPath: 'audio/Promise.mp3'),
      Song(title: 'Romantic Lover', artist: 'Eyedress', year: 2021, audioPath: 'audio/Romantic_Lover.mp3'),
      Song(title: 'Roommates', artist: 'Malcolm Todd', year: 2023, audioPath: 'audio/Roommates.mp3'), // ganti file lagu
      Song(title: 'Sailor Song', artist: 'Gigi Perez', year: 2021, audioPath: 'audio/Sailor_Song.mp3'),
      Song(title: 'Seasons', artist: 'Wave to Earth', year: 2023, audioPath: 'audio/seasons.mp3'),
      Song(title: 'Sienna', artist: 'The Marías', year: 2021, audioPath: 'audio/Sienna.mp3'),
      Song(title: 'Something About You', artist: 'Eyedress', year: 2022, audioPath: 'audio/Something_About_You.mp3'),  // ganti file lagu
      Song(title: 'Stress Relief', artist: 'Late Night Drive Home', year: 2022, audioPath: 'audio/Stress_Relief.mp3'),
      Song(title: 'Superpowers', artist: 'Daniel Caesar', year: 2019, audioPath: 'audio/Superpowers.mp3'),
      Song(title: 'Sweet Boy', artist: 'Malcolm Todd', year: 2023, audioPath: 'audio/Sweet_boy.mp3'),
      Song(title: 'Telephones', artist: 'Vacations ', year: 2020, audioPath: 'audio/Telephones.mp3'),
      Song(title: 'The Less I Know The Better', artist: 'Tame Impala', year: 2015, audioPath: 'audio/The_Less_I_Know_The_Better.mp3'),
      Song(title: 'The Perfect Pair', artist: 'Beabadoobee', year: 2022, audioPath: 'audio/The_Perfect_Pair.mp3'),
      Song(title: 'What Once Was', artist: "Her's", year: 2018, audioPath: 'audio/What_Once_Was.mp3'),
      Song(title: 'What Would I Do', artist: 'Strawberry Guy', year: 2019, audioPath: 'audio/What_Would_I_Do.mp3'),
      Song(title: 'Where All The Time Go', artist: 'Dr. Dog', year: 2010, audioPath: 'audio/Where_All_The_Time_Go.mp3'),
      Song(title: 'Who Knows', artist: 'Daniel Caesar', year: 2017, audioPath: 'audio/Who_Knows.mp3'),
      Song(title: 'Without You', artist: 'Strawberry Guy', year: 2019, audioPath: 'audio/Without_You.mp3'),
      Song(title: 'Young', artist: 'Vacations', year: 2018, audioPath: 'audio/Young.mp3'),
    ];

    for (var song in songs) {
      await db.insert('songs', song.toMap());
    }
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('songs');
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<Song?> getSongById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('songs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  Future<List<int>> getUnlockedStages() async {
    final db = await database;
    final result = await db.query('stage_progress', where: 'is_unlocked = 1');
    return result.map((e) => e['stage_id'] as int).toList();
  }


  Future<void> saveHighScore(String mode, int score) async {
    final db = await database;
    await db.insert('high_scores', {
      'mode': mode,
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unlockStage(int stageId) async {
    final db = await database;
    final existing = await db.query('stage_progress', where: 'stage_id = ?', whereArgs: [stageId]);
    if (existing.isEmpty) {
      await db.insert('stage_progress', {
        'stage_id': stageId,
        'is_unlocked': 1,
        'high_score': 0,
        'best_time': 0,
      });
    } else {
      await db.update('stage_progress', {'is_unlocked': 1}, where: 'stage_id = ?', whereArgs: [stageId]);
    }
  }
}