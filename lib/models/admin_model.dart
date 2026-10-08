/// Admin Model representing an administrator user
class AdminModel {
  final int? id;
  final String username;
  final String password;

  const AdminModel({
    this.id,
    required this.username,
    required this.password,
  });

  /// Factory constructor to create an AdminModel from a SQLite Map
  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  /// Converts the AdminModel to a SQLite Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a copy of AdminModel with specified updated fields
  AdminModel copyWith({
    int? id,
    String? username,
    String? password,
  }) {
    return AdminModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'AdminModel(id: $id, username: $username)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ password.hashCode;
}
