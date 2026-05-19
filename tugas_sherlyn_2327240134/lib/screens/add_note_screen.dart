import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/note_model.dart';
import '../services/firebase_service.dart';
import '../main.dart'; // Akses tema

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote; // Jika ada nilainya berarti sedang mode Edit

  const AddNoteScreen({super.key, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  
  String? _selectedCourseId;
  String? _selectedCourseName;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // Memasukkan data lama jika sedang mode EDIT
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _selectedCourseId = widget.existingNote?.courseId;
    _selectedCourseName = widget.existingNote?.courseName;
  }

  void _saveNote() {
    // FITUR VALIDASI FORM
    if (_formKey.currentState!.validate() && _selectedCourseId != null) {
      if (widget.existingNote == null) {
        // CREATE (Tambah Baru)
        _firebaseService.addNote(
          _selectedCourseId!, _selectedCourseName!,
          _titleController.text.trim(), _contentController.text.trim(),
        );
      } else {
        // UPDATE (Edit Catatan)
        _firebaseService.updateNote(
          widget.existingNote!.id, _selectedCourseId!, _selectedCourseName!,
          _titleController.text.trim(), _contentController.text.trim(),
        );
      }
      Navigator.pop(context);
    } else if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata kuliah terlebih dahulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final outlineColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
    final titleColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.existingNote == null ? 'Tambah Catatan' : 'Edit Catatan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: titleColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Kunci validasi
            child: ListView(
              children: [
                StreamBuilder<List<Course>>(
                  stream: _firebaseService.getCourses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final courses = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Mata Kuliah',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                      ),
                      value: courses.any((c) => c.id == _selectedCourseId) ? _selectedCourseId : null,
                      items: courses.map((course) {
                        return DropdownMenuItem(value: course.id, child: Text(course.name));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCourseId = val;
                          _selectedCourseName = courses.firstWhere((c) => c.id == val).name;
                        });
                      },
                      validator: (val) => val == null ? 'Wajib dipilih' : null, // Validasi dropdown
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Catatan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                  ),
                  validator: (val) => val!.trim().isEmpty ? 'Judul tidak boleh kosong' : null, // Validasi judul
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                  ),
                  validator: (val) => val!.trim().isEmpty ? 'Isi tidak boleh kosong' : null, // Validasi isi
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveNote,
                  child: Text(widget.existingNote == null ? 'Simpan' : 'Update', style: const TextStyle(fontSize: 16, color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}