import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/providers/navigation_provider.dart';
import 'package:ecommerce_app/screens/admin/admin_dashboard.dart';
import 'package:ecommerce_app/screens/admin/global_products_screen.dart';
import 'package:ecommerce_app/screens/admin/system_reports_screen.dart';
import 'package:ecommerce_app/screens/admin/user_management_screen.dart';
import 'package:ecommerce_app/screens/member/cart_screen.dart';
import 'package:ecommerce_app/screens/member/home_screen.dart';
import 'package:ecommerce_app/screens/member/products_screen.dart';
import 'package:ecommerce_app/screens/member/profile_screen.dart';
import 'package:ecommerce_app/screens/merchant/add_product_screen.dart';
import 'package:ecommerce_app/screens/merchant/merchant_dashboard.dart';
import 'package:ecommerce_app/screens/merchant/merchant_orders_screen.dart';
import 'package:ecommerce_app/screens/merchant/merchant_products_screen.dart';
import 'package:ecommerce_app/widgets/common/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? 'member';

    final List<Widget> memberScreens  = [
      HomeScreen(),
      ProductsScreen(),
      CartScreen(),
      ProfileScreen(),
    ];

    final List<Widget> merchantScreens = [
      MerchantDashboard(),
      AddProductScreen(),
      MerchantOrdersScreen(),
      MerchantProductsScreen(),
      ProfileScreen(),
    ];

    final List<Widget> adminScreens = [
      AdminDashboard(),
      UserManagementScreen(),
      GlobalProductsScreen(),
      ProfileScreen(),
    ];

    List<Widget> getScreens() {
      switch (userRole) {
        case 'merchant':
          return merchantScreens;
        case 'admin':
          return adminScreens;
        default:
          return memberScreens ;
      }
    }

    final screens = getScreens();

    final safeIndex = navProvider.currentIndex < screens.length
        ? navProvider.currentIndex
        : 0;

    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: safeIndex,
        onTap: (index) {
          if (index >= 0 && index < screens.length) {
            navProvider.changeIndex(index);
          }
        },
        userRole: userRole,
      ),
    );
  }
}