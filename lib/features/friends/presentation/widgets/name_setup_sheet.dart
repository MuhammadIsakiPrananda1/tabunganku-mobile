import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/family_group_provider.dart';

class NameSetupSheet extends ConsumerStatefulWidget {
  const NameSetupSheet({super.key});

  @override
  ConsumerState<NameSetupSheet> createState() => _NameSetupSheetState();
}

class _NameSetupSheetState extends ConsumerState<NameSetupSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan nama panggilan kamu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(userProfileProvider.notifier).setName(name);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nama Panggilan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan nama panggilan agar anggota keluarga lain mengenalimu.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Contoh: Ayah, Ibu, Kakak...',
              prefixIcon: const Icon(Icons.person, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan Nama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

void showNameSetupSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => const NameSetupSheet(),
  );
}
