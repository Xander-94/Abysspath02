class Profile {
  final String? id;                                                                // 用户ID
  final String? name;                                                             // 用户名
  final String? email;                                                            // 邮箱
  final String? avatar;                                                           // 头像URL
  const Profile({this.id, this.name, this.email, this.avatar});                  // 构造函数
  Profile copyWith({String? id, name, email, avatar}) => Profile(                 // 复制方法
    id: id ?? this.id, name: name ?? this.name,
    email: email ?? this.email, avatar: avatar ?? this.avatar);
  factory Profile.fromJson(Map<String, dynamic> j) => Profile(                    // JSON解析
    id: j['id'], name: j['name'], email: j['email'], avatar: j['avatar']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name,                      // JSON序列化
    'email': email, 'avatar': avatar};
  bool get isValid => id != null && name != null && email != null;               // 字段验证
  @override
  String toString() => 'Profile(id: $id, name: $name, email: $email)';          // 调试输出
} 