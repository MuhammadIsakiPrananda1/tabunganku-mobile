import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _currentPin = "";
  bool _isOldPinStage = false;
  bool _isConfirmStage = false;
  String _firstPin = "";

  @override
  void initState() {
    super.initState();
    final security = ref.read(securityProvider);
    if (security.hasPin) {
      _isOldPinStage = true;
    }
  }

  void _onKeyPress(String value) {
    if (value == "back") {
      if (_currentPin.isNotEmpty) {
        setState(() => _currentPin = _currentPin.substring(0, _currentPin.length - 1));
      }
    } else {
      if (_currentPin.length < 4) {
        setState(() => _currentPin += value);
        if (_currentPin.length == 4) {
          _handlePinCompletion();
        }
      }
    }
  }

  Future<void> _handlePinCompletion() async {
    if (_isOldPinStage) {
      // Verify old PIN
      final isValid = await ref.read(securityProvider.notifier).verifyPin(_currentPin);
      if (isValid) {
        setState(() {
          _isOldPinStage = false;
          _currentPin = "";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN Lama Salah!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _currentPin = "");
      }
    } else if (!_isConfirmStage) {
      // Move to confirmation stage
      _firstPin = _currentPin;
      setState(() {
        _isConfirmStage = true;
        _currentPin = "";
      });
    } else {
      // Verify confirmation
      if (_currentPin == _firstPin) {
        // Success
        ref.read(securityProvider.notifier).setPin(_currentPin);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN Keamanan Berhasil Diatur! ✓'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Mismatch
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN tidak cocok, silakan coba lagi.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _currentPin = "";
          _isConfirmStage = false;
          _firstPin = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Icon(
                        _isOldPinStage 
                          ? Icons.lock_outline_rounded 
                          : (_isConfirmStage ? Icons.verified_user_rounded : Icons.vpn_key_rounded),
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isOldPinStage 
                          ? 'PIN Lama' 
                          : (_isConfirmStage ? 'Konfirmasi PIN Baru' : 'Atur PIN Baru'),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOldPinStage
                          ? 'Masukkan PIN lama kamu'
                          : (_isConfirmStage 
                            ? 'Masukkan kembali PIN baru kamu'
                            : 'Gunakan 4 digit angka rahasia'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 40),
                      
                      // PIN Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive = index < _currentPin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: isActive ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: isActive ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                )
                              ] : null,
                            ),
                          );
                        }),
                      ),
                      
                      const Spacer(),
                      const SizedBox(height: 40),
                      
                      // Numeric Keypad
                      _buildKeypad(isDarkMode),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDarkMode) {
    return Column(
      children: [
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], [null, '0', 'back']])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var key in row)
                  key == null 
                    ? const SizedBox(width: 80)
                    : _buildKeypadButton(key, isDarkMode),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKeypadButton(String key, bool isDarkMode) {
    final isBack = key == "back";
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(key),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
          ),
          child: Center(
            child: isBack
              ? const Icon(Icons.backspace_rounded, size: 28, color: AppColors.primary)
              : Text(
                  key,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
          ),
        ),
      ),
    );
  }
}
