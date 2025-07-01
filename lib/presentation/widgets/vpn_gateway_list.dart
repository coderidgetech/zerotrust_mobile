import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/vpn_models.dart';

class VPNGatewayList extends StatelessWidget {
  final List<VPNGateway> gateways;
  final VPNGateway? selectedGateway;
  final VPNConnectionStatus connectionStatus;
  final Function(VPNGateway) onGatewaySelected;
  final Function(VPNGateway) onConnect;

  const VPNGatewayList({
    super.key,
    required this.gateways,
    this.selectedGateway,
    required this.connectionStatus,
    required this.onGatewaySelected,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    if (gateways.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF374151)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              'No Gateways Available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or check your connection',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gateways.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gateway = gateways[index];
        final isSelected = selectedGateway?.id == gateway.id;
        final isConnectedToThis = connectionStatus == VPNConnectionStatus.connected && isSelected;

        return GestureDetector(
          onTap: () => onGatewaySelected(gateway),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF374151),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Gateway Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(gateway.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getProtocolIcon(gateway.protocol),
                        color: _getStatusColor(gateway.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Gateway Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  gateway.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isConnectedToThis)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'CONNECTED',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${gateway.location}, ${gateway.country}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(gateway.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Gateway Details
                Row(
                  children: [
                    _buildDetailChip(
                      icon: Icons.speed,
                      label: '${gateway.latency}ms',
                      color: _getLatencyColor(gateway.latency),
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      icon: Icons.people,
                      label: '${gateway.currentUsers}/${gateway.capacity}',
                      color: _getLoadColor(gateway.load),
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      icon: Icons.security,
                      label: gateway.protocolName,
                      color: const Color(0xFF3B82F6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Load Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Server Load',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '${gateway.load}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getLoadColor(gateway.load),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: gateway.loadPercentage,
                      backgroundColor: const Color(0xFF374151),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getLoadColor(gateway.load),
                      ),
                    ),
                  ],
                ),
                
                if (isSelected && connectionStatus == VPNConnectionStatus.disconnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: gateway.isOnline ? () => onConnect(gateway) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          gateway.isOnline ? 'Connect' : 'Unavailable',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProtocolIcon(VPNProtocol protocol) {
    switch (protocol) {
      case VPNProtocol.wireguard:
        return Icons.bolt;
      case VPNProtocol.openVPN:
        return Icons.vpn_lock;
      case VPNProtocol.ikev2:
        return Icons.security;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return const Color(0xFF10B981);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      case 'offline':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getLatencyColor(int latency) {
    if (latency < 50) return const Color(0xFF10B981);
    if (latency < 100) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getLoadColor(int load) {
    if (load < 50) return const Color(0xFF10B981);
    if (load < 80) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}