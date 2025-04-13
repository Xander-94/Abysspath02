import 'package:uuid/uuid.dart';

/// 用户模型类
class UserModel {
  final String id;          // UUID
  final String email;       // 邮箱
  final String? username;   // 用户名
  final String? avatar;     // 头像URL
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final Map<String, dynamic>? metadata; // 额外元数据

  UserModel({
    String? id,
    required this.email,
    this.username,
    this.avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 创建更新后的用户模型
  UserModel copyWith({
    String? email,
    String? username,
    String? avatar,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)';
  }
} 