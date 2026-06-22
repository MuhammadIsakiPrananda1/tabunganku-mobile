import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> with TickerProviderStateMixin {
  String _currentPin = "";
  bool _isOldPinStage = false;
  bool _isConfirmStage = false;
  String _firstPin = "";
  late AnimationController _shakeController;
  bool _isError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    final security = ref.read(securityProvider);
    if (security.hasPin) {
      _isOldPinStage = true;
    }
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String value) {
    setState(() {
      _isError = false;
      _errorMessage = "";
    });

    if (value == "back") {
      if (_currentPin.isNotEmpty) {
        setState(() => _currentPin = _currentPin.substring(0, _currentPin.length - 1));
      }
    } else {
      if (_currentPin.length < 4) {
        setState(() => _currentPin += value);
        if (_currentPin.length == 4) {

          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) _handlePinCompletion();
          });
        }
      }
    }
  }

  Future<void> _handlePinCompletion() async {
    if (_isOldPinStage) {

      final isValid = await ref.read(securityProvider.notifier).verifyPin(_currentPin);
      if (isValid) {
        setState(() {
          _isOldPinStage = false;
          _currentPin = "";
        });
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'PIN Lama Salah!';
          _currentPin = "";
        });
        _shakeController.forward(from: 0);
        HapticFeedback.vibrate();
      }
    } else if (!_isConfirmStage) {

      _firstPin = _currentPin;
      setState(() {
        _isConfirmStage = true;
        _currentPin = "";
      });
    } else {

      if (_currentPin == _firstPin) {

        ref.read(securityProvider.notifier).setPin(_currentPin);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PIN Keamanan Berhasil Diatur! ✓',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } else {

        setState(() {
          _isError = true;
          _errorMessage = 'PIN tidak cocok, silakan coba lagi.';
          _currentPin = "";
          _isConfirmStage = false;
          _firstPin = "";
        });
        _shakeController.forward(from: 0);
        HapticFeedback.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 50),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _isOldPinStage 
                            ? Icons.lock_outline_rounded 
                            : (_isConfirmStage ? Icons.gpp_good_rounded : Icons.shield_outlined),
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

Text(
                        _isOldPinStage 
                          ? 'PIN Lama' 
                          : (_isConfirmStage ? 'Konfirmasi PIN Baru' : 'Atur PIN Baru'),
                        style: GoogleFonts.quicksand(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

Text(
                        _isOldPinStage
                          ? 'Masukkan PIN lama kamu untuk verifikasi'
                          : (_isConfirmStage 
                            ? 'Masukkan kembali 4 digit PIN baru kamu'
                            : 'Gunakan 4 digit angka rahasia untuk keamanan'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 36),

AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final offset = Curves.elasticIn.transform(_shakeController.value) * 10;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                final active = index < _currentPin.length;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: active ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),

if (_isError)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                      const Spacer(flex: 2),

_buildKeypad(isDarkMode),
                      const SizedBox(height: 32),
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
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var val in row) _buildKeypadButton(val, isDarkMode),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              const SizedBox(width: 72),
              _buildKeypadButton('0', isDarkMode),
              _buildKeypadIconButton(Icons.backspace_outlined, _onBackspace, isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  void _onBackspace() {
    _onKeyPress("back");
  }

  Widget _buildKeypadButton(String value, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(value),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.03),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadIconButton(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.03),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}
