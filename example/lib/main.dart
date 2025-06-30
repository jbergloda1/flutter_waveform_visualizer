import 'package:flutter/material.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

void main() {
  // Initialize the package
  WaveformVisualizer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waveform Visualizer Demo',
      theme: ThemeData.dark().copyWith(
        // primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
        cardColor: const Color(0xFF161B22),
        useMaterial3: true,
      ),
      home: const WaveformDemoPage(),
    );
  }
}

class WaveformDemoPage extends StatefulWidget {
  const WaveformDemoPage({Key? key}) : super(key: key);

  @override
  State<WaveformDemoPage> createState() => _WaveformDemoPageState();
}

class _WaveformDemoPageState extends State<WaveformDemoPage> {
  late WaveformController _waveformController;
  WaveformDrawStyle _selectedStyle = WaveformDrawStyle.bars;
  Color _selectedColor = Colors.cyan;
  bool _showGradient = true;
  double _strokeWidth = 2.0;
  int _barCount = 40;

  final List<Color> _colorOptions = [
    Colors.cyan,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.pink,
    Colors.blue,
    Colors.red,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _waveformController = WaveformController(
      maxDataPoints: 80,
      updateInterval: const Duration(milliseconds: 33),
      smoothingFactor: 0.85,
    );
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  void _showPackageInfo() {
    final info = WaveformVisualizer.getPackageInfo();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Package Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waveformStyle = WaveformStyle(
      waveColor: _selectedColor,
      backgroundColor: const Color(0xFF0D1117),
      strokeWidth: _strokeWidth,
      showGradient: _showGradient,
      gradientBegin: Alignment.topCenter,
      gradientEnd: Alignment.bottomCenter,
      waveformStyle: _selectedStyle,
      barCount: _barCount,
      barSpacing: 2.0,
      animationDuration: const Duration(milliseconds: 100),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Waveform Visualizer Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPackageInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Waveform Display
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🎤 Live Waveform Visualization',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WaveformWidget(
                      controller: _waveformController,
                      style: waveformStyle,
                      height: 200,
                      onTap: () {
                        if (_waveformController.isActive) {
                          _waveformController.stop();
                        } else {
                          _waveformController.start();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_waveformController.isActive) {
                              _waveformController.stop();
                            } else {
                              _waveformController.start();
                            }
                          },
                          icon: Icon(_waveformController.isActive 
                              ? Icons.stop 
                              : Icons.play_arrow),
                          label: Text(_waveformController.isActive 
                              ? 'Stop' 
                              : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _waveformController.isActive 
                                ? Colors.red 
                                : Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _waveformController.generateTestPattern,
                          icon: const Icon(Icons.graphic_eq),
                          label: const Text('Test Pattern'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _waveformController.reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Style Controls
            _buildControlCard(
              title: '🎨 Waveform Style',
              child: Wrap(
                spacing: 8.0,
                children: WaveformDrawStyle.values.map((style) {
                  final isSelected = _selectedStyle == style;
                  return FilterChip(
                    label: Text(_getStyleName(style)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStyle = style;
                      });
                    },
                    selectedColor: Colors.cyan.withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
            ),

            // Color Controls
            _buildControlCard(
              title: '🌈 Colors',
              child: Column(
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: isSelected 
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Gradient Effect'),
                    value: _showGradient,
                    onChanged: (value) {
                      setState(() {
                        _showGradient = value;
                      });
                    },
                    activeColor: Colors.cyan,
                  ),
                ],
              ),
            ),

            // Advanced Controls
            _buildControlCard(
              title: '⚙️ Advanced Settings',
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Stroke Width'),
                    subtitle: Slider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: _strokeWidth.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _strokeWidth = value;
                        });
                      },
                      activeColor: Colors.cyan,
                    ),
                  ),
                  if (_selectedStyle == WaveformDrawStyle.bars)
                    ListTile(
                      title: const Text('Bar Count'),
                      subtitle: Slider(
                        value: _barCount.toDouble(),
                        min: 20,
                        max: 60,
                        divisions: 8,
                        label: _barCount.toString(),
                        onChanged: (value) {
                          setState(() {
                            _barCount = value.round();
                          });
                        },
                        activeColor: Colors.cyan,
                      ),
                    ),
                ],
              ),
            ),

            // Information Card
            _buildControlCard(
              title: '📱 Usage Instructions',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Tap the waveform to start/stop visualization'),
                  SizedBox(height: 4),
                  Text('• Use "Test Pattern" to see a demo animation'),
                  SizedBox(height: 4),
                  Text('• Try different styles and colors'),
                  SizedBox(height: 4),
                  Text('• Bars use interpolation for smooth animation'),
                  SizedBox(height: 4),
                  Text('• Lower bar count = smoother performance'),
                  SizedBox(height: 4),
                  Text('• In real apps, connect to microphone amplitude'),
                  SizedBox(height: 8),
                  Text(
                    'Current: Smoothed real-time simulated data',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStyleName(WaveformDrawStyle style) {
    switch (style) {
      case WaveformDrawStyle.bars:
        return 'Bars';
      case WaveformDrawStyle.line:
        return 'Line';
      case WaveformDrawStyle.filled:
        return 'Filled';
      case WaveformDrawStyle.circular:
        return 'Circular';
    }
  }
} 