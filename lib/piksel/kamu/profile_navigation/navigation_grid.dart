import 'package:flutter/material.dart';

class NavigationGrid extends StatelessWidget {
  const NavigationGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navigationItems = [
      {'icon': Icons.send, 'label': 'Sending', 'onTap': () {}},
      {'icon': Icons.payment, 'label': 'Payment', 'onTap': () {}},
      {'icon': Icons.history, 'label': 'History', 'onTap': () {}},
      {
        'icon': Icons.folder_outlined,
        'label': 'Storage',
        'onTap': () => Navigator.pushNamed(context, '/storage'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: navigationItems.length,
        itemBuilder: (context, index) {
          final item = navigationItems[index];
          return _NavigationItem(
            icon: item['icon'],
            label: item['label'],
            onTap: item['onTap'],
          );
        },
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label == 'Payment Waiting' ? 'Payment' : label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
