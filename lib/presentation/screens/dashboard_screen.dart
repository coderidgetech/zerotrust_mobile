import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/vpn_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/models/vpn_models.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/dashboard_activity_card.dart';
import '../widgets/dashboard_security_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _metrics;
  List<Map<String, dynamic>>? _recentActivity;
  Map<String, dynamic>? _securityPosture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _apiService.getDashboardMetrics(),
        _apiService.getRecentActivity(),
        _apiService.getSecurityPosture(),
      ]);

      setState(() {
        _metrics = results[0] as Map<String, dynamic>?;
        _recentActivity = results[1] as List<Map<String, dynamic>>?;
        _securityPosture = results[2] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF3B82F6),
        backgroundColor: const Color(0xFF1E293B),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),

                    // VPN Quick Status
                    _buildVPNQuickStatus(),
                    const SizedBox(height: 24),

                    // Metrics Cards
                    if (_metrics != null) _buildMetricsGrid(),
                    const SizedBox(height: 24),

                    // Security Posture
                    if (_securityPosture != null)
                      DashboardSecurityCard(securityData: _securityPosture!),
                    const SizedBox(height: 24),

                    // Recent Activity
                    if (_recentActivity != null)
                      DashboardActivityCard(activities: _recentActivity!),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  user?.isAdmin == true ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      user?.fullName ?? user?.username ?? 'User',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.role.toUpperCase() ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVPNQuickStatus() {
    return Consumer<VPNProvider>(
      builder: (context, vpnProvider, child) {
        final isConnected = vpnProvider.connectionStatus == VPNConnectionStatus.connected;
        final selectedGateway = vpnProvider.selectedGateway;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/vpn');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isConnected 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFF374151),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isConnected ? const Color(0xFF10B981) : const Color(0xFF6B7280))
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isConnected ? Icons.shield : Icons.shield_outlined,
                    color: isConnected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'VPN Connected' : 'VPN Disconnected',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isConnected && selectedGateway != null
                            ? '${selectedGateway.location}, ${selectedGateway.country}'
                            : 'Tap to connect to secure network',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF6B7280),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardMetricCard(
          title: 'Active Users',
          value: _metrics!['activeUsers'].toString(),
          icon: Icons.people,
          color: const Color(0xFF3B82F6),
          trend: '+12%',
        ),
        DashboardMetricCard(
          title: 'Total Devices',
          value: _metrics!['totalDevices'].toString(),
          icon: Icons.devices,
          color: const Color(0xFF10B981),
          trend: '+5%',
        ),
        DashboardMetricCard(
          title: 'Active Policies',
          value: _metrics!['activePolicies'].toString(),
          icon: Icons.security,
          color: const Color(0xFF8B5CF6),
          trend: '0%',
        ),
        DashboardMetricCard(
          title: 'Compliance',
          value: '${_metrics!['complianceScore']}%',
          icon: Icons.verified_user,
          color: const Color(0xFFF59E0B),
          trend: '+3%',
        ),
      ],
    );
  }
}