import 'dart:math';
import 'package:flutter/material.dart';
import '../models/waveform_data.dart';
import '../controllers/waveform_controller.dart';

/// A beautiful animated waveform widget that visualizes audio amplitude data.
class WaveformWidget extends StatefulWidget {
  /// Creates a waveform widget.
  const WaveformWidget({
    super.key,
    required this.controller,
    this.style = const WaveformStyle(),
    this.height = 200.0,
    this.width,
    this.onTap,
  });

  /// Controller that manages the waveform data and state
  final WaveformController controller;

  /// Style configuration for the waveform
  final WaveformStyle style;

  /// Height of the waveform widget
  final double height;

  /// Width of the waveform widget (defaults to available width)
  final double? width;

  /// Callback when the waveform is tapped
  final VoidCallback? onTap;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.style.backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveformPainter(
                dataPoints: widget.controller.dataPoints,
                style: widget.style,
                isActive: widget.controller.isActive,
                pulseScale: _pulseAnimation.value,
              ),
              size: Size(widget.width ?? double.infinity, widget.height),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for drawing the waveform.
class WaveformPainter extends CustomPainter {
  /// Creates a waveform painter.
  WaveformPainter({
    required this.dataPoints,
    required this.style,
    required this.isActive,
    this.pulseScale = 1.0,
  });

  /// List of waveform data points to draw
  final List<WaveformPoint> dataPoints;

  /// Style configuration for the waveform
  final WaveformStyle style;

  /// Whether the waveform is currently active
  final bool isActive;

  /// Scale factor for pulse animation
  final double pulseScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    switch (style.waveformStyle) {
      case WaveformDrawStyle.bars:
        _drawBars(canvas, size);
        break;
      case WaveformDrawStyle.line:
        _drawLine(canvas, size);
        break;
      case WaveformDrawStyle.filled:
        _drawFilled(canvas, size);
        break;
      case WaveformDrawStyle.circular:
        _drawCircular(canvas, size);
        break;
    }
  }

  void _drawBars(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = style.strokeWidth
      ..strokeCap = StrokeCap.round;

    final barWidth =
        (size.width - (style.barCount - 1) * style.barSpacing) / style.barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < style.barCount; i++) {
      // Use better interpolation for smoother bars
      final dataIndex = (dataPoints.length - 1) * i / (style.barCount - 1);
      final lowerIndex = dataIndex.floor();
      final upperIndex = (lowerIndex + 1).clamp(0, dataPoints.length - 1);
      final fraction = dataIndex - lowerIndex;

      // Interpolate between adjacent data points for smoother visualization
      double amplitude;
      if (lowerIndex == upperIndex) {
        amplitude = dataPoints[lowerIndex].amplitude;
      } else {
        final lowerAmplitude = dataPoints[lowerIndex].amplitude;
        final upperAmplitude = dataPoints[upperIndex].amplitude;
        amplitude =
            lowerAmplitude + (upperAmplitude - lowerAmplitude) * fraction;
      }

      // Apply pulse effect for active state with smoother scaling
      final baseScale = isActive ? 1.0 : 0.8;
      final pulseEffect = isActive ? (pulseScale - 1.0) * 0.3 + 1.0 : 1.0;
      final effectiveAmplitude = amplitude * baseScale * pulseEffect;

      // Apply minimum height and smooth scaling
      const minHeight = 4.0;
      final maxHeight = size.height * 0.8;
      final barHeight =
          (effectiveAmplitude * maxHeight).clamp(minHeight, maxHeight);

      final x = i * (barWidth + style.barSpacing) + barWidth / 2;
      final startY = centerY - barHeight / 2;

      if (style.showGradient) {
        // Create gradient with alpha based on amplitude for nice effect
        final alphaFactor = (0.3 + amplitude * 0.7).clamp(0.3, 1.0);
        paint.shader = LinearGradient(
          begin: style.gradientBegin,
          end: style.gradientEnd,
          colors: [
            style.waveColor.withValues(alpha: alphaFactor),
            style.waveColor.withValues(alpha: alphaFactor * 0.3),
          ],
        ).createShader(
            Rect.fromLTWH(x - barWidth / 2, 0, barWidth, size.height));
      } else {
        // Apply alpha based on amplitude for depth effect
        final alphaFactor = (0.4 + amplitude * 0.6).clamp(0.4, 1.0);
        paint.color = style.waveColor.withValues(alpha: alphaFactor);
      }

      // Draw rounded rectangle bars for smoother appearance
      final radius = (barWidth * 0.3).clamp(1.0, 3.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth / 2, startY, barWidth, barHeight),
          Radius.circular(radius),
        ),
        paint,
      );
    }
  }

  void _drawLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.waveColor
      ..strokeWidth = style.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    bool isFirst = true;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final amplitude = dataPoints[i].amplitude;
      final effectiveAmplitude = isActive ? amplitude * pulseScale : amplitude;
      final y = centerY - (effectiveAmplitude - 0.5) * size.height * 0.8;

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    if (style.showGradient) {
      paint.shader = LinearGradient(
        begin: style.gradientBegin,
        end: style.gradientEnd,
        colors: [
          style.waveColor,
          style.waveColor.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    canvas.drawPath(path, paint);
  }

  void _drawFilled(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final path = Path();
    final centerY = size.height / 2;

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw the waveform line
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final amplitude = dataPoints[i].amplitude;
      final effectiveAmplitude = isActive ? amplitude * pulseScale : amplitude;
      final y = centerY - (effectiveAmplitude - 0.5) * size.height * 0.8;

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Close the path to create a filled shape
    path.lineTo(size.width, size.height);
    path.close();

    if (style.showGradient) {
      paint.shader = LinearGradient(
        begin: style.gradientBegin,
        end: style.gradientEnd,
        colors: [
          style.waveColor.withValues(alpha: 0.8),
          style.waveColor.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = style.waveColor.withValues(alpha: 0.6);
    }

    canvas.drawPath(path, paint);
  }

  void _drawCircular(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = style.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 4;

    for (int i = 0; i < dataPoints.length; i++) {
      final angle = (i / dataPoints.length) * 2 * pi;
      final amplitude = dataPoints[i].amplitude;
      final effectiveAmplitude = isActive ? amplitude * pulseScale : amplitude;
      final radius = baseRadius + effectiveAmplitude * baseRadius;

      final startX = center.dx + cos(angle) * baseRadius;
      final startY = center.dy + sin(angle) * baseRadius;
      final endX = center.dx + cos(angle) * radius;
      final endY = center.dy + sin(angle) * radius;

      if (style.showGradient) {
        final gradientRadius = radius - baseRadius;
        paint.shader = RadialGradient(
          colors: [
            style.waveColor,
            style.waveColor.withValues(alpha: 0.3),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: gradientRadius));
      } else {
        paint.color = style.waveColor;
      }

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.isActive != isActive ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.style != style;
  }
}
