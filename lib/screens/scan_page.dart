import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../providers/app_provider.dart';
import '../core/theme/app_theme.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void _launchEtherscan(String address) async {
    final uri = Uri.parse('https://etherscan.io/address/$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final theme = Theme.of(context);

    final scanButton = ElevatedButton(
      onPressed: appProvider.isScanning ? appProvider.stopScanning : appProvider.startScanning,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Text(appProvider.isScanning ? 'Stop Scanning' : 'Start Scanning'),
    );

    final pageContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ETH Hunter', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200)),
            Row(
              children: [
                if (isMobile)
                  IconButton(
                    icon: Icon(Icons.bar_chart, color: customColors.textMuted),
                    tooltip: 'View Stats',
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withAlpha((255 * 0.3).round()),
                        builder: (_) => const _MobileStatsDialog(),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.history, color: customColors.textMuted),
                  tooltip: 'View Session History',
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withAlpha((255 * 0.3).round()),
                      builder: (_) => const _HistoryDialog(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Wallets to Scan:', style: TextStyle(color: customColors.textMuted)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  height: 40,
                  child: TextField(
                    controller: appProvider.walletsToScanController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: customColors.glassBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: customColors.borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: customColors.borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.primary)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.all_inclusive),
                        tooltip: "Set to Max",
                        onPressed: appProvider.setMaxWallets,
                        color: customColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!isMobile) scanButton,
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: customColors.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: customColors.borderColor),
            ),
            child: ListView.builder(
              controller: appProvider.scrollController,
              itemCount: appProvider.logs.length,
              itemBuilder: (context, index) {
                final log = appProvider.logs[index];
                final isWinner = log.balance > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText.rich(
                        TextSpan(
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400, height: 1.5),
                          children: [
                            TextSpan(text: 'Scan: ${log.totalScan} | ', style: TextStyle(color: customColors.textMuted)),
                            TextSpan(text: 'Winners: ${log.winnerCount} | ', style: TextStyle(color: customColors.green)),
                            TextSpan(text: 'Balance: ', style: TextStyle(color: customColors.textMuted)),
                            TextSpan(
                              text: '${log.balance.toStringAsFixed(6)} ETH\n',
                              style: TextStyle(color: isWinner ? customColors.green : customColors.red, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal),
                            ),
                            TextSpan(
                              text: log.address,
                              style: TextStyle(color: theme.colorScheme.primary),
                              recognizer: TapGestureRecognizer()..onTap = () => _launchEtherscan(log.address),
                            ),
                          ],
                        ),
                      ),
                      if (index < appProvider.logs.length - 1)
                        const Divider(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (isMobile) const SizedBox(height: 60), // Space for the floating button
      ],
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 8.0),
        child: isMobile
            ? Stack(
                children: [
                  pageContent,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: scanButton,
                    ),
                  )
                ],
              )
            : pageContent,
      ),
    );
  }
}

class _HistoryDialog extends StatelessWidget {
  const _HistoryDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final customColors = theme.extension<CustomColors>()!;
    final appProvider = context.watch<AppProvider>();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: (isDark ? const Color(0xFF1F1F1F) : Colors.white).withAlpha((255 * 0.85).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: customColors.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 10),
            Text('Session History'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Total Scanned', value: appProvider.totalScanned.toString()),
                  _StatItem(label: 'Total Winners', value: appProvider.totalWinners.toString(), valueColor: customColors.green),
                ],
              ),
              const Divider(height: 24),
              Text('Winners This Session (${appProvider.winners.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: appProvider.winners.isEmpty
                    ? Center(child: Text('No winners found in this session yet.', style: TextStyle(color: customColors.textMuted)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: appProvider.winners.length,
                        itemBuilder: (context, index) {
                          final winner = appProvider.winners[index];
                          return _WinnerCard(winner: winner);
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MobileStatsDialog extends StatelessWidget {
  const _MobileStatsDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final customColors = theme.extension<CustomColors>()!;
    final totalStats = context.select((AppProvider p) => p.getTotalStats());
    final appProvider = context.watch<AppProvider>();

    Color getProgressColor(double percentage) {
      if (percentage > 50) return customColors.green;
      if (percentage > 25) return customColors.yellow;
      if (percentage > 10) return customColors.orange;
      return customColors.red;
    }

    final progressColor = getProgressColor(totalStats.percentage);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: (isDark ? const Color(0xFF1F1F1F) : Colors.white).withAlpha((255 * 0.85).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: customColors.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.bar_chart),
            SizedBox(width: 10),
            Text('Stats'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatItem(label: 'Total Scanned', value: appProvider.totalScanned.toString()),
              const SizedBox(height: 8),
              _StatItem(label: 'Total Winners', value: appProvider.totalWinners.toString(), valueColor: customColors.green),
              const Divider(height: 24),
              const Text("Requests Left", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalStats.percentage / 100,
                backgroundColor: Colors.black.withAlpha((255 * 0.3).round()),
                color: progressColor,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "~${totalStats.remaining.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 12, color: customColors.textMuted, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: customColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final WinnerEntry winner;
  const _WinnerCard({required this.winner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: customColors.glassBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: customColors.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${winner.balance.toStringAsFixed(8)} ETH',
                    style: TextStyle(fontWeight: FontWeight.bold, color: customColors.green, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    winner.address,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: customColors.textMuted),
                  ),
                  SelectableText(
                    'PK: ${winner.privateKey}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: customColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy Private Key',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: winner.privateKey));
                context.read<AppProvider>().showToast('Private Key Copied!');
              },
            ),
          ],
        ),
      ),
    );
  }
}