import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  List<BottomNavigationBarItem> _getMemberItems() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Products',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  List<BottomNavigationBarItem> _getMerchantItems() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add Products'),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Orders'),
      BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  List<BottomNavigationBarItem> _getAdminItems() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
      BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items;

    switch (userRole) {
      case 'merchant':
        items = _getMerchantItems();
        break;
      case 'admin':
        items = _getAdminItems();
        break;
      default:
        items = _getMemberItems();
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFFFF9900),
      unselectedItemColor: Colors.grey[600],
      items: items,
    );
  }
}
