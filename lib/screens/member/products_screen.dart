import 'package:ecommerce_app/widgets/common/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/error_state.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;
  const ProductsScreen({super.key, this.initialCategory});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  bool _showSearch = false;

  List<String> get _categories {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (provider.categories.isEmpty) {
      return [
        'All',
        'Electronics',
        'Fashion',
        'Home',
        'Sports',
        'Books',
        'Beauty',
      ];
    }
    return ['All', ...provider.categories.map((c) => c.name)];
  }

  @override
void initState() {
  super.initState();
  _selectedCategory = widget.initialCategory ?? 'All';
  _loadData();
}

void _loadData() {
  Future.microtask(() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.loadProducts().then((_) {
      productProvider.filterByCategory(_selectedCategory);
    });
    if (productProvider.categories.isEmpty) {
      productProvider.loadCategories();
    }
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFilteredProducts(List<String> allProducts) {
    if (_selectedCategory == 'All') {
      return allProducts;
    }
    return allProducts;
  }

  void _handleSearch(String query) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    if (query.isEmpty) {
      productProvider.loadProducts();
    } else {
      productProvider.searchProducts(query);
    }
  }

  void _cancelSearch() {
    _searchController.clear();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? null : const Text('Products'),
        backgroundColor: const Color(0xFF232F3E),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _cancelSearch();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            CustomSearchBar(
              controller: _searchController,
              hintText: 'Search products...',
              onSearch: _handleSearch,
              onCancel: _cancelSearch,
            ),

          if (!_showSearch)
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });

                        productProvider.filterByCategory(category);
                      },
                      selectedColor: const Color(0xFFFF9900),
                      labelStyle: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (productProvider.isLoading) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ProductShimmer(),
                  );
                }

                if (productProvider.error.isNotEmpty) {
                  return ErrorState(
                    message: productProvider.error,
                    onRetry: () {
                      productProvider.loadProducts();
                    },
                  );
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('No products found'),
                        const SizedBox(height: 8),
                        const Text('Try selecting a different category'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await productProvider.loadProducts();
                    productProvider.filterByCategory(_selectedCategory);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
