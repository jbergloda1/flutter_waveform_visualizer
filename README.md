# Waveform Visualizer

[![pub package](https://img.shields.io/pub/v/waveform_visualizer.svg)](https://pub.dev/packages/waveform_visualizer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful animated waveform widget for Flutter with real-time visualization capabilities. Perfect for audio applications, voice recorders, and music visualizers.

## ✨ Features

- **🎵 Real-time Waveform Visualization**: Beautiful animated waveforms that respond to amplitude data
- **🎨 Multiple Styles**: Choose from bars, line, filled, and circular waveform styles
- **🌈 Customizable Appearance**: Full control over colors, gradients, stroke width, and animations
- **📱 Responsive Design**: Adapts beautifully to different screen sizes and orientations
- **🚀 Smooth Animations**: Fluid animations with customizable pulse effects
- **⚡ High Performance**: Optimized custom painter for smooth 60fps animations
- **🔧 Easy Integration**: Simple API that works with any audio input source

## 📸 Screenshots

![Waveform Styles](https://via.placeholder.com/600x300/0D1117/cyan?text=Waveform+Visualizer+Demo)

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  waveform_visualizer: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📖 Usage

### Basic Setup

Import the package and initialize it:

```dart
import 'package:waveform_visualizer/waveform_visualizer.dart';

void main() {
  WaveformVisualizer.initialize();
  runApp(MyApp());
}
```

### Simple Waveform Widget

Create a basic waveform visualization:

```dart
class MyWaveformPage extends StatefulWidget {
  @override
  _MyWaveformPageState createState() => _MyWaveformPageState();
}

class _MyWaveformPageState extends State<MyWaveformPage> {
  late WaveformController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaveformController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WaveformWidget(
          controller: _controller,
          height: 200,
          style: WaveformStyle(
            waveColor: Colors.cyan,
            backgroundColor: Colors.black,
            waveformStyle: WaveformDrawStyle.bars,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.isActive) {
            _controller.stop();
          } else {
            _controller.start();
          }
        },
        child: Icon(_controller.isActive ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
```

### Connecting to Microphone

To use with real microphone input, update the amplitude with your audio data:

```dart
// Example with a hypothetical audio package
void onAudioData(List<double> audioSamples) {
  // Calculate RMS amplitude from audio samples
  double amplitude = calculateRMS(audioSamples);
  
  // Update the waveform (amplitude should be 0.0 to 1.0)
  _controller.updateAmplitude(amplitude);
}

double calculateRMS(List<double> samples) {
  double sum = 0.0;
  for (double sample in samples) {
    sum += sample * sample;
  }
  return sqrt(sum / samples.length);
}
```

### Advanced Controller Configuration

```dart
// Configure controller for optimal smoothness
_controller = WaveformController(
  maxDataPoints: 80,              // Data history size
  updateInterval: Duration(milliseconds: 33), // 30fps update rate
  smoothingFactor: 0.85,          // Smoothing intensity (0.0-1.0)
);
```

## 🎨 Customization

### Waveform Styles

Choose from multiple visualization styles:

```dart
// Bar style (default)
WaveformStyle(waveformStyle: WaveformDrawStyle.bars)

// Line style
WaveformStyle(waveformStyle: WaveformDrawStyle.line)

// Filled style
WaveformStyle(waveformStyle: WaveformDrawStyle.filled)

// Circular style
WaveformStyle(waveformStyle: WaveformDrawStyle.circular)
```

### Custom Styling

Customize the appearance with rich styling options:

```dart
WaveformStyle(
  waveColor: Colors.cyan,
  backgroundColor: Colors.black,
  strokeWidth: 3.0,
  showGradient: true,
  gradientBegin: Alignment.topCenter,
  gradientEnd: Alignment.bottomCenter,
  barCount: 60,
  barSpacing: 2.0,
  animationDuration: Duration(milliseconds: 150),
)
```

### Style Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `waveColor` | `Color` | `Colors.blue` | Primary color of the waveform |
| `backgroundColor` | `Color` | `Colors.black` | Background color |
| `strokeWidth` | `double` | `2.0` | Width of waveform lines/bars |
| `showGradient` | `bool` | `true` | Enable gradient effects |
| `gradientBegin` | `Alignment` | `topCenter` | Gradient start point |
| `gradientEnd` | `Alignment` | `bottomCenter` | Gradient end point |
| `waveformStyle` | `WaveformDrawStyle` | `bars` | Visualization style |
| `barCount` | `int` | `50` | Number of bars (bar style only) |
| `barSpacing` | `double` | `2.0` | Space between bars |
| `animationDuration` | `Duration` | `100ms` | Animation speed |

## 🎛️ Controller API

### WaveformController Methods

| Method | Description |
|--------|-------------|
| `start()` | Start the waveform visualization |
| `stop()` | Stop the visualization |
| `reset()` | Reset all data points to zero |
| `updateAmplitude(double)` | Update with new amplitude (0.0-1.0) |
| `generateTestPattern()` | Generate demo animation pattern |

### Controller Properties

| Property | Type | Description |
|----------|------|-------------|
| `isActive` | `bool` | Whether visualization is running |
| `currentAmplitude` | `double` | Current amplitude value |
| `dataPoints` | `List<WaveformPoint>` | Historical amplitude data |
| `maxDataPoints` | `int` | Maximum data points to store |

## 🎯 Real-World Example

Here's a complete example with multiple waveform styles:

```dart
import 'package:flutter/material.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class WaveformShowcase extends StatefulWidget {
  @override
  _WaveformShowcaseState createState() => _WaveformShowcaseState();
}

class _WaveformShowcaseState extends State<WaveformShowcase> {
  late WaveformController _controller;
  WaveformDrawStyle _currentStyle = WaveformDrawStyle.bars;

  @override
  void initState() {
    super.initState();
    _controller = WaveformController();
    _controller.start(); // Auto-start with demo data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('🎵 Waveform Showcase'),
        backgroundColor: Color(0xFF161B22),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: WaveformWidget(
                controller: _controller,
                height: 200,
                style: WaveformStyle(
                  waveColor: Colors.cyan,
                  backgroundColor: Color(0xFF0D1117),
                  waveformStyle: _currentStyle,
                  showGradient: true,
                  strokeWidth: 3.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: WaveformDrawStyle.values.map((style) {
                return ElevatedButton(
                  onPressed: () => setState(() => _currentStyle = style),
                  child: Text(style.name.toUpperCase()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStyle == style 
                        ? Colors.cyan 
                        : Colors.grey[700],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 📱 Example App

Check out the [example](example/) directory for a complete demo application showcasing all features:

- Multiple waveform styles
- Real-time style switching
- Color customization
- Interactive controls
- Test pattern generation

To run the example:

```bash
cd example
flutter run
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
flutter test
```

The package includes tests for:
- ✅ Waveform controller functionality
- ✅ Data point management
- ✅ Style configuration
- ✅ Animation behavior
- ✅ Edge cases and error handling

## 🔧 Performance Tips

1. **Optimize Data Points**: Use fewer `maxDataPoints` for better performance on lower-end devices (recommended: 50-100)
2. **Adjust Update Frequency**: Use 30-60fps update interval (`Duration(milliseconds: 33)` for 30fps)
3. **Choose Appropriate Styles**: Bar and line styles are more performant than filled or circular
4. **Control Bar Count**: Keep bar count between 20-60 for smooth animations
5. **Use Smoothing**: Higher `smoothingFactor` (0.8-0.9) reduces jerkiness but adds slight delay
6. **Optimize for Device**: Lower settings on older devices, higher on flagship phones

### Smoothness Optimizations

The package includes several built-in optimizations for smooth animations:

- **Amplitude Smoothing**: Configurable smoothing factor to reduce jerkiness
- **Interpolation**: Linear interpolation between data points for bar visualization
- **Moving Average Filter**: 3-point moving average for additional smoothness
- **Eased Animations**: Smooth easing functions for fade-out effects
- **Optimized Update Rates**: Balanced update frequency for 30-60fps performance

```dart
// Smooth configuration example
WaveformController(
  maxDataPoints: 80,
  updateInterval: Duration(milliseconds: 33), // 30fps
  smoothingFactor: 0.85, // High smoothing
)
```

## 🎨 Design Inspiration

This package is perfect for:
- 🎤 Voice recording apps
- 🎵 Music players and visualizers
- 📞 Voice chat applications
- 🎙️ Podcast apps
- 🔊 Audio analysis tools
- 🎮 Interactive audio games

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 API Documentation

For detailed API documentation, visit [pub.dev/documentation/waveform_visualizer](https://pub.dev/documentation/waveform_visualizer)

## 🆘 Support

If you find this package helpful, please:
- ⭐ Star it on [GitHub](https://github.com/yourusername/waveform_visualizer)
- 👍 Like it on [pub.dev](https://pub.dev/packages/waveform_visualizer)
- 🐛 Report issues on the [issue tracker](https://github.com/yourusername/waveform_visualizer/issues)

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

---

Made with ❤️ for the Flutter community 