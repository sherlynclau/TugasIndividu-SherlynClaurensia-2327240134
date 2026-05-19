import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/firebase_service.dart';
import '../main.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? existingCourse;
  const AddCourseScreen({super.key, this.existingCourse});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  
  late TextEditingController _nameController;
  late TextEditingController _lecturerController;
  late TextEditingController _sksController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingCourse?.name ?? '');
    _lecturerController = TextEditingController(text: widget.existingCourse?.lecturer ?? '');
    _sksController = TextEditingController(text: widget.existingCourse?.sks ?? ''); // Langsung ambil string
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      if (widget.existingCourse == null) {
        _firebaseService.addCourse(_nameController.text.trim(), _lecturerController.text.trim(), _sksController.text.trim());
      } else {
        _firebaseService.updateCourse(widget.existingCourse!.id, _nameController.text.trim(), _lecturerController.text.trim(), _sksController.text.trim());
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final outlineColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
    final titleColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCourse == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: titleColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama Mata Kuliah', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor))),
                    validator: (val) => val!.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lecturerController,
                    decoration: InputDecoration(labelText: 'Nama Dosen', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor))),
                    validator: (val) => val!.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _sksController,
                    // Tidak lagi dibatasi tipe keyboardnya
                    decoration: InputDecoration(
                      labelText: 'Jumlah SKS', 
                      hintText: 'Contoh: 3 atau 2/1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor))
                    ),
                    validator: (val) => val!.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _saveCourse,
                    child: Text(widget.existingCourse == null ? 'Simpan Mata Kuliah' : 'Update Mata Kuliah', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}