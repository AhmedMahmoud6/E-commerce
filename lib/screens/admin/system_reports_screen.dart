import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class SystemReportsScreen extends StatefulWidget {
  const SystemReportsScreen({super.key});

  @override
  _SystemReportsScreenState createState() => _SystemReportsScreenState();
}

class _SystemReportsScreenState extends State<SystemReportsScreen> {
  String _selectedReport = 'overview';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllUsers();
      adminProvider.loadAllProducts();
      adminProvider.loadAllOrders();
    });
  }

  Map<String, dynamic> _getReportData() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    switch (_selectedReport) {
      case 'sales':
        return {
          'title': 'Sales Report',
          'data': {
            'Total Sales': '\$${adminProvider.totalRevenue.toStringAsFixed(2)}',
            'Total Orders': adminProvider.totalOrders.toString(),
            'Average Order Value':
                '\$${(adminProvider.totalRevenue / (adminProvider.totalOrders == 0 ? 1 : adminProvider.totalOrders)).toStringAsFixed(2)}',
            'Completed Orders': adminProvider.allOrders
                .where((order) => order.status == 'delivered')
                .length
                .toString(),
          },
        };
      case 'users':
        return {
          'title': 'Users Report',
          'data': {
            'Total Users': adminProvider.totalUsers.toString(),
            'Members': adminProvider.users
                .where((user) => user.role == 'member')
                .length
                .toString(),
            'Merchants': adminProvider.users
                .where((user) => user.role == 'merchant')
                .length
                .toString(),
            'Admins': adminProvider.users
                .where((user) => user.role == 'admin')
                .length
                .toString(),
          },
        };
      case 'products':
        return {
          'title': 'Products Report',
          'data': {
            'Total Products': adminProvider.totalProducts.toString(),
            'Electronics': adminProvider.allProducts
                .where((product) => product.category == 'Electronics')
                .length
                .toString(),
            'Fashion': adminProvider.allProducts
                .where((product) => product.category == 'Fashion')
                .length
                .toString(),
            'Home': adminProvider.allProducts
                .where((product) => product.category == 'Home')
                .length
                .toString(),
            'Sports': adminProvider.allProducts
                .where((product) => product.category == 'Sports')
                .length
                .toString(),
          },
        };
      default:
        return {
          'title': 'System Overview',
          'data': {
            'Total Users': adminProvider.totalUsers.toString(),
            'Total Products': adminProvider.totalProducts.toString(),
            'Total Orders': adminProvider.totalOrders.toString(),
            'Total Revenue':
                '\$${adminProvider.totalRevenue.toStringAsFixed(2)}',
            'System Health': 'Good',
            'Last Updated': 'Just now',
          },
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportData = _getReportData();

    return Scaffold(
      appBar: AppBar(
        title: Text('System Reports'),
        backgroundColor: Color(0xFF232F3E),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildReportTypeChip('Overview', 'overview'),
                  SizedBox(width: 8),
                  _buildReportTypeChip('Sales', 'sales'),
                  SizedBox(width: 8),
                  _buildReportTypeChip('Users', 'users'),
                  SizedBox(width: 8),
                  _buildReportTypeChip('Products', 'products'),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reportData['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildReportCards(reportData['data']),
                  SizedBox(height: 24),
                  _buildChartPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedReport == value,
      onSelected: (selected) {
        setState(() {
          _selectedReport = value;
        });
      },
      selectedColor: Color(0xFFFF9900),
      labelStyle: TextStyle(
        color: _selectedReport == value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildReportCards(Map<String, String> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: data.entries.map((entry) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9900),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 50, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'Visual Analytics',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Charts and graphs will be displayed here',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}