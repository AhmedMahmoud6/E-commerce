import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF232F3E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF232F3E),
                      backgroundImage: user?.profileUrl != null
                          ? NetworkImage(user!.profileUrl!)
                          : null,
                      child: user?.profileUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.username ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'guest@example.com',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(
                          user?.role ?? 'member',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRoleColor(user?.role ?? 'member'),
                        ),
                      ),
                      child: Text(
                        _getRoleText(user?.role ?? 'member'),
                        style: TextStyle(
                          color: _getRoleColor(user?.role ?? 'member'),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    if (user?.address != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        user!.address!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 8),
                    Text(
                      'customer since: ${_formatDate(user?.createdAt ?? DateTime.now())}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Account Settings'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to edit profile
                },
              ),
              if (user?.role == 'member')
                _buildSettingsItem(
                  icon: Icons.favorite_border,
                  title: 'Wishlist',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistScreen(),
                      ),
                    );
                  },
                ),
              _buildSettingsItem(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              _buildSettingsItem(
                icon: Icons.location_on_outlined,
                title: 'Address',
                trailing: Text(user?.address ?? 'Not set'),
                onTap: () {
                  // TODO: Navigate to address management
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Orders'),

            _buildSettingsCard([
              if (user?.role == 'member')
                _buildSettingsItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    );
                  },
                ),
              _buildSettingsItem(
                icon: Icons.receipt_long_outlined,
                title: 'Order History',
                onTap: () {
                  // TODO: Navigate to order history
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('Support'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  // TODO: Navigate to help center
                },
              ),
              _buildSettingsItem(
                icon: Icons.support_agent_outlined,
                title: 'Customer Support',
                onTap: () {
                  // TODO: Navigate to customer support
                },
              ),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: () {
                  // TODO: Navigate to about us
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader('App Settings'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.language,
                title: 'Language',
                trailing: const Text('English'),
                onTap: () {
                  // TODO: Change language
                },
              ),
              _buildSettingsItem(
                icon: Icons.security,
                title: 'Privacy & Security',
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(child: Column(children: children));
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF232F3E)),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'member':
        return 'Member';
      case 'merchant':
        return 'Merchant';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'member':
        return Colors.blue;
      case 'merchant':
        return Colors.green;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
