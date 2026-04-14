import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

class SmartDigitalClock extends StatefulWidget {
  const SmartDigitalClock({super.key});

  @override
  State<SmartDigitalClock> createState() => _SmartDigitalClockState();
}

class _SmartDigitalClockState extends State<SmartDigitalClock> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('HH:mm:ss').format(_currentTime),
      style: GoogleFonts.comicNeue(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 2.0,
      ),
    );
  }
}

class SmartDateDisplay extends StatefulWidget {
  final bool isDarkMode;
  const SmartDateDisplay({super.key, required this.isDarkMode});

  @override
  State<SmartDateDisplay> createState() => _SmartDateDisplayState();
}

class _SmartDateDisplayState extends State<SmartDateDisplay> {
  DateTime _currentDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute is enough for date, or even every 1 hour
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && _currentDate.day != DateTime.now().day) {
        setState(() {
          _currentDate = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_currentDate),
      style: TextStyle(
        fontSize: 12,
        color: widget.isDarkMode ? Colors.white70 : Colors.teal,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
