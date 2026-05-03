import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class CredentialDisplayDialog extends StatelessWidget {
  final String username;
  final String password;
  final String role;

  const CredentialDisplayDialog({
    super.key,
    required this.username,
    required this.password,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registration Successful!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please save your unique credentials for future logins:'),
          const SizedBox(height: 20),
          _buildCredentialRow(context, 'Username', username),
          const SizedBox(height: 12),
          _buildCredentialRow(context, 'Password', password),
          const SizedBox(height: 24),
          const Text(
            'Important: You will need these to login every time the app opens.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/role-selection', (route) => false);
          },
          child: const Text('Go to Login'),
        ),
      ],
    );
  }

  Widget _buildCredentialRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
}
