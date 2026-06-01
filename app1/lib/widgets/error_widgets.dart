import 'package:flutter/material.dart';

/// Custom Error Banner Widget untuk menampilkan error di UI
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final bool isDismissible;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData icon;

  const ErrorBanner({
    Key? key,
    required this.message,
    this.onClose,
    this.isDismissible = true,
    this.backgroundColor,
    this.textColor,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300] ?? Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? Colors.red[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (isDismissible && onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 18, color: Colors.red[600]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom Field Error Widget
class FieldErrorText extends StatelessWidget {
  final String? errorText;

  const FieldErrorText({Key? key, this.errorText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.red[600]),
          const SizedBox(width: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Success Banner Widget
class SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final bool isDismissible;

  const SuccessBanner({
    Key? key,
    required this.message,
    this.onClose,
    this.isDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300] ?? Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isDismissible && onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 18, color: Colors.green[600]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Warning Banner Widget
class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final bool isDismissible;

  const WarningBanner({
    Key? key,
    required this.message,
    this.onClose,
    this.isDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300] ?? Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_outlined, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber[800],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isDismissible && onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 18, color: Colors.amber[700]),
            ),
          ],
        ],
      ),
    );
  }
}
