import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/air_quality_provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: Consumer<AirQualityProvider>(
        builder: (_, aq, __) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSection('Notifikasi', [
                _buildSliderTile(
                  title: 'Batas Notif AQI',
                  subtitle:
                      'Notifikasi saat AQI melampaui ${aq.notifThreshold}',
                  value: aq.notifThreshold.toDouble(),
                  min: 50,
                  max: 300,
                  divisions: 10,
                  activeColor: AqiColors.getLevelFromAqi(aq.notifThreshold).color,
                  onChanged: (v) => aq.setNotifThreshold(v.round()),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('Auto-Refresh', [
                _buildSliderTile(
                  title: 'Interval Refresh',
                  subtitle: 'Setiap ${aq.refreshIntervalMinutes} menit',
                  value: aq.refreshIntervalMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: AppTheme.accent,
                  onChanged: (v) => aq.setRefreshInterval(v.round()),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('Data & Cache', [
                _buildActionTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Hapus Cache',
                  subtitle: 'Hapus semua data yang tersimpan',
                  iconColor: AqiColors.tidakSehat,
                  onTap: () => _confirmClearCache(context, aq),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('Tentang', [
                _buildInfoTile('Aplikasi', AppConstants.appName),
                _buildInfoTile('Versi', '1.0.0'),
                _buildInfoTile('Pengembang', 'Dimas Alfa Pratama'),
                _buildInfoTile('Lisensi', 'Proprietary (Hak Cipta Dilindungi)'),
                _buildInfoTile('Privasi', 'Privasi Mutlak (Penyimpanan Lokal)'),
                _buildInfoTile('Sumber Data', 'Open-Meteo (open-meteo.com)'),
              ]),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: AppTheme.border,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.15),
              valueIndicatorColor: activeColor,
              valueIndicatorTextStyle: const TextStyle(
                fontFamily: 'Sora',
                color: AppTheme.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCache(
      BuildContext context, AirQualityProvider aq) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Cache?',
          style: TextStyle(
            fontFamily: 'Sora',
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Semua data yang tersimpan akan dihapus. Anda perlu koneksi internet untuk memuat data kembali.',
          style: TextStyle(
            fontFamily: 'Sora',
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(fontFamily: 'Sora', color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AqiColors.tidakSehat,
              foregroundColor: AppTheme.textPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await aq.clearCache();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cache berhasil dihapus.',
              style: TextStyle(fontFamily: 'Sora')),
        ),
      );
    }
  }
}

