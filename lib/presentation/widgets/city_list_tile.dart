import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/city_entity.dart';
import 'glass_card.dart';

class CityListTile extends StatelessWidget {
  final CityEntity city;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const CityListTile({
    super.key,
    required this.city,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey('city-${city.id}'),
      direction: DismissDirection.up,
      background: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: GlassCard(
            dark: isDark,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            borderRadius: 24,
            blur: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_city_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        city.country,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    city.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: city.isFavorite ? const Color(0xFFFF6B81) : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
