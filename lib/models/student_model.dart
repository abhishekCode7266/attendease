/// Student Model representing an enrolled student
class StudentModel {
  final int? id;
  final String name;
  final String rollNo;
  final String className;
  final String password;
  final String? email;
  final String? phone;
  final String? createdAt;

  const StudentModel({
    this.id,
    required this.name,
    required this.rollNo,
    required this.className,
    required this.password,
    this.email,
    this.phone,
    this.createdAt,
  });

  /// Factory constructor to create a StudentModel from a SQLite Map
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      rollNo: map['roll_no'] as String,
      className: (map['class_name'] ?? map['class']) as String,
      password: map['password'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Converts the StudentModel to a SQLite Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'roll_no': rollNo.trim().toUpperCase(),
      'class_name': className.trim(),
      'password': password,
      'email': email?.trim(),
      'phone': phone?.trim(),
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a copy of StudentModel with modified fields
  StudentModel copyWith({
    int? id,
    String? name,
    String? rollNo,
    String? className,
    String? password,
    String? email,
    String? phone,
    String? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns user's uppercase initials for avatars (e.g. "John Doe" -> "JD")
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  String toString() =>
      'StudentModel(id: $id, name: $name, rollNo: $rollNo, class: $className)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rollNo == other.rollNo;

  @override
  int get hashCode => id.hashCode ^ rollNo.hashCode;
}
