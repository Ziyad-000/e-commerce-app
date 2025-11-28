import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SearchProvider>().loadRecentSearches());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<SearchProvider>().clearSearchResults();
                  }
                },
                onSubmitted: (value) {
                  context.read<SearchProvider>().searchProducts(value);
                },
                style: const TextStyle(color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: AppColors.mutedForeground),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.destructive,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.mutedForeground,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchProvider>().clearSearchResults();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.destructive,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.destructive,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.destructive,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // المحتوى
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) {
                  if (searchProvider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (searchProvider.searchResults.isNotEmpty) {
                    return _buildSearchResults(searchProvider);
                  }

                  return _buildSearchSuggestions(searchProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: searchProvider.searchResults.length,
      itemBuilder: (context, index) {
        final product = searchProvider.searchResults[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetailsRoute,
              arguments: product,
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: AppColors.surface2,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.mutedForeground,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions(SearchProvider searchProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchProvider.recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      searchProvider.clearAllSearches();
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchProvider.recentSearches.map((search) {
                  return InkWell(
                    onTap: () {
                      _searchController.text = search;
                      searchProvider.searchProducts(search);
                    },
                    child: Chip(
                      label: Text(search),
                      backgroundColor: AppColors.surface2,
                      labelStyle: const TextStyle(color: AppColors.foreground),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        searchProvider.removeRecentSearch(search);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              'Suggestions',
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem('Popular items', Icons.trending_up),
            _buildSuggestionItem('New arrivals', Icons.new_releases),
            _buildSuggestionItem('Sale items', Icons.local_offer),
            _buildSuggestionItem('Trending now', Icons.whatshot),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.foreground),
      title: Text(title, style: const TextStyle(color: AppColors.foreground)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.mutedForeground,
      ),
      onTap: () {
        debugPrint('Tapped: $title');
      },
    );
  }
}
