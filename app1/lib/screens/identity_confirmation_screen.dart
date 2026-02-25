import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';

/// Identity Confirmation Screen - Memverifikasi identitas sebelum akses ke main UI
///
/// Fungsi: Memastikan user yang login adalah user yang sebenarnya dengan:
/// - Verifikasi password
/// - Verifikasi email (optional)
/// - Biometric authentication (optional)
class IdentityConfirmationScreen extends StatefulWidget {
  final VoidCallback? onConfirmed;
  final VoidCallback? onLogout;

  const IdentityConfirmationScreen({
    super.key,
    this.onConfirmed,
    this.onLogout,
  });

  @override
  State<IdentityConfirmationScreen> createState() =>
      _IdentityConfirmationScreenState();
}

class _IdentityConfirmationScreenState
    extends State<IdentityConfirmationScreen> {
  final _authService = AuthService();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  bool _showError = false;
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;

  final user = AuthService().currentUser;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Verify identity with password
  Future<void> _verifyIdentity() async {
    _clearError();

    if (_passwordController.text.isEmpty) {
      _showErrorMessage('Password tidak boleh kosong');
      return;
    }

    // Check if locked out
    if (_failedAttempts >= _maxFailedAttempts) {
      _showErrorMessage(
        'Terlalu banyak percobaan gagal. Silakan logout dan login kembali.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify identity by attempting to re-authenticate
      // This ensures the password is correct
      final result = await _authService.login(
        email: user?.email ?? '',
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Reset attempts on success
        _failedAttempts = 0;
        _passwordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Identitas terverifikasi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to main UI
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          widget.onConfirmed?.call();
        }
      } else {
        // Handle verification failure
        _failedAttempts++;
        final message = 'Password salah. Coba lagi.';
        _showErrorMessage(message);
      }
    } catch (e) {
      _failedAttempts++;
      _showErrorMessage('Verifikasi gagal. Silakan coba lagi.');
      debugPrint('Identity verification error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _showError = true;
      });

      // Auto dismiss after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _showError) {
          _clearError();
        }
      });
    }
  }

  /// Clear error message
  void _clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _showError = false;
      });
    }
  }

  /// Logout
  void _logout() {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _authService.logout();
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Identitas'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Logout'), value: 'logout'),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Security Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  size: 60,
                  color: Colors.deepPurple[700],
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verifikasi Identitas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Masukkan password untuk melanjutkan',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Error Banner
              if (_showError && _errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red[300] ?? Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearError,
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),

              // Failed attempts warning
              if (_failedAttempts > 0 && _failedAttempts < _maxFailedAttempts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber[300] ?? Colors.amber,
                      ),
                    ),
                    child: Text(
                      'Percobaan gagal: $_failedAttempts/$_maxFailedAttempts',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Akun',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.deepPurple, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user?.email ?? 'Email tidak tersedia',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user?.displayName ?? 'Nama tidak tersedia',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    child: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _failedAttempts >= _maxFailedAttempts)
                      ? null
                      : _verifyIdentity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _failedAttempts >= _maxFailedAttempts
                              ? 'Akses Terblokir'
                              : 'Verifikasi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Text(
                'Masukkan password Anda untuk memverifikasi identitas\ndan melanjutkan ke aplikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
