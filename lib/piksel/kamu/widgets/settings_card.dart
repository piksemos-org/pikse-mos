import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const SettingsCard({required this.title, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...items.map((item) => _buildListTile(context, item)),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Map<String, dynamic> item) {
    return ListTile(
      leading: Icon(item['icon']),
      title: Text(item['title']),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 0,
      onTap: () {},
    );
  }
}
