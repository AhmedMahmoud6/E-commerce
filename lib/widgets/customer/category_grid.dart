import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/product_provider.dart';
import '../../screens/member/products_screen.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  // دالة لإرجاع أيقونة بناءً على اسم الفئة
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'fashion':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'sports':
        return Icons.sports_basketball;
      case 'books':
        return Icons.menu_book;
      case 'beauty':
        return Icons.face;
      default:
        return Icons.category;
    }
  }

  // دالة لإرجاع لون بناءً على اسم الفئة (مثل ألوان الأدوار)
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return const Color(0xFF4A6FA5); // أزرق
      case 'fashion':
        return const Color(0xFFE76F51); // برتقالي/وردي
      case 'home':
        return const Color(0xFF2A9D8F); // تركواز
      case 'sports':
        return const Color(0xFFE9C46A); // أصفر ذهبي
      case 'books':
        return const Color(0xFF9B5DE5); // بنفسجي
      case 'beauty':
        return const Color(0xFFF15BB5); // وردي فاتح
      default:
        return const Color(0xFF6C757D); // رمادي
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = productProvider.categories;

    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryColor = _getCategoryColor(category.name);

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductsScreen(initialCategory: category.name),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: categoryColor, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(category.name),
                        size: 30,
                        color: categoryColor,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.productCount}',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
