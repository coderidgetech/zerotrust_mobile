import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSecurityCard extends StatelessWidget {
  final Map<String, dynamic> securityData;

  const DashboardSecurityCard({
    super.key,
    required this.securityData,
  });

  @override
  Widget build(BuildContext context) {
    final zeroTrustScore = securityData['zeroTrustScore'] as int? ?? 0;
    final deviceCompliance = securityData['deviceCompliance'] as int? ?? 0;
    final policyCompliance = securityData['policyCompliance'] as int? ?? 0;
    final threats = securityData['threatsBlocked'] as int? ?? 0;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getScoreColor(zeroTrustScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  color: _getScoreColor(zeroTrustScore),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Security Posture',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to security dashboard
                },
                child: Text(
                  'Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Zero Trust Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getScoreColor(zeroTrustScore).withOpacity(0.1),
                  _getScoreColor(zeroTrustScore).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getScoreColor(zeroTrustScore).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Zero Trust Score',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$zeroTrustScore/100',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(zeroTrustScore),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: zeroTrustScore / 100,
                  backgroundColor: const Color(0xFF374151),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(zeroTrustScore),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreDescription(zeroTrustScore),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Security Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.devices,
                  label: 'Device Compliance',
                  value: '$deviceCompliance%',
                  color: _getComplianceColor(deviceCompliance),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.policy,
                  label: 'Policy Compliance',
                  value: '$policyCompliance%',
                  color: _getComplianceColor(policyCompliance),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildMetricItem(
            icon: Icons.shield,
            label: 'Threats Blocked Today',
            value: threats.toString(),
            color: threats > 0 ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(8),
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFFF59E0B);
    if (score >= 50) return const Color(0xFFEF4444);
    return const Color(0xFFDC2626);
  }

  Color _getComplianceColor(int compliance) {
    if (compliance >= 90) return const Color(0xFF10B981);
    if (compliance >= 75) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getScoreDescription(int score) {
    if (score >= 85) return 'Excellent security posture';
    if (score >= 70) return 'Good security with room for improvement';
    if (score >= 50) return 'Moderate security - needs attention';
    return 'Poor security - immediate action required';
  }
}