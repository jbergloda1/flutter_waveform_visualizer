import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/waveform_data.dart';

/// Controller for managing waveform visualization state and animations.
class WaveformController extends ChangeNotifier {
  /// Creates a waveform controller.
  WaveformController({
    int maxDataPoints = 100,
    Duration updateInterval = const Duration(milliseconds: 50),
    double smoothingFactor = 0.8,
  }) : _maxDataPoints = maxDataPoints,
       _updateInterval = updateInterval,
       _smoothingFactor = smoothingFactor {
    _initializeData();
  }

  final int _maxDataPoints;
  final Duration _updateInterval;
  final double _smoothingFactor;
  final List<WaveformPoint> _dataPoints = [];
  final List<double> _smoothedAmplitudes = [];
  Timer? _timer;
  Timer? _fadeOutTimer;
  bool _isActive = false;
  double _currentAmplitude = 0.0;
  double _targetAmplitude = 0.0;
  bool _disposed = false;

  /// Current amplitude value (0.0 to 1.0)
  double get currentAmplitude => _currentAmplitude;

  /// List of waveform data points
  List<WaveformPoint> get dataPoints => List.unmodifiable(_dataPoints);

  /// Whether the waveform is currently active
  bool get isActive => _isActive;

  /// Maximum number of data points to maintain
  int get maxDataPoints => _maxDataPoints;

  void _initializeData() {
    _dataPoints.clear();
    _smoothedAmplitudes.clear();
    for (int i = 0; i < _maxDataPoints; i++) {
      _dataPoints.add(WaveformPoint(
        amplitude: 0.0,
        timestamp: DateTime.now().subtract(Duration(
          milliseconds: (_maxDataPoints - i) * _updateInterval.inMilliseconds,
        )),
      ));
      _smoothedAmplitudes.add(0.0);
    }
  }

  /// Start the waveform visualization.
  void start() {
    if (_isActive) return;
    
    _isActive = true;
    _timer = Timer.periodic(_updateInterval, (_) {
      // Generate some sample data for demonstration
      _updateWithSampleData();
    });
    notifyListeners();
  }

  /// Stop the waveform visualization.
  void stop() {
    if (!_isActive) return;
    
    _isActive = false;
    _timer?.cancel();
    _timer = null;
    
    // Gradually fade out the amplitude
    _fadeOut();
  }

  /// Update with new amplitude data from microphone.
  /// 
  /// [amplitude] should be a value between 0.0 and 1.0
  void updateAmplitude(double amplitude) {
    _targetAmplitude = amplitude.clamp(0.0, 1.0);
    
    // Smooth the amplitude change to reduce jerkiness
    _currentAmplitude = _currentAmplitude * _smoothingFactor + 
                       _targetAmplitude * (1.0 - _smoothingFactor);
    
    _addDataPoint(_currentAmplitude);
  }

  void _addDataPoint(double amplitude) {
    final newPoint = WaveformPoint(
      amplitude: amplitude,
      timestamp: DateTime.now(),
    );

    _dataPoints.add(newPoint);
    _smoothedAmplitudes.add(amplitude);
    
    // Remove old data points if we exceed the maximum
    if (_dataPoints.length > _maxDataPoints) {
      _dataPoints.removeAt(0);
      _smoothedAmplitudes.removeAt(0);
    }
    
    // Apply additional smoothing to the amplitude array
    _applySmoothingFilter();
    
    notifyListeners();
  }

  void _applySmoothingFilter() {
    if (_smoothedAmplitudes.length < 3) return;
    
    // Apply a simple moving average filter for smoothness
    for (int i = 1; i < _smoothedAmplitudes.length - 1; i++) {
      final prev = _smoothedAmplitudes[i - 1];
      final current = _smoothedAmplitudes[i];
      final next = _smoothedAmplitudes[i + 1];
      
      // Simple 3-point moving average
      _smoothedAmplitudes[i] = (prev + current * 2 + next) / 4;
      
      // Update the corresponding data point
      _dataPoints[i] = WaveformPoint(
        amplitude: _smoothedAmplitudes[i],
        timestamp: _dataPoints[i].timestamp,
      );
    }
  }

  void _updateWithSampleData() {
    // Generate more realistic and smoother waveform data
    final random = Random();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Create a smoother complex waveform with multiple frequencies
    double amplitude = 0.0;
    amplitude += sin(time * 2 * pi * 0.3) * 0.4; // Lower frequency base
    amplitude += sin(time * 2 * pi * 1.2) * 0.3; // Mid frequency
    amplitude += sin(time * 2 * pi * 4.0) * 0.2; // Higher frequency detail
    amplitude += sin(time * 2 * pi * 0.1) * 0.1; // Very slow movement
    
    // Add gentler randomness
    amplitude += (random.nextDouble() - 0.5) * 0.15;
    
    // Normalize more smoothly
    amplitude = (amplitude + 1.0) / 2.0; // Convert from [-1,1] to [0,1]
    amplitude = amplitude.clamp(0.0, 1.0);
    
    // Add occasional but smoother spikes
    if (random.nextDouble() < 0.03) {
      final spikeIntensity = random.nextDouble() * 0.6 + 0.3;
      amplitude = max(amplitude, spikeIntensity);
    }
    
    // Apply envelope for more natural feel
    final envelope = (sin(time * 0.5) + 1.0) / 2.0;
    amplitude *= (0.3 + envelope * 0.7);
    
    updateAmplitude(amplitude);
  }

  void _fadeOut() {
    // Cancel any existing fade out timer
    _fadeOutTimer?.cancel();
    
    const steps = 30; // More steps for smoother fade
    const stepDuration = Duration(milliseconds: 33); // ~30fps for smooth fade
    
    _fadeOutTimer = Timer.periodic(stepDuration, (timer) {
      if (timer.tick >= steps) {
        timer.cancel();
        _fadeOutTimer = null;
        _currentAmplitude = 0.0;
        _targetAmplitude = 0.0;
        if (!_disposed) {
          _addDataPoint(0.0);
        }
        return;
      }
      
      final progress = timer.tick / steps;
      final easedProgress = _easeOutCubic(progress);
      final fadeAmplitude = _currentAmplitude * (1.0 - easedProgress);
      if (!_disposed) {
        updateAmplitude(fadeAmplitude);
      }
    });
  }

  // Smooth easing function
  double _easeOutCubic(double t) {
    return 1 - pow(1 - t, 3).toDouble();
  }

  /// Reset the waveform data.
  void reset() {
    stop();
    _currentAmplitude = 0.0;
    _targetAmplitude = 0.0;
    _initializeData();
    notifyListeners();
  }

  /// Generate test pattern for demonstration.
  void generateTestPattern() {
    stop();
    
    const steps = 80; // More steps for smoother animation
    const stepDuration = Duration(milliseconds: 50);
    
    int currentStep = 0;
    Timer.periodic(stepDuration, (timer) {
      if (currentStep >= steps) {
        timer.cancel();
        return;
      }
      
      final progress = currentStep / steps;
      
      // Create a more complex and smooth test pattern
      double amplitude = 0.0;
      amplitude += sin(progress * 6 * pi) * 0.5; // Main wave
      amplitude += sin(progress * 16 * pi) * 0.2; // Higher frequency
      amplitude += sin(progress * 2 * pi) * 0.3; // Slower envelope
      
      // Add some randomness but keep it smooth
      final randomFactor = sin(progress * 20 * pi) * 0.1;
      amplitude += randomFactor;
      
      // Normalize and ensure positive
      amplitude = (amplitude + 1.0) / 2.0;
      amplitude = amplitude.clamp(0.1, 0.9);
      
      updateAmplitude(amplitude);
      currentStep++;
    });
  }

  @override
  void dispose() {
    stop();
    _fadeOutTimer?.cancel();
    _disposed = true;
    super.dispose();
  }
} 