class Song {
  final int? id;
  final String title;
  final String artist;
  final String? albumArt;
  final String? audioPath;
  final int year;

  Song({
    this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    this.audioPath,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album_art': albumArt,
      'audio_path': audioPath,
      'year': year,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      albumArt: map['album_art'],
      audioPath: map['audio_path'],
      year: map['year'],
    );
  }
}