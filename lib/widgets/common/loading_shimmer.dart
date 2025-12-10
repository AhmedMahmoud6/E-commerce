import 'package:flutter/material.dart';

class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 8),

                Container(height: 12, width: 100, color: Colors.grey[300]),
                SizedBox(height: 8),

                Container(height: 14, width: 60, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Container(width: 50, height: 50, color: Colors.grey[300]),
        title: Container(height: 16, width: 150, color: Colors.grey[300]),
        subtitle: Container(
          height: 12,
          width: 100,
          color: Colors.grey[300],
          margin: EdgeInsets.only(top: 4),
        ),
      ),
    );
  }
}
