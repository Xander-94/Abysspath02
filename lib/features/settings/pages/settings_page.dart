import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {
                // TODO: 实现主题切换
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            trailing: const Text('中文'),
            onTap: () {
              // TODO: 实现语言切换
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知设置'),
            onTap: () {
              // TODO: 实现通知设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () {
              // TODO: 实现关于页面
            },
          ),
        ],
      ),
    );
  }
} 