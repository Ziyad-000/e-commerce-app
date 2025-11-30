import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../products/views/widgets/product_card.dart';
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
    _searchController.addListener(() {
      setState(() {});
    });
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
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<SearchProvider>().clearSearchResults();
                  }
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<SearchProvider>().searchProducts(value);
                  }
                },
                style: const TextStyle(color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: AppColors.mutedForeground),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: AppColors.destructive,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.circleXmark,
                            color: AppColors.mutedForeground,
                            size: 20,
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

                  if (searchProvider.lastQuery.isNotEmpty &&
                      searchProvider.searchResults.isEmpty &&
                      !searchProvider.isSearching) {
                    return _buildNoResults();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${searchProvider.searchResults.length} results found',
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              return ProductCard(product: searchProvider.searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 80,
            color: AppColors.mutedForeground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching with different keywords',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(SearchProvider searchProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
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
                      'Clear All',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
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
                      deleteIcon: const FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 14,
                      ),
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
            _buildSuggestionItem('T-Shirt', FontAwesomeIcons.shirt),
            _buildSuggestionItem('Shoes', FontAwesomeIcons.shoePrints),
            _buildSuggestionItem('Jacket', FontAwesomeIcons.vest),
            _buildSuggestionItem('Dress', FontAwesomeIcons.personDress),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FaIcon(icon, color: AppColors.foreground, size: 20),
      title: Text(title, style: const TextStyle(color: AppColors.foreground)),
      trailing: const FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: AppColors.mutedForeground,
      ),
      onTap: () {
        _searchController.text = title;
        context.read<SearchProvider>().searchProducts(title);
      },
    );
  }
}
