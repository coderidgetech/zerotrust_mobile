import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/vpn_models.dart';

class VPNService {
  static const MethodChannel _channel = MethodChannel('com.zerovault.vpn/service');
  static const EventChannel _statusChannel = EventChannel('com.zerovault.vpn/status');
  static const EventChannel _statisticsChannel = EventChannel('com.zerovault.vpn/statistics');

  StreamSubscription<dynamic>? _statusSubscription;
  StreamSubscription<dynamic>? _statisticsSubscription;

  final StreamController<VPNConnectionStatus> _statusController = StreamController.broadcast();
  final StreamController<VPNStatistics> _statisticsController = StreamController.broadcast();

  Stream<VPNConnectionStatus> get statusStream => _statusController.stream;
  Stream<VPNStatistics> get statisticsStream => _statisticsController.stream;

  VPNService() {
    _initializeStreams();
  }

  void _initializeStreams() {
    // Listen to VPN status changes
    _statusSubscription = _statusChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        final status = _parseVPNStatus(event);
        _statusController.add(status);
      },
      onError: (error) {
        print('VPN Status Stream Error: $error');
      },
    );

    // Listen to VPN statistics updates
    _statisticsSubscription = _statisticsChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        final statistics = VPNStatistics.fromJson(Map<String, dynamic>.from(event));
        _statisticsController.add(statistics);
      },
      onError: (error) {
        print('VPN Statistics Stream Error: $error');
      },
    );
  }

  /// Establishes VPN connection with the provided configuration
  Future<bool> connect(VPNConfiguration config) async {
    try {
      final Map<String, dynamic> configMap = {
        'privateKey': config.privateKey,
        'publicKey': config.publicKey,
        'endpoint': config.endpoint,
        'allowedIPs': config.allowedIPs,
        'dns': config.dns,
        'mtu': config.mtu,
        'persistentKeepalive': config.persistentKeepalive,
      };

      final bool result = await _channel.invokeMethod('connect', configMap);
      return result;
    } catch (e) {
      print('VPN Connect Error: $e');
      return false;
    }
  }

  /// Disconnects the current VPN connection
  Future<bool> disconnect() async {
    try {
      final bool result = await _channel.invokeMethod('disconnect');
      return result;
    } catch (e) {
      print('VPN Disconnect Error: $e');
      return false;
    }
  }

  /// Gets the current VPN connection status
  Future<VPNConnectionStatus> getConnectionStatus() async {
    try {
      final String status = await _channel.invokeMethod('getStatus');
      return _parseVPNStatus(status);
    } catch (e) {
      print('Get VPN Status Error: $e');
      return VPNConnectionStatus.disconnected;
    }
  }

  /// Gets current VPN statistics (data usage, session time, etc.)
  Future<VPNStatistics?> getStatistics() async {
    try {
      final Map<dynamic, dynamic> stats = await _channel.invokeMethod('getStatistics');
      return VPNStatistics.fromJson(Map<String, dynamic>.from(stats));
    } catch (e) {
      print('Get VPN Statistics Error: $e');
      return null;
    }
  }

  /// Imports VPN configuration from QR code or config string
  Future<bool> importConfiguration(String configData) async {
    try {
      final bool result = await _channel.invokeMethod('importConfig', {'data': configData});
      return result;
    } catch (e) {
      print('Import Configuration Error: $e');
      return false;
    }
  }

  /// Checks if VPN permission is granted (Android)
  Future<bool> hasVPNPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('hasVPNPermission');
      return hasPermission;
    } catch (e) {
      print('Check VPN Permission Error: $e');
      return false;
    }
  }

  /// Requests VPN permission (Android)
  Future<bool> requestVPNPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestVPNPermission');
      return granted;
    } catch (e) {
      print('Request VPN Permission Error: $e');
      return false;
    }
  }

  /// Enables kill switch (blocks traffic when VPN disconnects)
  Future<bool> enableKillSwitch(bool enable) async {
    try {
      final bool result = await _channel.invokeMethod('enableKillSwitch', {'enable': enable});
      return result;
    } catch (e) {
      print('Kill Switch Error: $e');
      return false;
    }
  }

  /// Sets custom DNS servers
  Future<bool> setCustomDNS(List<String> dnsServers) async {
    try {
      final bool result = await _channel.invokeMethod('setCustomDNS', {'servers': dnsServers});
      return result;
    } catch (e) {
      print('Set Custom DNS Error: $e');
      return false;
    }
  }

  /// Gets the current IP address (both public and VPN)
  Future<Map<String, String>> getIPAddresses() async {
    try {
      final Map<dynamic, dynamic> addresses = await _channel.invokeMethod('getIPAddresses');
      return Map<String, String>.from(addresses);
    } catch (e) {
      print('Get IP Addresses Error: $e');
      return {'public': 'Unknown', 'vpn': 'Unknown'};
    }
  }

  /// Performs network connectivity test
  Future<Map<String, dynamic>> performConnectivityTest() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('connectivityTest');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Connectivity Test Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Gets detailed network interface information
  Future<List<Map<String, dynamic>>> getNetworkInterfaces() async {
    try {
      final List<dynamic> interfaces = await _channel.invokeMethod('getNetworkInterfaces');
      return interfaces.map((interface) => Map<String, dynamic>.from(interface)).toList();
    } catch (e) {
      print('Get Network Interfaces Error: $e');
      return [];
    }
  }

  /// Configures traffic routing rules
  Future<bool> configureRouting(Map<String, dynamic> routingConfig) async {
    try {
      final bool result = await _channel.invokeMethod('configureRouting', routingConfig);
      return result;
    } catch (e) {
      print('Configure Routing Error: $e');
      return false;
    }
  }

  /// Sets up split tunneling (exclude specific apps from VPN)
  Future<bool> configureSplitTunneling(List<String> excludedApps) async {
    try {
      final bool result = await _channel.invokeMethod('configureSplitTunneling', {'apps': excludedApps});
      return result;
    } catch (e) {
      print('Configure Split Tunneling Error: $e');
      return false;
    }
  }

  /// Monitors real-time traffic data
  Stream<Map<String, dynamic>> getTrafficMonitor() {
    return _statisticsChannel.receiveBroadcastStream('traffic').map(
      (event) => Map<String, dynamic>.from(event)
    );
  }

  /// Gets VPN server latency
  Future<int> measureLatency(String serverEndpoint) async {
    try {
      final int latency = await _channel.invokeMethod('measureLatency', {'endpoint': serverEndpoint});
      return latency;
    } catch (e) {
      print('Measure Latency Error: $e');
      return -1;
    }
  }

  /// Performs speed test through VPN
  Future<Map<String, double>> performSpeedTest() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('speedTest');
      return {
        'download': (result['download'] as num).toDouble(),
        'upload': (result['upload'] as num).toDouble(),
        'ping': (result['ping'] as num).toDouble(),
      };
    } catch (e) {
      print('Speed Test Error: $e');
      return {'download': 0.0, 'upload': 0.0, 'ping': 0.0};
    }
  }

  VPNConnectionStatus _parseVPNStatus(dynamic status) {
    switch (status.toString().toLowerCase()) {
      case 'connected':
        return VPNConnectionStatus.connected;
      case 'connecting':
        return VPNConnectionStatus.connecting;
      case 'disconnecting':
        return VPNConnectionStatus.disconnecting;
      case 'error':
        return VPNConnectionStatus.error;
      default:
        return VPNConnectionStatus.disconnected;
    }
  }

  void dispose() {
    _statusSubscription?.cancel();
    _statisticsSubscription?.cancel();
    _statusController.close();
    _statisticsController.close();
  }
}