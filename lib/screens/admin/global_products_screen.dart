import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/product_card.dart';

class GlobalProductsScreen extends StatefulWidget {
  const GlobalProductsScreen({super.key});

  @override
  _GlobalProductsScreenState createState() => _GlobalProductsScreenState();
}

class _GlobalProductsScreenState extends State<GlobalProductsScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllProducts();
    });
  }

  List<dynamic> _getFilteredProducts(List<dynamic> products) {
    if (_selectedCategory == 'All') {
      return products;
    }
    return products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  void _deleteProduct(String productId, String productName, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "$productName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              adminProvider.deleteProduct(productId);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final filteredProducts = _getFilteredProducts(adminProvider.allProducts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Products'),
        backgroundColor: const Color(0xFF232F3E),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Electronics', 'Electronics'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Fashion', 'Fashion'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Home', 'Home'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sports', 'Sports'),
                ],
              ),
            ),
          ),

          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await adminProvider.loadAllProducts();
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
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Stack(
                          children: [
                            ProductCard(
                              product: product,
                              onTap: () {
                                // TODO: Navigate to product detail
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete Product',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteProduct(
                                        product.id,
                                        product.name,
                                        context,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedCategory == value,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: const Color(0xFFFF9900),
      labelStyle: TextStyle(
        color: _selectedCategory == value ? Colors.white : Colors.black,
      ),
    );
  }
}