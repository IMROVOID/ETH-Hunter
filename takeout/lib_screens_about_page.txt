import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final bodyTextStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    const titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w200);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- App Info ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/app.png',
                height: 64,
                width: 64,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline, size: 64),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ETH Hunter',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
                  ),
                  Row(
                    children: [
                      Text(
                        appProvider.appVersion,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: theme.textTheme.bodySmall?.color
                                ?.withAlpha((255 * 0.6).round())),
                      ),
                      const SizedBox(width: 8),
                      // **MODIFICATION**: Update check UI is now dynamic
                      Consumer<AppProvider>(
                        builder: (context, app, child) {
                          if (app.isCheckingForUpdate) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (app.isUpdateAvailable) {
                            return ElevatedButton.icon(
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Download Update'),
                              onPressed: () => _launchURL(app.latestVersionUrl),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.colorScheme.onPrimary,
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            );
                          }

                          return TextButton(
                            onPressed: () =>
                                app.checkForUpdate(showToastOnSuccess: true),
                            child: const Text('Check for updates'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Explanation ---
          const Text('About the App', style: titleStyle),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: bodyTextStyle,
              children: const [
                TextSpan(
                  text:
                      'ETH Hunter is a conceptual application designed to explore the vast address space of the Ethereum blockchain. It operates by programmatically generating a valid private key, deriving its corresponding public wallet address, and then checking that address\'s balance using the Infura API. ',
                ),
                TextSpan(
                  text:
                      'The entire scanning process is performed in a separate Isolate to ensure the user interface remains smooth and responsive. While it is theoretically possible to find a wallet with a balance, the sheer number of possible addresses makes this a statistically improbable event.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- License ---
          const Text('License & Contribution', style: titleStyle),
          const SizedBox(height: 10),
          Text(
            'This application is open-source and distributed freely. You are welcome to fork the project, explore the code, and contribute to its development for any purpose.',
            style: bodyTextStyle,
          ),
          const SizedBox(height: 24),

          // --- Developer ---
          const Text('About the Developer', style: titleStyle),
          const SizedBox(height: 10),
          Text(
            "I'm a passionate professional from Iran specializing in Graphic Design, Web Development, and cross-platform app development with Dart & Flutter. I thrive on turning innovative ideas into reality, whether it's a stunning visual, a responsive website, or a polished desktop app like this one. I also develop immersive games using Unreal Engine.",
            style: bodyTextStyle,
          ),
          const SizedBox(height: 24),

          // --- Social Media ---
          const Text('Social Media', style: titleStyle),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _SocialButton(
                  assetPath: 'assets/icons/social-media/website.svg',
                  onTap: () => _launchURL('https://rovoid.ir')),
              _SocialButton(
                  assetPath: 'assets/icons/social-media/github.svg',
                  onTap: () => _launchURL('https://github.com/IMROVOID')),
              _SocialButton(
                  assetPath: 'assets/icons/social-media/linktree.svg',
                  onTap: () => _launchURL('https://linktr.ee/ROVOID')),
              _SocialButton(
                  assetPath: 'assets/icons/social-media/linkedin.svg',
                  onTap: () => _launchURL(
                      'https://www.linkedin.com/in/roham-andarzgouu/')),
              _SocialButton(
                  assetPath: 'assets/icons/social-media/telegram.svg',
                  onTap: () => _launchURL('https://t.me/rovoid_dev')),
              _SocialButton(
                  assetPath: 'assets/icons/social-media/discord.svg',
                  onTap: () =>
                      _launchURL('https://discord.com/invite/TuEpzZNgbZ')),
            ],
          ),
          const SizedBox(height: 24),

          // --- Donations ---
          const Text('Donate', style: titleStyle),
          const SizedBox(height: 10),
          Text(
            'If you find this project useful, please consider a donation. As I am based in Iran, cryptocurrency is the only way I can receive support. Thank you!',
            style: bodyTextStyle,
          ),
          const SizedBox(height: 15),
          const _DonationAddress(
              name: 'Bitcoin',
              address: 'bc1qd35yqx3xt28dy6fd87xzd62cj7ch35p68ep3p8'),
          const _DonationAddress(
              name: 'Ethereum (ETH)',
              address: '0xA39Dfd80309e881cF1464dDb00cF0a17bF0322e3'),
          const _DonationAddress(
              name: 'USDT (TRC20)',
              address: 'THMe6FdXkA2Pw45yKaXBHRnkX3fjyKCzfy'),
          const _DonationAddress(
              name: 'Solana',
              address: '9QZHMTN4Pu6BCxiN2yABEcR3P4sXtBjkog9GXNxWbav1'),
          const _DonationAddress(
              name: 'TON',
              address: 'UQCp0OawnofpZTNZk-69wlqIx_wQpzKBgDpxY2JK5iynh3mC'),
          const SizedBox(height: 60), // Space for toast to appear
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        assetPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary, BlendMode.srcIn),
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DonationAddress extends StatelessWidget {
  final String name;
  final String address;

  const _DonationAddress({required this.name, required this.address});

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
                    name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    address,
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: customColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy Address',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address));
                context
                    .read<AppProvider>()
                    .showToast('$name Address Copied!');
              },
            ),
          ],
        ),
      ),
    );
  }
}