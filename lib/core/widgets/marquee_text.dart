import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double pixelsPerSecond; // Kecepatan lambat & lembut (piksel per detik)
  final double gap;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.pixelsPerSecond = 20.0, // Kecepatan pelan & halus
    this.gap = 50.0, // Jarak antar teks saat berputar
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late ScrollController _scrollController;
  bool _isOverflowing = false;
  double _textWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initController();
  }

  void _initController() {
    _controller = AnimationController(vsync: this);
    _controller!.addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    if (_isOverflowing && _scrollController.hasClients && _controller != null) {
      final totalDistance = _textWidth + widget.gap;
      _scrollController.jumpTo(_controller!.value * totalDistance);
    }
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller?.stop();
      _controller?.reset();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onAnimationTick);
    _controller?.dispose();
    _controller = null;
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimation(double textWidth, double containerWidth) {
    if (!mounted || _controller == null) return;
    
    _textWidth = textWidth;
    final isOverflow = textWidth > containerWidth;

    if (isOverflow != _isOverflowing) {
      _isOverflowing = isOverflow;
    }

    if (_isOverflowing) {
      final totalDistance = _textWidth + widget.gap;
      final durationSeconds = totalDistance / widget.pixelsPerSecond;
      final durationMs = (durationSeconds * 1000).toInt();

      if (_controller!.duration?.inMilliseconds != durationMs) {
        _controller!.duration = Duration(milliseconds: durationMs);
      }

      if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    } else {
      _controller!.stop();
      _controller!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final textWidth = textPainter.width;
        final containerWidth = constraints.maxWidth;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _setupAnimation(textWidth, containerWidth);
          }
        });

        if (textWidth <= containerWidth) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.text, style: widget.style),
              SizedBox(width: widget.gap),
              Text(widget.text, style: widget.style),
              SizedBox(width: widget.gap),
              Text(widget.text, style: widget.style),
              SizedBox(width: widget.gap),
            ],
          ),
        );
      },
    );
  }
}
