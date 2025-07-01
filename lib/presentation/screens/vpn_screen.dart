import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/vpn_provider.dart';
import '../../core/models/vpn_models.dart';
import '../widgets/vpn_connection_card.dart';
import '../widgets/vpn_gateway_list.dart';
import '../widgets/vpn_statistics_card.dart';

class VPNScreen extends StatefulWidget {
  const VPNScreen({super.key});

  @override
  State<VPNScreen> createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VPNProvider>(context, listen: false).loadGateways();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'VPN Connection',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/qr-scanner');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<VPNProvider>(context, listen: false).refreshGateways();
            },
          ),
        ],
      ),
      body: Consumer<VPNProvider>(
        builder: (context, vpnProvider, child) {
          if (vpnProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await vpnProvider.refreshGateways();
            },
            color: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status Card
                  VPNConnectionCard(
                    status: vpnProvider.connectionStatus,
                    selectedGateway: vpnProvider.selectedGateway,
                    onConnect: (gateway) => _handleConnect(context, vpnProvider, gateway),
                    onDisconnect: () => _handleDisconnect(context, vpnProvider),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Card (when connected)
                  if (vpnProvider.connectionStatus == VPNConnectionStatus.connected && 
                      vpnProvider.statistics != null)
                    VPNStatisticsCard(statistics: vpnProvider.statistics!),

                  if (vpnProvider.connectionStatus == VPNConnectionStatus.connected && 
                      vpnProvider.statistics != null)
                    const SizedBox(height: 16),

                  // Gateway Selection
                  Text(
                    'Available Gateways',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (vpnProvider.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vpnProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  VPNGatewayList(
                    gateways: vpnProvider.gateways,
                    selectedGateway: vpnProvider.selectedGateway,
                    connectionStatus: vpnProvider.connectionStatus,
                    onGatewaySelected: (gateway) {
                      vpnProvider.selectGateway(gateway);
                    },
                    onConnect: (gateway) => _handleConnect(context, vpnProvider, gateway),
                  ),

                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR Code',
                  onTap: () {
                    Navigator.of(context).pushNamed('/qr-scanner');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: 'Import Config',
                  onTap: () {
                    _showImportDialog(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.speed,
                  label: 'Speed Test',
                  onTap: () {
                    _performSpeedTest(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.settings,
                  label: 'VPN Settings',
                  onTap: () {
                    _showVPNSettings(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4B5563)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConnect(BuildContext context, VPNProvider vpnProvider, VPNGateway gateway) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Connecting to VPN',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 16),
            Text(
              'Establishing secure connection to ${gateway.name}...',
              style: GoogleFonts.inter(color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    await vpnProvider.connectToGateway(gateway);
    
    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (vpnProvider.connectionStatus == VPNConnectionStatus.connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${gateway.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (vpnProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vpnProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDisconnect(BuildContext context, VPNProvider vpnProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Disconnect VPN',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to disconnect from the VPN?',
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Disconnect',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await vpnProvider.disconnect();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disconnected from VPN'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Import Configuration',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Choose how to import your VPN configuration:',
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/qr-scanner');
            },
            child: Text(
              'Scan QR Code',
              style: GoogleFonts.inter(color: const Color(0xFF3B82F6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement file picker
            },
            child: Text(
              'Choose File',
              style: GoogleFonts.inter(color: const Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _performSpeedTest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Speed test feature coming soon'),
        backgroundColor: Color(0xFF3B82F6),
      ),
    );
  }

  void _showVPNSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'VPN Settings',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.security, color: Color(0xFF3B82F6)),
              title: Text(
                'Kill Switch',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Block internet if VPN disconnects',
                style: GoogleFonts.inter(color: Colors.grey[400]),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement kill switch toggle
                },
                activeColor: const Color(0xFF3B82F6),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.autorenew, color: Color(0xFF3B82F6)),
              title: Text(
                'Auto Reconnect',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Automatically reconnect on failure',
                style: GoogleFonts.inter(color: Colors.grey[400]),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement auto reconnect toggle
                },
                activeColor: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: const Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}