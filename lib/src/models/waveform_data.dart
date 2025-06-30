import 'package:flutter/material.dart';

/// Represents a single amplitude value with timestamp for waveform visualization.
class WaveformPoint {
  /// Creates a waveform point.
  const WaveformPoint({
    required this.amplitude,
    required this.timestamp,
  });

  /// The amplitude value (typically between 0.0 and 1.0)
  final double amplitude;

  /// The timestamp when this amplitude was recorded
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaveformPoint &&
          runtimeType == other.runtimeType &&
          amplitude == other.amplitude &&
          timestamp == other.timestamp;

  @override
  int get hashCode => amplitude.hashCode ^ timestamp.hashCode;
}

/// Represents waveform configuration and styling options.
class WaveformStyle {
  /// Creates a waveform style configuration.
  const WaveformStyle({
    this.waveColor = const Color(0xFF2196F3),
    this.backgroundColor = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.showGradient = true,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.waveformStyle = WaveformDrawStyle.bars,
    this.barCount = 50,
    this.barSpacing = 2.0,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  /// Primary color of the waveform
  final Color waveColor;

  /// Background color of the widget
  final Color backgroundColor;

  /// Width of the waveform stroke
  final double strokeWidth;

  /// Whether to show gradient effect
  final bool showGradient;

  /// Gradient start alignment
  final Alignment gradientBegin;

  /// Gradient end alignment
  final Alignment gradientEnd;

  /// Style of waveform drawing
  final WaveformDrawStyle waveformStyle;

  /// Number of bars (for bar style)
  final int barCount;

  /// Spacing between bars
  final double barSpacing;

  /// Animation duration for amplitude changes
  final Duration animationDuration;

  /// Creates a copy of this style with given fields replaced by new values.
  WaveformStyle copyWith({
    Color? waveColor,
    Color? backgroundColor,
    double? strokeWidth,
    bool? showGradient,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
    WaveformDrawStyle? waveformStyle,
    int? barCount,
    double? barSpacing,
    Duration? animationDuration,
  }) {
    return WaveformStyle(
      waveColor: waveColor ?? this.waveColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      showGradient: showGradient ?? this.showGradient,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      waveformStyle: waveformStyle ?? this.waveformStyle,
      barCount: barCount ?? this.barCount,
      barSpacing: barSpacing ?? this.barSpacing,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

/// Different styles for drawing waveforms.
enum WaveformDrawStyle {
  /// Draw as vertical bars
  bars,
  
  /// Draw as continuous line
  line,
  
  /// Draw as filled wave
  filled,
  
  /// Draw as circular wave
  circular,
} 