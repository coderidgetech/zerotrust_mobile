import 'package:flutter/foundation.dart';
import '../models/vpn_models.dart';
import '../services/vpn_service.dart';
import '../services/api_service.dart';

class VPNProvider with ChangeNotifier {
  VPNConnectionStatus _connectionStatus = VPNConnectionStatus.disconnected;
  VPNGateway? _selectedGateway;
  List<VPNGateway> _gateways = [];
  VPNStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  VPNConnectionStatus get connectionStatus => _connectionStatus;
  VPNGateway? get selectedGateway => _selectedGateway;
  List<VPNGateway> get gateways => _gateways;
  VPNStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final VPNService _vpnService = VPNService();
  final ApiService _apiService = ApiService();

  VPNProvider() {
    _initializeVPN();
  }

  Future<void> _initializeVPN() async {
    await loadGateways();
    await checkConnectionStatus();
  }

  Future<void> loadGateways() async {
    _setLoading(true);
    
    try {
      _gateways = await _apiService.getVPNGateways();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load VPN gateways');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> connectToGateway(VPNGateway gateway) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Get VPN configuration from API
      final config = await _apiService.getVPNConfiguration(gateway.id);
      
      if (config != null) {
        // Connect using VPN service
        final success = await _vpnService.connect(config);
        
        if (success) {
          _connectionStatus = VPNConnectionStatus.connected;
          _selectedGateway = gateway;
          
          // Notify backend about connection
          await _apiService.notifyVPNConnection(gateway.id);
          
          // Start monitoring connection
          _startConnectionMonitoring();
        } else {
          _setError('Failed to establish VPN connection');
        }
      } else {
        _setError('Failed to get VPN configuration');
      }
    } catch (e) {
      _setError('VPN connection failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnect() async {
    _setLoading(true);
    
    try {
      await _vpnService.disconnect();
      
      if (_selectedGateway != null) {
        await _apiService.notifyVPNDisconnection(_selectedGateway!.id);
      }
      
      _connectionStatus = VPNConnectionStatus.disconnected;
      _selectedGateway = null;
      _statistics = null;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect VPN');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkConnectionStatus() async {
    try {
      final status = await _vpnService.getConnectionStatus();
      _connectionStatus = status;
      
      if (status == VPNConnectionStatus.connected) {
        _statistics = await _vpnService.getStatistics();
      }
      
      notifyListeners();
    } catch (e) {
      // Handle silently for status checks
    }
  }

  void _startConnectionMonitoring() {
    // Monitor connection every 5 seconds
    Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      if (_connectionStatus == VPNConnectionStatus.connected) {
        await checkConnectionStatus();
        
        // Update statistics
        try {
          _statistics = await _vpnService.getStatistics();
          notifyListeners();
        } catch (e) {
          // Handle silently
        }
      }
    });
  }

  Future<String?> generateQRCode(String platform) async {
    try {
      return await _apiService.generateVPNQRCode(platform);
    } catch (e) {
      _setError('Failed to generate QR code');
      return null;
    }
  }

  Future<bool> importConfigFromQR(String qrData) async {
    _setLoading(true);
    
    try {
      final success = await _vpnService.importConfiguration(qrData);
      if (success) {
        await loadGateways();
        return true;
      } else {
        _setError('Invalid QR code configuration');
        return false;
      }
    } catch (e) {
      _setError('Failed to import configuration');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshGateways() async {
    await loadGateways();
  }

  void selectGateway(VPNGateway gateway) {
    _selectedGateway = gateway;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}