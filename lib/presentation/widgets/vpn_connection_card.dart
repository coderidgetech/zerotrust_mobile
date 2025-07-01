import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/vpn_models.dart';

class VPNConnectionCard extends StatelessWidget {
  final VPNConnectionStatus status;
  final VPNGateway? selectedGateway;
  final Function(VPNGateway) onConnect;
  final VoidCallback onDisconnect;

  const VPNConnectionCard({
    super.key,
    required this.status,
    this.selectedGateway,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Status Text
          Text(
            _getStatusText(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Gateway Info
          if (selectedGateway != null)
            Text(
              selectedGateway!.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          
          if (selectedGateway != null)
            Text(
              '${selectedGateway!.location}, ${selectedGateway!.country}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _getStatusColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _getButtonText(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case VPNConnectionStatus.connecting:
      case VPNConnectionStatus.disconnecting:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case VPNConnectionStatus.error:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        );
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return const Color(0xFF10B981);
      case VPNConnectionStatus.connecting:
      case VPNConnectionStatus.disconnecting:
        return const Color(0xFFF59E0B);
      case VPNConnectionStatus.error:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return Icons.shield;
      case VPNConnectionStatus.connecting:
      case VPNConnectionStatus.disconnecting:
        return Icons.sync;
      case VPNConnectionStatus.error:
        return Icons.error_outline;
      default:
        return Icons.shield_outlined;
    }
  }

  String _getStatusText() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return 'Connected';
      case VPNConnectionStatus.connecting:
        return 'Connecting...';
      case VPNConnectionStatus.disconnecting:
        return 'Disconnecting...';
      case VPNConnectionStatus.error:
        return 'Connection Error';
      default:
        return 'Disconnected';
    }
  }

  String _getButtonText() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return 'Disconnect';
      case VPNConnectionStatus.connecting:
      case VPNConnectionStatus.disconnecting:
        return 'Please Wait...';
      default:
        return selectedGateway != null ? 'Connect' : 'Select Gateway';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (status) {
      case VPNConnectionStatus.connected:
        return onDisconnect;
      case VPNConnectionStatus.connecting:
      case VPNConnectionStatus.disconnecting:
        return null;
      default:
        return selectedGateway != null ? () => onConnect(selectedGateway!) : null;
    }
  }
}