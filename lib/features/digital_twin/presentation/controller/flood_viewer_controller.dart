import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/models.dart';

class TimeChange {
  const TimeChange(this.index, this.t);
  final int index;
  final String? t;
}

class CameraChange {
  const CameraChange(this.heading, this.mode);

  /// Cap en degres: 0 = la camera regarde vers le nord.
  final double heading;
  final ViewMode mode;
}

/// Encapsule la WebView et le canal JS "FloodBridge" (voir viewer_web/src/main.ts).
///
/// Flutter -> web : setScenarios, setScenario, setTime, setTheme, setLayers, setViewMode,
///                  resetCamera, faceNorth, screenshot.
/// Web -> Flutter : onReady, onScenarioChange, onTimeChange, onCameraChange, onScreenshot, onError.
class FloodViewerController {
  FloodViewerController({this.assetPath = 'assets/viewer/index.html'}) {
    webView = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFDCEBFA))
      ..addJavaScriptChannel(_channel, onMessageReceived: (m) => _onMessage(m.message))
      ..setNavigationDelegate(
        NavigationDelegate(
          // Les assets sont locaux: on bloque toute navigation sortante.
          onNavigationRequest: (r) => r.url.startsWith('file:') || r.url.startsWith('about:') ? NavigationDecision.navigate : NavigationDecision.prevent,
          onWebResourceError: (e) => _errors.add('WebView: ${e.description}'),
        ),
      )
      ..loadFlutterAsset(assetPath);
  }

  static const _channel = 'FloodBridge';

  final String assetPath;
  late final WebViewController webView;

  final _ready = Completer<void>();
  final _pending = <String>[];
  final _screenshots = <int, Completer<Uint8List>>{};
  var _nextRequest = 1;
  var _disposed = false;

  final _scenario = StreamController<String>.broadcast();
  final _time = StreamController<TimeChange>.broadcast();
  final _camera = StreamController<CameraChange>.broadcast();
  final _errors = StreamController<String>.broadcast();

  /// Termine quand la scene web a envoye onReady.
  Future<void> get ready => _ready.future;
  bool get isReady => _ready.isCompleted;

  /// Scenario choisi en touchant une bande dans la scene 3D.
  Stream<String> get onScenarioChange => _scenario.stream;
  Stream<TimeChange> get onTimeChange => _time.stream;
  Stream<CameraChange> get onCameraChange => _camera.stream;
  Stream<String> get onError => _errors.stream;

  // ---- Flutter -> web ----

  Future<void> setScenarios(FloodDataset d) => _send('setScenarios', d.toJson());

  Future<void> setScenario(String id) => _send('setScenario', {'id': id});

  /// Index fractionnaire dans la frise (0 = premier pas).
  Future<void> setTime(double index) => _send('setTime', {'index': index});

  Future<void> setTheme(FloodTheme theme) => _send('setTheme', {'theme': theme.name});

  Future<void> setLayers(LayerVisibility layers) => _send('setLayers', layers.toJson());

  Future<void> setViewMode(ViewMode mode) => _send('setViewMode', {'mode': mode == ViewMode.view2d ? '2d' : '3d'});

  Future<void> resetCamera() => _send('resetCamera');

  Future<void> faceNorth() => _send('faceNorth');

  /// Capture PNG de la scene (avec l'etiquette), renvoyee par onScreenshot.
  Future<Uint8List> screenshot({Duration timeout = const Duration(seconds: 8)}) {
    final id = _nextRequest++;
    final c = Completer<Uint8List>();
    _screenshots[id] = c;
    _send('screenshot', {'requestId': id});
    return c.future.timeout(timeout, onTimeout: () {
      _screenshots.remove(id);
      throw TimeoutException('Capture non recue');
    });
  }

  // ---- interne ----

  Future<void> _send(String type, [Map<String, dynamic> payload = const {}]) async {
    if (_disposed) return;
    final js = 'window.floodViewer && window.floodViewer.receive(${jsonEncode({'type': type, 'payload': payload})});';
    if (!isReady) {
      _pending.add(js);
      return;
    }
    try {
      await webView.runJavaScript(js);
    } catch (e) {
      _errors.add('runJavaScript: $e');
    }
  }

  void _onMessage(String raw) {
    final Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final p = (msg['payload'] as Map<String, dynamic>?) ?? const {};
    switch (msg['type']) {
      case 'onReady':
        if (!_ready.isCompleted) {
          _ready.complete();
          final queued = List.of(_pending);
          _pending.clear();
          for (final js in queued) {
            webView.runJavaScript(js);
          }
        }
      case 'onScenarioChange':
        _scenario.add(p['id'] as String);
      case 'onTimeChange':
        _time.add(TimeChange((p['index'] as num).toInt(), p['t'] as String?));
      case 'onCameraChange':
        _camera.add(CameraChange((p['heading'] as num).toDouble(), p['mode'] == '2d' ? ViewMode.view2d : ViewMode.view3d));
      case 'onScreenshot':
        final c = _screenshots.remove((p['requestId'] as num?)?.toInt());
        c?.complete(base64Decode(p['base64'] as String));
      case 'onError':
        debugPrint('[FloodViewer] ${p['message']}');
        _errors.add(p['message'] as String? ?? 'Erreur inconnue');
    }
  }

  void dispose() {
    _disposed = true;
    for (final c in [_scenario, _time, _camera, _errors]) {
      c.close();
    }
    for (final c in _screenshots.values) {
      c.completeError(StateError('Controleur ferme'));
    }
    _screenshots.clear();
  }
}
