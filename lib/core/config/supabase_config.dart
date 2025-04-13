import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase配置类
class SupabaseConfig {
  static const String supabaseUrl = 'https://oqvjpdhmmxvklrmdywab.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9xdmpwZGhtbXh2a2xybWR5d2FiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1MzE2NTIsImV4cCI6MjA2MDEwNzY1Mn0.K57WnYqEQG4dnIYI_BbE3hz2Opy0XFEfic3hLV-t3Zg';

  /// Supabase客户端实例
  static final client = Supabase.instance.client;

  /// 初始化Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,  // 开发环境启用调试
    );
  }
} 