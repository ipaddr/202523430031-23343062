import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';

/// Home Screen - Halaman utama setelah login
class HomeScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeScreen({super.key, this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                user?.email ?? 'User',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple[100],
              child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
            ),
            const SizedBox(height: 24),

            // Welcome Text
            Text(
              'Selamat Datang,',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user?.displayName ?? user?.email ?? 'User',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Info Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoTile(
                      label: 'Email',
                      value: user?.email ?? 'Tidak tersedia',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Nama',
                      value: user?.displayName ?? 'Belum diatur',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Status',
                      value: 'Terdaftar',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _authService.logout();
                            if (mounted) {
                              widget.onLogout?.call();
                            }
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Info Tile Widget
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
