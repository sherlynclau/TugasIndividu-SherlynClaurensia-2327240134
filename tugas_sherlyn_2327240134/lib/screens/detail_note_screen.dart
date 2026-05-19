import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../models/course_model.dart';
import '../services/firebase_service.dart';
import 'add_note_screen.dart';
import '../main.dart';

class DetailNoteScreen extends StatelessWidget {
  final Note note;
  const DetailNoteScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(note.timestamp);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy • HH:mm').format(date);
    final isDark = themeNotifier.value == ThemeMode.dark;
    final FirebaseService firebaseService = FirebaseService();

    final bgColor       = isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF5F5F7);
    final cardColor     = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0A0A0F);
    final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B6B80);
    const accent        = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: bgColor,
      // --- APPBAR DISAMAKAN DENGAN HOMESCREEN ---
      appBar: AppBar(
        title: Text(
          'Detail Catatan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? Colors.white : Colors.black,
              size: 22,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AddNoteScreen(existingNote: note)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: firebaseService.getCourses(),
        builder: (context, snapshot) {
          String lecturerName = '---';
          if (snapshot.hasData) {
            try {
              lecturerName =
                  snapshot.data!.firstWhere((c) => c.id == note.courseId).lecturer;
            } catch (_) {
              lecturerName = 'Dosen tidak diketahui';
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge mata kuliah
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Text(note.courseName.toUpperCase(),
                      style: const TextStyle(color: accent, fontWeight: FontWeight.w800,
                          fontSize: 10.5, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 16),

                // Judul
                Text(note.title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                        height: 1.2, letterSpacing: -0.5, color: textPrimary)),
                const SizedBox(height: 20),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isDark
                        ? []
                        : [BoxShadow(color: Colors.black.withOpacity(0.05),
                            blurRadius: 12, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.person_outline_rounded, label: 'Dosen',
                          value: lecturerName, textSecondary: textSecondary,
                          textPrimary: textPrimary),
                      Divider(height: 20,
                          color: isDark ? Colors.white12 : Colors.black12),
                      _InfoRow(icon: Icons.access_time_rounded, label: 'Waktu',
                          value: formattedDate, textSecondary: textSecondary,
                          textPrimary: textPrimary),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Isi catatan
                SelectableText(note.content,
                    style: TextStyle(fontSize: 16, height: 1.8,
                        color: isDark ? const Color(0xFFD1D1D6) : const Color(0xFF1C1C1E),
                        letterSpacing: 0.1)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;

  const _InfoRow({required this.icon, required this.label, required this.value,
      required this.textSecondary, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 10),
        Text('$label  ', style: TextStyle(fontSize: 13, color: textSecondary)),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}