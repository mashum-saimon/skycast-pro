
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/search_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/state_views.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectCity(String name) {
    ref.read(searchNotifierProvider.notifier).commitToHistory(name);
    ref.read(weatherNotifierProvider.notifier).loadByCity(name);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
                  ),
                  Expanded(
                    child: GlassCard(
                      dark: isDark,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      borderRadius: 20,
                      blur: 10,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: theme.textTheme.bodyLarge,
                        onChanged: (value) =>
                            ref.read(searchNotifierProvider.notifier).onQueryChanged(value),
                        decoration: InputDecoration(
                          hintText: 'Search for a city…',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  onPressed: () {
                                    _controller.clear();
                                    ref.read(searchNotifierProvider.notifier).clearResults();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: _selectCity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent(searchState, theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state, ThemeData theme, bool isDark) {
    if (state.status == SearchStatus.idle && _controller.text.isEmpty) {
      return _buildHistory(state.history, theme, isDark);
    }

    switch (state.status) {
      case SearchStatus.loading:
        return Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        );
      case SearchStatus.error:
        return ErrorStateView(
          message: state.errorMessage ?? 'Search failed.',
          onRetry: () => ref
              .read(searchNotifierProvider.notifier)
              .onQueryChanged(_controller.text),
        );
      case SearchStatus.empty:
        return const EmptyStateView(
          title: 'No cities found',
          subtitle: 'Try a different spelling or a nearby major city.',
          icon: Icons.search_off_rounded,
        );
      case SearchStatus.loaded:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final city = state.results[index];
            return _CityResultTile(
              title: city.name,
              subtitle: city.country,
              isDark: isDark,
              theme: theme,
              onTap: () => _selectCity(city.name),
            );
          },
        );
      case SearchStatus.idle:
        return _buildHistory(state.history, theme, isDark);
    }
  }

  Widget _buildHistory(List<String> history, ThemeData theme, bool isDark) {
    if (history.isEmpty) {
      return const EmptyStateView(
        title: 'Search for any city',
        subtitle: 'Your recent searches will appear here for quick access.',
        icon: Icons.travel_explore_rounded,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(searchNotifierProvider.notifier).clearHistory(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...history.map(
          (query) => _CityResultTile(
            title: query,
            subtitle: 'Recent',
            icon: Icons.history_rounded,
            isDark: isDark,
            theme: theme,
            onTap: () => _selectCity(query),
          ),
        ),
      ],
    );
  }
}

class _CityResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _CityResultTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon = Icons.location_on_rounded,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: GlassCard(
          dark: isDark,
          borderRadius: 20,
          blur: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary.withOpacity(0.8), size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}


