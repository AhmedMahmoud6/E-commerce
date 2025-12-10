import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/auth_provider.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  _SalesAnalyticsScreenState createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  String _selectedPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantProvider = Provider.of<MerchantProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        merchantProvider.loadMerchantOrders(authProvider.user!.id);
      }
    });
  }

  Map<String, dynamic> _getAnalyticsData() {
    final merchantProvider = Provider.of<MerchantProvider>(
      context,
      listen: false,
    );

    if (_selectedPeriod == 'monthly') {
      return {
        'totalSales': 12540.00,
        'totalOrders': 89,
        'averageOrderValue': 140.90,
        'topProducts': [
          {'name': 'Wireless Headphones', 'sales': 4520.00},
          {'name': 'Smart Watch', 'sales': 3890.00},
          {'name': 'Running Shoes', 'sales': 2150.00},
        ],
        'salesGrowth': 15.2,
      };
    } else {
      return {
        'totalSales': 89450.00,
        'totalOrders': 645,
        'averageOrderValue': 138.68,
        'topProducts': [
          {'name': 'Wireless Headphones', 'sales': 25420.00},
          {'name': 'Smart Watch', 'sales': 19850.00},
          {'name': 'Running Shoes', 'sales': 12480.00},
        ],
        'salesGrowth': 22.8,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsData = _getAnalyticsData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Analytics'),
        backgroundColor: Color(0xFF232F3E),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            items: [
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPeriod = value!;
              });
            },
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.white),
            underline: Container(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedPeriod == 'monthly'
                  ? 'Monthly Analytics'
                  : 'Yearly Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildKeyMetrics(analyticsData),
            SizedBox(height: 24),

            _buildTopProducts(analyticsData['topProducts']),
            SizedBox(height: 24),

            _buildSalesChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          title: 'Total Sales',
          value: '\$${data['totalSales'].toStringAsFixed(2)}',
          subtitle: 'All time',
          color: Colors.green,
          icon: Icons.attach_money,
        ),
        _buildMetricCard(
          title: 'Total Orders',
          value: data['totalOrders'].toString(),
          subtitle: 'Completed orders',
          color: Colors.blue,
          icon: Icons.shopping_cart,
        ),
        _buildMetricCard(
          title: 'Avg Order Value',
          value: '\$${data['averageOrderValue'].toStringAsFixed(2)}',
          subtitle: 'Per order',
          color: Colors.orange,
          icon: Icons.trending_up,
        ),
        _buildMetricCard(
          title: 'Sales Growth',
          value: '+${data['salesGrowth']}%',
          subtitle: 'vs previous period',
          color: Colors.purple,
          icon: Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(List<dynamic> topProducts) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Column(
              children: topProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getRankColor(index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(product['name']),
                  trailing: Text(
                    '\$${product['sales'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9900),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend',
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
                      'Sales Chart',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Visual representation of sales data',
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

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}