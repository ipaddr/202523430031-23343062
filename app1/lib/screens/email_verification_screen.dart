import 'package:flutter/material.dart';
import 'package:app1/services/auth_service.dart';

/// Email Verification Screen
class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  final VoidCallback? onVerificationComplete;
  final VoidCallback? onSkip;

  const EmailVerificationScreen({
    super.key,
    this.email,
    this.onVerificationComplete,
    this.onSkip,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isVerified = false;
  int _resendTimer = 0;
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = widget.email ?? _authService.currentUser?.email ?? '';
    _startVerificationCheck();
    _sendInitialVerificationEmail();
  }

  /// Send initial verification email on screen load
  Future<void> _sendInitialVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      _resetResendTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  /// Start periodic check for email verification
  void _startVerificationCheck() {
    // Check every 3 seconds
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      try {
        final isVerified = await _authService.isEmailVerified();
        if (isVerified && mounted) {
          setState(() {
            _isVerified = true;
          });

          // Show success message and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Email berhasil diverifikasi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Wait a bit and then navigate
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            widget.onVerificationComplete?.call();
          }
        } else if (mounted) {
          // Continue checking
          _startVerificationCheck();
        }
      } catch (e) {
        if (mounted) {
          _startVerificationCheck();
        }
      }
    });
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (_resendTimer > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tunggu $_resendTimer detik sebelum resend')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.resendEmailVerification();

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Email resend berhasil'),
              backgroundColor: Colors.green,
            ),
          );
          _resetResendTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Gagal resend email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Reset resend timer
  void _resetResendTimer() {
    setState(() {
      _resendTimer = 60; // 60 seconds
    });

    // Count down
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _resetResendTimer();
      }
    });
  }

  /// Manual check for verification
  Future<void> _manualCheckVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isVerified = await _authService.isEmailVerified();

      if (mounted) {
        if (isVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Email berhasil diverifikasi!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onVerificationComplete?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email belum diverifikasi. Silakan cek email Anda.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Header Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: Colors.blue[600],
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Verifikasi Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Kami telah mengirimkan link verifikasi ke email Anda. Silakan cek inbox atau folder spam.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Email Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email untuk diverifikasi:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userEmail,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Verification Steps
                Column(
                  children: [
                    _buildStep(
                      '1',
                      'Buka email Anda',
                      'Cari email dari aplikasi kami',
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      '2',
                      'Klik link verifikasi',
                      'Link akan membuka di browser Anda',
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      '3',
                      'Tunggu konfirmasi',
                      'Aplikasi akan otomatis masuk setelah verifikasi',
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Check Verification Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _manualCheckVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Cek Verifikasi',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading || _resendTimer > 0
                        ? null
                        : _resendVerificationEmail,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: _resendTimer > 0
                            ? Colors.grey[400]!
                            : Colors.blue[600]!,
                      ),
                    ),
                    child: Text(
                      _resendTimer > 0
                          ? 'Resend Email ($_resendTimer)'
                          : 'Resend Email',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _resendTimer > 0
                            ? Colors.grey[600]
                            : Colors.blue[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip Button
                TextButton(
                  onPressed: widget.onSkip != null
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Lewati Verifikasi?'),
                              content: const Text(
                                'Email belum diverifikasi. Anda mungkin akan mengalami batasan fitur.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onSkip?.call();
                                  },
                                  child: const Text(
                                    'Lewati',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Lewati untuk Sekarang',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.onSkip != null
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build step widget
  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
