import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_mode.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200)),
            const SizedBox(height: 20),
        
            // Theme Settings
            const Text('Theme',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            SegmentedButton<AppThemeMode>(
              style: SegmentedButton.styleFrom(
                backgroundColor: customColors.glassBg,
                foregroundColor: customColors.textMuted,
                selectedForegroundColor: theme.colorScheme.onPrimary,
                selectedBackgroundColor: theme.colorScheme.primary,
                side: isDark
                    ? BorderSide(color: customColors.borderColor, width: 0.5)
                    : null,
              ),
              segments: AppThemeMode.values.map((mode) {
                return ButtonSegment<AppThemeMode>(
                  value: mode,
                  label: Text(mode.presentableName),
                );
              }).toList(),
              selected: {appProvider.themeMode},
              onSelectionChanged: (newSelection) {
                appProvider.changeThemeMode(newSelection.first);
              },
            ),
            const SizedBox(height: 30),
        
            // API Keys Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('Infura API Keys',
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.info_outline,
                          color: customColors.textMuted, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.3),
                          builder: (context) => const InfuraInfoDialog(),
                        );
                      },
                      tooltip: 'How to get an API key',
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: appProvider.addApiKey,
                  style: IconButton.styleFrom(
                    backgroundColor: customColors.glassBg,
                    side: BorderSide(color: customColors.borderColor),
                  ),
                ),
              ],
            ),
            Text(
              'Add your Infura API keys below. The app will cycle through them.',
              style: TextStyle(color: customColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),
        
            Expanded(
              child: ListView.builder(
                itemCount: appProvider.apiKeyControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: appProvider.apiKeyControllers[index],
                            onChanged: (value) =>
                                appProvider.updateAndSaveApiKeys(),
                            decoration: InputDecoration(
                              hintText: 'Enter Infura API Key',
                              filled: true,
                              fillColor: customColors.glassBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: customColors.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: customColors.borderColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => appProvider.removeApiKey(index),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.8),
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfuraInfoDialog extends StatelessWidget {
  const InfuraInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final customColors = theme.extension<CustomColors>()!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor:
            (isDark ? const Color(0xFF1F1F1F) : Colors.white).withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: customColors.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 10),
            Text('Getting an Infura API Key'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Infura is a service that provides access to the Ethereum network without needing to run your own node.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 15),
              Text('How to get a key:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _InfoStep(
                  index: 1,
                  text: 'Go to infura.io and create a free account.'),
              _InfoStep(
                  index: 2,
                  text: 'From your dashboard, click "CREATE NEW KEY".'),
              _InfoStep(
                  index: 3,
                  text:
                      'Select "Web3 API" as the network and give your key a name.'),
              _InfoStep(
                  index: 4,
                  text:
                      'Once created, you can see your "API KEY". Copy it.'),
              _InfoStep(index: 5, text: 'Paste the key into this application.'),
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

class _InfoStep extends StatelessWidget {
  final int index;
  final String text;
  const _InfoStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}