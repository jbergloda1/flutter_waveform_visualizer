/// Base class for the Waveform Visualizer package.
/// 
/// This class provides core functionality and serves as the main entry point
/// for the package's features.
class WaveformVisualizer {
  /// The current version of the package
  static const String version = '1.0.0';
  
  /// Package name
  static const String packageName = 'waveform_visualizer';
  
  /// Initialize the package
  /// 
  /// Call this method in your app's main function to initialize
  /// the package with default settings.
  static void initialize() {
    print('$packageName v$version initialized');
  }
  
  /// Get package information
  /// 
  /// Returns a map containing package metadata.
  static Map<String, String> getPackageInfo() {
    return {
      'name': packageName,
      'version': version,
      'description': 'A beautiful animated waveform widget for Flutter',
    };
  }
} 