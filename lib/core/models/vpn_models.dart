enum VPNConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

enum VPNProtocol {
  wireguard,
  openVPN,
  ikev2,
}

class VPNGateway {
  final int id;
  final String name;
  final String location;
  final String country;
  final int latency;
  final int load;
  final String status;
  final VPNProtocol protocol;
  final int capacity;
  final int currentUsers;
  final String endpoint;

  VPNGateway({
    required this.id,
    required this.name,
    required this.location,
    required this.country,
    required this.latency,
    required this.load,
    required this.status,
    required this.protocol,
    required this.capacity,
    required this.currentUsers,
    required this.endpoint,
  });

  factory VPNGateway.fromJson(Map<String, dynamic> json) {
    return VPNGateway(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      country: json['country'],
      latency: json['latency'],
      load: json['load'],
      status: json['status'],
      protocol: _parseProtocol(json['protocol']),
      capacity: json['capacity'],
      currentUsers: json['currentUsers'],
      endpoint: json['endpoint'] ?? '',
    );
  }

  static VPNProtocol _parseProtocol(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'wireguard':
        return VPNProtocol.wireguard;
      case 'openvpn':
        return VPNProtocol.openVPN;
      case 'ikev2':
        return VPNProtocol.ikev2;
      default:
        return VPNProtocol.wireguard;
    }
  }

  bool get isOnline => status == 'online';
  double get loadPercentage => load / 100.0;
  double get utilizationPercentage => currentUsers / capacity;
  
  String get protocolName {
    switch (protocol) {
      case VPNProtocol.wireguard:
        return 'WireGuard';
      case VPNProtocol.openVPN:
        return 'OpenVPN';
      case VPNProtocol.ikev2:
        return 'IKEv2';
    }
  }
}

class VPNConfiguration {
  final String privateKey;
  final String publicKey;
  final String endpoint;
  final String allowedIPs;
  final String dns;
  final int mtu;
  final int persistentKeepalive;

  VPNConfiguration({
    required this.privateKey,
    required this.publicKey,
    required this.endpoint,
    required this.allowedIPs,
    required this.dns,
    required this.mtu,
    required this.persistentKeepalive,
  });

  factory VPNConfiguration.fromJson(Map<String, dynamic> json) {
    return VPNConfiguration(
      privateKey: json['privateKey'],
      publicKey: json['publicKey'],
      endpoint: json['endpoint'],
      allowedIPs: json['allowedIPs'],
      dns: json['dns'],
      mtu: json['mtu'] ?? 1420,
      persistentKeepalive: json['persistentKeepalive'] ?? 25,
    );
  }

  String toWireGuardConfig() {
    return '''
[Interface]
PrivateKey = $privateKey
Address = 10.8.0.2/24
DNS = $dns
MTU = $mtu

[Peer]
PublicKey = $publicKey
Endpoint = $endpoint
AllowedIPs = $allowedIPs
PersistentKeepalive = $persistentKeepalive
''';
  }
}

class VPNStatistics {
  final int bytesIn;
  final int bytesOut;
  final Duration sessionDuration;
  final String publicIP;
  final String virtualIP;
  final DateTime connectedAt;

  VPNStatistics({
    required this.bytesIn,
    required this.bytesOut,
    required this.sessionDuration,
    required this.publicIP,
    required this.virtualIP,
    required this.connectedAt,
  });

  factory VPNStatistics.fromJson(Map<String, dynamic> json) {
    return VPNStatistics(
      bytesIn: json['bytesIn'],
      bytesOut: json['bytesOut'],
      sessionDuration: Duration(seconds: json['sessionDuration']),
      publicIP: json['publicIP'],
      virtualIP: json['virtualIP'],
      connectedAt: DateTime.parse(json['connectedAt']),
    );
  }

  String get formattedBytesIn => _formatBytes(bytesIn);
  String get formattedBytesOut => _formatBytes(bytesOut);
  String get formattedDuration => _formatDuration(sessionDuration);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}