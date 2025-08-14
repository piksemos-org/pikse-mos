import 'package:flutter/material.dart';

class NavigationGrid extends StatelessWidget {
  const NavigationGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navigationItems = [
      {'icon': Icons.send, 'label': 'Sending', 'onTap': () {}},
      {'icon': Icons.payment, 'label': 'Payment Waiting', 'onTap': () {}},
      {'icon': Icons.history, 'label': 'History', 'onTap': () {}},
      {
        'icon': Icons.folder_outlined,
        'label': 'Storage',
        'onTap': () => Navigator.pushNamed(context, '/storage'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
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
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8),
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fontSize = constraints.maxHeight * 0.15;
                      final effectiveFontSize = fontSize
                          .clamp(10, 14)
                          .toDouble();

                      return constraints.maxHeight > 60
                          ? Text(
                              label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: effectiveFontSize,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: effectiveFontSize,
                                    ),
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
