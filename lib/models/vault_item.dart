enum VaultItemType { password, note, document }

class VaultItem {
  final String id;
  final VaultItemType type;
  final String title;
  final String? username;
  final String? password;
  final String? url;
  final String? content;
  final String? filePath;
  final String? fileName;
  final String? notes;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultItem({
    required this.id,
    required this.type,
    required this.title,
    this.username,
    this.password,
    this.url,
    this.content,
    this.filePath,
    this.fileName,
    this.notes,
    this.favorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  VaultItem copyWith({
    String? id,
    VaultItemType? type,
    String? title,
    String? username,
    String? password,
    String? url,
    String? content,
    String? filePath,
    String? fileName,
    String? notes,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      notes: notes ?? this.notes,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'username': username,
        'password': password,
        'url': url,
        'content': content,
        'filePath': filePath,
        'fileName': fileName,
        'notes': notes,
        'favorite': favorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'] as String,
      type: VaultItemType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String? ?? '',
      username: json['username'] as String?,
      password: json['password'] as String?,
      url: json['url'] as String?,
      content: json['content'] as String?,
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String?,
      notes: json['notes'] as String?,
      favorite: json['favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
