import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/firebase_service.dart';
import 'add_note_screen.dart';
import 'detail_note_screen.dart';
import 'course_list_screen.dart';
import '../main.dart';

// Ubah nama enum agar lebih relevan dengan mata kuliah
enum SortOption { newest, oldest, courseAsc, courseDesc }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  String searchQuery = '';
  SortOption _currentSort = SortOption.newest; 

  final List<Color> _iconColors = [
    const Color(0xFF6C63FF), 
    const Color(0xFFF06292), 
    const Color(0xFF4DD0E1), 
    const Color(0xFFFF8A65), 
    const Color(0xFF81C784), 
    const Color(0xFFBA68C8), 
    const Color(0xFF4DB6AC), 
    const Color(0xFFFFD54F), 
    const Color(0xFF7986CB), 
    const Color(0xFFE57373), 
  ];

  String _getInitials(String name) {
    if (name.isEmpty) return '-';
    List<String> words = name.trim().split(RegExp(r'\s+'));
    String initials = '';
    for (int i = 0; i < words.length && i < 5; i++) {
      if (words[i].isNotEmpty) {
        initials += words[i][0].toUpperCase();
      }
    }
    return initials;
  }

  Color _getCourseColor(String name) {
    if (name.isEmpty) return _iconColors[0];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash += name.codeUnitAt(i) * (i + 1);
    }
    return _iconColors[hash % _iconColors.length];
  }
  
  // --- FUNGSI DIALOG KONFIRMASI HAPUS CATATAN ---
  void _deleteNoteConfirm(String noteId, String noteTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Apakah Anda yakin ingin menghapus catatan "$noteTitle"?\n\nTindakan ini tidak dapat dibatalkan.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              firebaseService.deleteNote(noteId); 
              Navigator.pop(ctx); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan berhasil dihapus!'), 
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI DIALOG KONFIRMASI KELUAR ---
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda yakin ingin menutup aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur keluar hanya tersedia di aplikasi mobile.'))
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- WIDGET SIDEBAR (DRAWER) ---
  Widget _buildSidebar(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: Column(
        children: [
          // --- HEADER SIDEBAR TANPA NAMA PENGGUNA ---
          DrawerHeader(
            decoration: BoxDecoration(color:  isDarkMode ? const Color(0xFF1A237E) :
             Color.fromARGB(255, 213, 233, 255)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.menu_book_rounded, size: 40, color: Color.fromARGB(255, 53, 161, 255)),
                  ),
                  SizedBox(height: 10),
                  Text('Catatan Kuliah', style: TextStyle(color: isDarkMode ? Colors.white : Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school_rounded, color: Color(0xFF6C63FF)),
            title: const Text('Kelola Mata Kuliah', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseListScreen()));
            },
          ),
          SwitchListTile(
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.orange),
            title: const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w600)),
            value: isDarkMode,
            onChanged: (bool value) => themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Keluar Aplikasi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              _showExitDialog(context);
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final outlineColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scaffold(
            // --- PINDAHKAN DRAWER KE SINI AGAR BISA DITEKAN ---
            drawer: _buildSidebar(context, isDarkMode),
            appBar: AppBar(
              title: const Text('Catatan Kuliah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
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
                            hintText: 'Cari catatan...',
                            prefixIcon: const Icon(Icons.search),
                            // Outline Biru Muda saat tidak ditekan
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFB3E5FC), width: 1.5),
                            ),
                            // Outline Biru Cerah saat aktif/ditekan
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF03A9F4), width: 2.0),
                            ),
                            ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // --- FILTER TARUH DI SEBELAH SEARCH ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: outlineColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<SortOption>(
                          icon: const Icon(Icons.sort_rounded),
                          tooltip: 'Urutkan',
                          onSelected: (SortOption result) {
                            setState(() => _currentSort = result);
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                            const PopupMenuItem<SortOption>(value: SortOption.newest, child: Text('Waktu: Terbaru')),
                            const PopupMenuItem<SortOption>(value: SortOption.oldest, child: Text('Waktu: Terlama')),
                            const PopupMenuItem<SortOption>(value: SortOption.courseAsc, child: Text('Mata Kuliah: A - Z')),
                            const PopupMenuItem<SortOption>(value: SortOption.courseDesc, child: Text('Mata Kuliah: Z - A')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                Expanded(
                  child: StreamBuilder<List<Note>>(
                    stream: firebaseService.getNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada catatan.'));

                      List<Note> notes = snapshot.data!.where((note) {
                        return note.title.toLowerCase().contains(searchQuery) || note.courseName.toLowerCase().contains(searchQuery);
                      }).toList();

                      if (_currentSort == SortOption.newest) {
                        notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                      } else if (_currentSort == SortOption.oldest) {
                        notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                      } else if (_currentSort == SortOption.courseAsc) {
                        notes.sort((a, b) => a.courseName.toLowerCase().compareTo(b.courseName.toLowerCase()));
                      } else if (_currentSort == SortOption.courseDesc) {
                        notes.sort((a, b) => b.courseName.toLowerCase().compareTo(a.courseName.toLowerCase()));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final date = DateTime.fromMillisecondsSinceEpoch(note.timestamp);
                          final formattedDate = DateFormat('dd MMM yyyy • HH:mm').format(date);

                          final initials = _getInitials(note.courseName);
                          final iconBgColor = _getCourseColor(note.courseName);

                          return InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailNoteScreen(note: note))),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border.all(
                                  color: iconBgColor.withOpacity(0.5), 
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isDarkMode ? [] : [
                                  BoxShadow(
                                    color: iconBgColor.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: iconBgColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: iconBgColor.withOpacity(0.5), width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0), 
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              initials,
                                              style: TextStyle(
                                                color: iconBgColor,
                                                fontSize: 20, 
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text(
                                            note.courseName, 
                                            style: TextStyle(color: iconBgColor, fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note.title, 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87), 
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen(existingNote: note)));
                                        } else if (value == 'delete') {
                                          _deleteNoteConfirm(note.id, note.title);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF6C63FF),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNoteScreen())),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}