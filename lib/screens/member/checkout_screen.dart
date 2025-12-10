import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _addressController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = 'John Customer';

    _addressController.text = '123 Main Street, New York, NY 10001';
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final productIds = cartProvider.cart?.productIds ?? [];
    final quantities = cartProvider.cart?.quantities ?? [];

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user?.id ?? '',
      productIds: productIds,
      quantities: quantities,
      totalPrice: cartProvider.totalPrice,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final orderProducts = cartProvider.cartProducts;

    await Future.delayed(const Duration(seconds: 2));

    orderProvider.addOrder(newOrder, orderProducts);

    cartProvider.clearCart();

    setState(() {
      _isProcessing = false;
    });

    _showOrderConfirmation(context, newOrder);
  }

  void _showOrderConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thank you for your order!'),
            const SizedBox(height: 8),
            Text('Order ID: #${order.id}'),
            const SizedBox(height: 8),
            Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Shipping to: ${_addressController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF232F3E),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Processing your order...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),



                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Shipping Address',
                        border: OutlineInputBorder(),
                        hintText:
                            'Enter full shipping address including street, city, state and ZIP code',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter shipping address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Column(
                      children: [
                        RadioListTile(
                          title: const Text('Cash on Delivery'),
                          value: 'cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text('Credit Card'),
                          value: 'credit',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildSummaryRow(
                              'Items (${cartProvider.itemCount})',
                              '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                            ),

                            const SizedBox(height: 8),

                            _buildSummaryRow('Shipping', '\$0.00'),

                            const SizedBox(height: 8),

                            _buildSummaryRow(
                              'Tax',
                              '\$${(cartProvider.totalPrice * 0.1).toStringAsFixed(2)}',
                            ),

                            const Divider(height: 24),

                            _buildSummaryRow(
                              'Total',
                              '\$${(cartProvider.totalPrice * 1.1).toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFFF9900) : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();

    _addressController.dispose();
    super.dispose();
  }
}