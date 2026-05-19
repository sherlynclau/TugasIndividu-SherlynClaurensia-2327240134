import 'package:firebase_database/firebase_database.dart';
import '../models/course_model.dart';
import '../models/note_model.dart';

class FirebaseService {
  final DatabaseReference  _db = FirebaseDatabase.instance.ref();
  
  // --- MATA KULIAH ---
  Future<void> addCourse(String name, String lecturer, String sks) async {
    await _db.child('courses').push().set({
      'name': name,
      'lecturer': lecturer,
      'sks': sks, // Sekarang menyimpan format teks
    });
  }

  Future<void> updateCourse(String id, String name, String lecturer, String sks) async {
    // 1. Update data di tabel Mata Kuliah
    await _db.child('courses').child(id).update({
      'name': name,
      'lecturer': lecturer,
      'sks': sks,
    });

    // 2. Cari semua catatan yang menggunakan Mata Kuliah ini
    final DataSnapshot snapshot = await _db.child('notes').orderByChild('courseId').equalTo(id).get();

    // 3. Jika ada catatan yang terhubung, perbarui namanya (Cascade Update)
    if (snapshot.exists) {
      final Map<dynamic, dynamic> notesMap = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> updates = {};

      // Siapkan jalur update untuk setiap catatan yang ditemukan
      notesMap.forEach((noteId, value) {
        updates['notes/$noteId/courseName'] = name;
      });

      // Lakukan update massal (Batch Update) dalam satu kali proses
      await _db.update(updates);
    }
  }

  // --- MATA KULIAH ---
  // ... fungsi addCourse dan updateCourse ...

  Future<void> deleteCourse(String id) async {
    // 1. Cari semua catatan yang menggunakan Mata Kuliah ini
    final DataSnapshot snapshot = await _db.child('notes').orderByChild('courseId').equalTo(id).get();

    // 2. Jika ada catatan yang ditemukan, siapkan perintah hapus (set ke null)
    if (snapshot.exists) {
      final Map<dynamic, dynamic> notesMap = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> updates = {};

      notesMap.forEach((noteId, _) {
        // Mengatur value ke 'null' di Firebase berarti MENGHAPUS node tersebut
        updates['notes/$noteId'] = null; 
      });

      // Eksekusi penghapusan semua catatan yang terkait secara serentak
      await _db.update(updates);
    }

    // 3. Setelah catatannya bersih, barulah hapus Mata Kuliah utamanya
    await _db.child('courses').child(id).remove();
  }

  Stream<List<Course>> getCourses() {
    return _db.child('courses').onValue.map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      return map.entries.map((e) => Course.fromMap(e.value, e.key)).toList();
    });
  }

  // --- CATATAN KULIAH ---
  Future<void> addNote(String courseId, String courseName, String title, String content) async {
    final newNoteRef = _db.child('notes').push();
    await newNoteRef.set({
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': ServerValue.timestamp, 
    });
  }
  // --- FITUR UPDATE (EDIT) CATATAN ---
  Future<void> updateNote(String id, String courseId, String courseName, String title, String content) async {
    await _db.child('notes').child(id).update({
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      // Timestamp tidak diubah agar tetap tahu kapan pertama dibuat
    });
  }

  // --- FITUR DELETE (HAPUS) CATATAN ---
  Future<void> deleteNote(String id) async {
    await _db.child('notes').child(id).remove();
  }

  Stream<List<Note>> getNotes() {
    return _db.child('notes').onValue.map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      List<Note> notes = map.entries.map((e) => Note.fromMap(e.value, e.key)).toList();
      // Bonus: Pengurutan catatan (terbaru di atas)
      notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notes;
    });
  }
}