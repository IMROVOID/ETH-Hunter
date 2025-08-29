import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_provider.dart';

class SidebarStatsWidget extends StatelessWidget {
  final bool isMinimized;
  const SidebarStatsWidget({super.key, required this.isMinimized});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final totalStats = context.select((AppProvider p) => p.getTotalStats());
    final appProvider = context.watch<AppProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color getProgressColor(double percentage) {
      if (percentage > 50) return customColors.green;
      if (percentage > 25) return customColors.yellow;
      if (percentage > 10) return customColors.orange;
      return customColors.red;
    }

    final progressColor = getProgressColor(totalStats.percentage);
    final progressIndicator = LinearProgressIndicator(
      value: totalStats.percentage / 100,
      backgroundColor: Colors.black.withOpacity(0.3),
      color: progressColor,
      borderRadius: BorderRadius.circular(5),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: customColors.borderColor),
      ),
      child: isMinimized
          ? SizedBox(
              height: 100,
              child: RotatedBox(
                quarterTurns: 3,
                child: Tooltip(
                  message:
                      "Requests Left: ~${totalStats.remaining.toStringAsFixed(0)}",
                  child: progressIndicator,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow("Scanned:", appProvider.totalScanned.toString(),
                    customColors.textMuted, isLight),
                const SizedBox(height: 4),
                _buildStatRow("Winners:", appProvider.totalWinners.toString(),
                    customColors.green, isLight),
                const Divider(height: 16),
                Text("Requests Left",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isLight ? FontWeight.w500 : FontWeight.w400)),
                const SizedBox(height: 8),
                progressIndicator,
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "~${totalStats.remaining.toStringAsFixed(0)}",
                    style: TextStyle(
                        fontSize: 11,
                        color: customColors.textMuted,
                        fontWeight:
                            isLight ? FontWeight.w300 : FontWeight.w200),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatRow(
      String label, String value, Color valueColor, bool isLight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isLight ? FontWeight.w300 : FontWeight.w200)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isLight ? FontWeight.w500 : FontWeight.w400,
                color: valueColor)),
      ],
    );
  }
}