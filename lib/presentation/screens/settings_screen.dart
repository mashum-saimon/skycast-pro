import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';
import '../../database/database_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _cacheSizeBytes = 0;
  bool _isLoadingCache = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    setState(() => _isLoadingCache = true);
    final size = await DatabaseHelper.instance.getDatabaseSizeInBytes();
    if (mounted) {
      setState(() {
        _cacheSizeBytes = size;
        _isLoadingCache = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('Clear Offline Cache?', style: TextStyle(color: isDark ? Colors.white : AppColors.deepBlue)),
        content: Text(
          'This will remove all cached offline weather and air quality data. Are you sure?',
          style: TextStyle(color: isDark ? Colors.white70 : AppColors.slate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : AppColors.slate)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoadingCache = true);
      await DatabaseHelper.instance.clearWeatherCache();
      await _loadCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline cache cleared successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildAppearanceSection(themeMode, isDark, theme),
                  const SizedBox(height: 24),
                  _buildOfflineStorageSection(isDark, theme),
                  const SizedBox(height: 24),
                  _buildAccountSection(authState, isDark, theme),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeMode themeMode, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Appearance', theme),
        const SizedBox(height: 12),
        GlassCard(
          dark: isDark,
          padding: const EdgeInsets.all(8),
          child: Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: Text(
                'Dark Mode',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Use dark theme across the app',
                style: theme.textTheme.bodySmall,
              ),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              activeColor: AppColors.royalBlueLight,
              secondary: Icon(Icons.dark_mode_rounded, color: theme.colorScheme.primary, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStorageSection(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Offline Storage', theme),
        const SizedBox(height: 12),
        GlassCard(
          dark: isDark,
          padding: const EdgeInsets.all(8),
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: Icon(Icons.storage_rounded, color: theme.colorScheme.primary, size: 28),
              title: Text(
                'Local Cache Size',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                _isLoadingCache ? 'Calculating...' : _formatSize(_cacheSizeBytes),
                style: theme.textTheme.bodySmall,
              ),
              trailing: OutlinedButton.icon(
                onPressed: _isLoadingCache ? null : _clearCache,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(AuthState authState, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Account', theme),
        const SizedBox(height: 12),
        GlassCard(
          dark: isDark,
          padding: const EdgeInsets.all(8),
          child: Material(
            type: MaterialType.transparency,
            child: authState.status == AuthStatus.authenticated && authState.user != null
                ? ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    title: Text(
                      authState.user!.username,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Logged in securely',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      tooltip: 'Logout',
                    ),
                  )
                : ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    title: Text(
                      'Not logged in',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Sign in to sync your preferences',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: FilledButton(
                      onPressed: () => context.push('/login'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
