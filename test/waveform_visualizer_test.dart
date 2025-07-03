import 'package:flutter_test/flutter_test.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

void main() {
  group('WaveformVisualizer', () {
    test('should return correct package info', () {
      final info = WaveformVisualizer.getPackageInfo();

      expect(info['name'], equals('waveform_visualizer'));
      expect(info['version'], equals('1.0.0'));
      expect(info['description'], isNotEmpty);
    });

    test('should have correct version', () {
      expect(WaveformVisualizer.version, equals('1.0.0'));
    });

    test('should have correct package name', () {
      expect(WaveformVisualizer.packageName, equals('waveform_visualizer'));
    });
  });

  group('WaveformController', () {
    late WaveformController controller;

    setUp(() {
      controller = WaveformController(
        maxDataPoints: 50,
        updateInterval: const Duration(milliseconds: 100),
        smoothingFactor: 0.8,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with correct default values', () {
      expect(controller.currentAmplitude, equals(0.0));
      expect(controller.isActive, isFalse);
      expect(controller.maxDataPoints, equals(50));
      expect(controller.dataPoints.length, equals(50));
    });

    test('should update amplitude correctly with smoothing', () {
      // First update
      controller.updateAmplitude(1.0);
      expect(controller.currentAmplitude, lessThan(1.0)); // Should be smoothed
      expect(controller.currentAmplitude, greaterThan(0.0));

      // Second update should get closer to target
      controller.updateAmplitude(1.0);
      final secondAmplitude = controller.currentAmplitude;

      // Third update should get even closer
      controller.updateAmplitude(1.0);
      expect(controller.currentAmplitude, greaterThan(secondAmplitude));
    });

    test('should clamp amplitude to valid range', () {
      controller.updateAmplitude(-0.5);
      expect(controller.currentAmplitude, greaterThanOrEqualTo(0.0));

      controller.updateAmplitude(1.5);
      // Reset controller to test upper bound properly
      final newController = WaveformController(smoothingFactor: 0.0);
      newController.updateAmplitude(1.5);
      expect(newController.currentAmplitude, lessThanOrEqualTo(1.0));
      newController.dispose();
    });

    test('should start and stop correctly', () {
      expect(controller.isActive, isFalse);

      controller.start();
      expect(controller.isActive, isTrue);

      controller.stop();
      expect(controller.isActive, isFalse);
    });

    test('should reset data correctly', () {
      controller.updateAmplitude(0.8);
      controller.reset();

      expect(controller.currentAmplitude, equals(0.0));
      expect(controller.isActive, isFalse);
      expect(controller.dataPoints.every((point) => point.amplitude == 0.0),
          isTrue);
    });

    test('should maintain maximum data points', () {
      final maxPoints = controller.maxDataPoints;

      // Add more points than the maximum
      for (int i = 0; i < maxPoints + 10; i++) {
        controller.updateAmplitude(0.5);
      }

      expect(controller.dataPoints.length, equals(maxPoints));
    });

    test('should apply smoothing correctly', () {
      final controllerNoSmoothing = WaveformController(smoothingFactor: 0.0);
      final controllerWithSmoothing = WaveformController(smoothingFactor: 0.8);

      // Update both with same large amplitude
      controllerNoSmoothing.updateAmplitude(1.0);
      controllerWithSmoothing.updateAmplitude(1.0);

      // Controller with smoothing should have lower amplitude initially
      expect(controllerWithSmoothing.currentAmplitude,
          lessThan(controllerNoSmoothing.currentAmplitude));

      controllerNoSmoothing.dispose();
      controllerWithSmoothing.dispose();
    });
  });

  group('WaveformPoint', () {
    test('should create point with correct values', () {
      final timestamp = DateTime.now();
      final point = WaveformPoint(amplitude: 0.7, timestamp: timestamp);

      expect(point.amplitude, equals(0.7));
      expect(point.timestamp, equals(timestamp));
    });

    test('should compare equality correctly', () {
      final timestamp = DateTime.now();
      final point1 = WaveformPoint(amplitude: 0.5, timestamp: timestamp);
      final point2 = WaveformPoint(amplitude: 0.5, timestamp: timestamp);
      final point3 = WaveformPoint(amplitude: 0.6, timestamp: timestamp);

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });
  });

  group('WaveformStyle', () {
    test('should create with default values', () {
      const style = WaveformStyle();

      expect(style.strokeWidth, equals(2.0));
      expect(style.showGradient, isTrue);
      expect(style.waveformStyle, equals(WaveformDrawStyle.bars));
      expect(style.barCount, equals(50));
      expect(style.barSpacing, equals(2.0));
    });

    test('should copy with new values', () {
      const originalStyle = WaveformStyle();
      final newStyle = originalStyle.copyWith(
        strokeWidth: 5.0,
        showGradient: false,
        waveformStyle: WaveformDrawStyle.line,
      );

      expect(newStyle.strokeWidth, equals(5.0));
      expect(newStyle.showGradient, isFalse);
      expect(newStyle.waveformStyle, equals(WaveformDrawStyle.line));
      // Other values should remain the same
      expect(newStyle.barCount, equals(originalStyle.barCount));
      expect(newStyle.barSpacing, equals(originalStyle.barSpacing));
    });
  });

  group('WaveformDrawStyle', () {
    test('should have all expected values', () {
      expect(WaveformDrawStyle.values.length, equals(4));
      expect(WaveformDrawStyle.values, contains(WaveformDrawStyle.bars));
      expect(WaveformDrawStyle.values, contains(WaveformDrawStyle.line));
      expect(WaveformDrawStyle.values, contains(WaveformDrawStyle.filled));
      expect(WaveformDrawStyle.values, contains(WaveformDrawStyle.circular));
    });
  });
}
