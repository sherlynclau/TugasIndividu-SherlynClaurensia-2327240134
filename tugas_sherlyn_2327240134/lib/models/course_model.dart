class Course {
  final String id;
  final String name;
  final String lecturer;
  final String sks; // Diubah menjadi String agar bisa menerima "2/1"

  Course({required this.id, required this.name, required this.lecturer, required this.sks});

  factory Course.fromMap(Map<dynamic, dynamic> map, String id) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      lecturer: map['lecturer'] ?? '',
      sks: map['sks']?.toString() ?? '0', // Dikonversi ke string secara aman
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'lecturer': lecturer, 'sks': sks};
  }
}