import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/providers/family_group_provider.dart';
import 'dart:io';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with TickerProviderStateMixin {
  String _inputPin = '';
  bool _isError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Shake controller initialization
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _authenticateBiometric() async {
    final authenticated = await ref.read(securityProvider.notifier).authenticate();
    if (authenticated && mounted) {
      context.go('/dashboard');
    }
  }

  void _onNumberPressed(String number) {
    if (_inputPin.length < 4) {
      setState(() {
        _inputPin += number;
        _isError = false;
      });

      if (_inputPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(securityProvider.notifier).verifyPin(_inputPin);
    if (success) {
      ref.read(securityProvider.notifier).recordSuccessAuth();
      if (mounted) context.go('/dashboard');
    } else {
      setState(() {
        _isError = true;
        _inputPin = '';
      });
      _shakeController.forward(from: 0);
      HapticFeedback.vibrate();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final security = ref.watch(securityProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Profile / Logo Section
            _buildProfileHeader(profile),
            const SizedBox(height: 32),
            
            // PIN Dots
            _buildPinDots(),
            const SizedBox(height: 16),
            
            if (_isError)
              const Text(
                'PIN Salah. Coba lagi.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              
            const Spacer(flex: 1),
            
            // Numeric Keypad
            _buildKeypad(security.isBiometricEnabled),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child: profile.photoUrl != null
                ? (profile.photoUrl!.startsWith('http') 
                    ? Image.network(profile.photoUrl!, fit: BoxFit.cover)
                    : Image.file(File(profile.photoUrl!), fit: BoxFit.cover))
                : Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Selamat Datang Kembali,',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          profile.name.isNotEmpty ? profile.name : 'Pengguna TabunganKu',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = Curves.elasticIn.transform(_shakeController.value) * 10;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final active = index < _inputPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildKeypad(bool showBiometric) {
    return Column(
      children: [
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var val in row) _buildKeypadButton(val),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Biometric or empty
              if (showBiometric)
                _buildKeypadIconButton(Icons.fingerprint_rounded, _authenticateBiometric)
              else
                const SizedBox(width: 70),
                
              _buildKeypadButton('0'),
              _buildKeypadIconButton(Icons.backspace_outlined, _onBackspace),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String value) {
    return InkWell(
      onTap: () => _onNumberPressed(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}
