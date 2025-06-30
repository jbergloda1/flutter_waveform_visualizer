library waveform_visualizer;

/// A Flutter package that provides beautiful animated waveform visualization
/// for real-time audio representation.
/// 
/// This package includes:
/// * Animated waveform widget
/// * Real-time amplitude processing
/// * Customizable appearance
/// * Smooth animations
/// 
/// To use this package, add it to your pubspec.yaml:
/// ```yaml
/// dependencies:
///   waveform_visualizer: ^1.0.0
/// ```
/// 
/// Then import it in your Dart code:
/// ```dart
/// import 'package:waveform_visualizer/waveform_visualizer.dart';
/// ```

export 'src/waveform_visualizer_base.dart';
export 'src/widgets/waveform_widget.dart';
export 'src/models/waveform_data.dart';
export 'src/controllers/waveform_controller.dart'; 