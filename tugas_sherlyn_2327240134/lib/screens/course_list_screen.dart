import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/firebase_service.dart';
import 'add_course_screen.dart';
import '../main.dart';

enum CourseSortOption { nameAsc, nameDesc, lecturerAsc }

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final FirebaseService firebaseService = FirebaseService();
  String searchQuery = '';
  CourseSortOption _currentSort = CourseSortOption.nameAsc;

  int _calculateTotalSks(List<Course> courses) {
    int total = 0;
    for (var course in courses) {
      final numbers = course.sks.split(RegExp(r'[^0-9]'));
      for (var num in numbers) {
        if (num.isNotEmpty) {
          total += int.parse(num);
        }
      }
    }
    return total;
  }

  void _deleteCourseConfirm(String courseId, String courseName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Apakah Anda yakin ingin menghapus "$courseName"?\n\nPERINGATAN: Semua catatan yang berhubungan dengan mata kuliah ini juga akan terhapus permanen!'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              firebaseService.deleteCourse(courseId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mata kuliah beserta catatannya berhasil dihapus!'), 
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final outlineColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scaffold(
            // APPBAR DISAMAKAN DENGAN HOME (Tengah & Bold)
            appBar: AppBar(
              title: const Text('Daftar Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                          decoration: InputDecoration(
                            hintText: 'Cari mata kuliah atau dosen...',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: outlineColor)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: outlineColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<CourseSortOption>(
                          icon: const Icon(Icons.sort_rounded),
                          tooltip: 'Urutkan',
                          onSelected: (CourseSortOption result) => setState(() => _currentSort = result),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: CourseSortOption.nameAsc, child: Text('Mata Kuliah: A - Z')),
                            PopupMenuItem(value: CourseSortOption.nameDesc, child: Text('Mata Kuliah: Z - A')),
                            PopupMenuItem(value: CourseSortOption.lecturerAsc, child: Text('Dosen: A - Z')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<Course>>(
                    stream: firebaseService.getCourses(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      List<Course> courses = snapshot.data!.where((course) {
                        return course.name.toLowerCase().contains(searchQuery) || 
                               course.lecturer.toLowerCase().contains(searchQuery);
                      }).toList();

                      if (_currentSort == CourseSortOption.nameAsc) {
                        courses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                      } else if (_currentSort == CourseSortOption.nameDesc) {
                        courses.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                      } else if (_currentSort == CourseSortOption.lecturerAsc) {
                        courses.sort((a, b) => a.lecturer.toLowerCase().compareTo(b.lecturer.toLowerCase()));
                      }

                      int totalSks = _calculateTotalSks(courses);

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Beban SKS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('$totalSks SKS', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF6C63FF))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: courses.isEmpty
                                ? const Center(child: Text('Mata kuliah tidak ditemukan.'))
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: courses.length,
                                    itemBuilder: (context, index) {
                                      final course = courses[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                          border: Border.all(color: outlineColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('Dosen: ${course.lecturer}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, 
                                                  borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: Text('${course.sks} SKS', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                              PopupMenuButton<String>(
                                                onSelected: (val) {
                                                  if (val == 'edit') {
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddCourseScreen(existingCourse: course)));
                                                  } else if (val == 'delete') {
                                                    _deleteCourseConfirm(course.id, course.name);
                                                  }
                                                },
                                                itemBuilder: (ctx) => const [
                                                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF6C63FF),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen())),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}