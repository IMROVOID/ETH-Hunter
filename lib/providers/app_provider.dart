import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart'; // MODIFICATION: Import the package
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme_mode.dart';
import '../services/scanner_isolate.dart';

// Data models
class LogEntry {
  final int totalScan;
  final int winnerCount;
  final String address;
  final double balance;
  LogEntry(
      {required this.totalScan,
      required this.winnerCount,
      required this.address,
      required this.balance});
}

class WinnerEntry {
  final String address;
  final String privateKey;
  final double balance;
  WinnerEntry(
      {required this.address,
      required this.privateKey,
      required this.balance});
}

class ApiKeyStats {
  final String key;
  final int remaining;
  final int limit;
  double get percentage => limit > 0 ? (remaining / limit) * 100 : 0;
  ApiKeyStats(
      {required this.key, required this.remaining, required this.limit});
}

class TotalStats {
  final int remaining;
  final int limit;
  double get percentage => limit > 0 ? (remaining / limit) * 100 : 0;
  TotalStats({required this.remaining, required this.limit});
}

// Enum for toast types
enum ToastType { info, error }

// The main state management class
class AppProvider with ChangeNotifier {
  // --- App Info ---
  // MODIFICATION: Changed from a hardcoded string to a variable that will be loaded.
  String appVersion = "v0.0.0"; 
  static const int infuraDailyLimit = 3000000;
  final String executableDirectory;

  // --- Theme State ---
  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  // --- Persistent Stats ---
  int totalScanned = 0;
  int totalWinners = 0;

  // --- Session State ---
  bool isScanning = false;
  List<LogEntry> logs = [];
  List<WinnerEntry> winners = [];
  List<ApiKeyStats> apiKeyStats = [];
  List<TextEditingController> apiKeyControllers = [];
  Map<String, int> _apiKeyUsage = {};
  Isolate? _scannerIsolate;
  final ScrollController scrollController = ScrollController();
  final TextEditingController walletsToScanController =
      TextEditingController(text: '1000');

  // --- Toast State ---
  String _toastMessage = '';
  String get toastMessage => _toastMessage;
  bool _isToastVisible = false;
  bool get isToastVisible => _isToastVisible;
  ToastType _toastType = ToastType.info;
  ToastType get toastType => _toastType;
  Timer? _toastTimer;

  // --- Update State ---
  bool isUpdateAvailable = false;
  bool isCheckingForUpdate = false;
  String latestVersionUrl = '';

  AppProvider({required this.executableDirectory}) {
    // MODIFICATION: Load all initial data in a single async method.
    _initializeApp();
  }

  // MODIFICATION: New method to load app info and settings.
  Future<void> _initializeApp() async {
    await _loadAppInfo();
    await _loadSettings();
    checkForUpdate(); // Check silently on startup
  }

  // MODIFICATION: New method to load the version from the package.
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = 'v${packageInfo.version}';
      notifyListeners(); // Notify listeners in case the UI is already built
    } catch (e) {
      debugPrint("Failed to get package info: $e");
      appVersion = "v?.?.?"; // Fallback version
      notifyListeners();
    }
  }

  /// Compares two version strings (e.g., "v1.2.3"). Returns true if remoteVersion is newer.
  bool _isNewerVersion(String remoteVersion, String localVersion) {
    try {
      // Clean up strings by removing 'v' prefix
      final remoteClean = remoteVersion.startsWith('v')
          ? remoteVersion.substring(1)
          : remoteVersion;
      final localClean =
          localVersion.startsWith('v') ? localVersion.substring(1) : localVersion;

      final remoteParts = remoteClean.split('.').map(int.parse).toList();
      final localParts = localClean.split('.').map(int.parse).toList();

      // Get the maximum length to iterate over
      final maxLength =
          remoteParts.length > localParts.length ? remoteParts.length : localParts.length;

      for (int i = 0; i < maxLength; i++) {
        final remotePart = (i < remoteParts.length) ? remoteParts[i] : 0;
        final localPart = (i < localParts.length) ? localParts[i] : 0;

        if (remotePart > localPart) {
          return true;
        }
        if (remotePart < localPart) {
          return false;
        }
      }
      // If all parts are equal, it's not a newer version
      return false;
    } catch (e) {
      debugPrint("Version comparison error: $e");
      return false; // Fail safe
    }
  }

  // --- Update Check ---
  Future<void> checkForUpdate({bool showToastOnSuccess = false}) async {
    if (isCheckingForUpdate) return;
    isCheckingForUpdate = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
          'https://api.github.com/repos/IMROVOID/ETH-Hunter/releases/latest');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final remoteVersion = data['tag_name'] as String;
        final releaseUrl = data['html_url'] as String;

        if (_isNewerVersion(remoteVersion, appVersion)) {
          isUpdateAvailable = true;
          latestVersionUrl = releaseUrl;
          if (showToastOnSuccess) {
            showToast('A new version ($remoteVersion) is available!');
          }
        } else {
          isUpdateAvailable = false;
          latestVersionUrl = '';
          if (showToastOnSuccess) {
            showToast('You are on the latest version.');
          }
        }
      } else {
        if (showToastOnSuccess) {
          showToast('Failed to check for updates.', type: ToastType.error);
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
      if (showToastOnSuccess) {
        showToast('Failed to check for updates.', type: ToastType.error);
      }
    } finally {
      isCheckingForUpdate = false;
      notifyListeners();
    }
  }

  // --- Toast Management ---
  void showToast(String message, {ToastType type = ToastType.info}) {
    _toastMessage = message;
    _toastType = type;
    _isToastVisible = true;
    notifyListeners();

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      _isToastVisible = false;
      notifyListeners();
    });
  }

  // --- Theme Management ---
  Future<void> changeThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  // --- Settings & Stats Management ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeName = prefs.getString('theme_mode');
    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => AppThemeMode.system,
    );

    // Load Persistent Stats
    totalScanned = prefs.getInt('totalScanned') ?? 0;
    totalWinners = prefs.getInt('totalWinners') ?? 0;

    // Load API Keys
    final keys = prefs.getStringList('api_keys') ?? [];
    apiKeyControllers =
        keys.map((key) => TextEditingController(text: key)).toList();
    if (apiKeyControllers.isEmpty) {
      apiKeyControllers.add(TextEditingController());
    }
    _updateStats();
    notifyListeners();
  }

  Future<void> _savePersistentStat(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> updateAndSaveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = apiKeyControllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    await prefs.setStringList('api_keys', keys);
    _updateStats();
    notifyListeners();
  }

  void addApiKey() {
    apiKeyControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeApiKey(int index) {
    if (apiKeyControllers.length > 1) {
      apiKeyControllers[index].dispose();
      apiKeyControllers.removeAt(index);
    } else {
      apiKeyControllers[index].clear();
    }
    updateAndSaveApiKeys();
  }

  void _updateStats() {
    // This updates the per-key stats for the current session
    final keys = apiKeyControllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    apiKeyStats = keys.map((key) {
      final used = _apiKeyUsage[key] ?? 0;
      final remaining = infuraDailyLimit - used;
      final displayKey = key.length > 8
          ? '${key.substring(0, 4)}....${key.substring(key.length - 4)}'
          : key;
      return ApiKeyStats(
          key: displayKey, remaining: remaining, limit: infuraDailyLimit);
    }).toList();
  }

  TotalStats getTotalStats() {
    int totalRemaining = 0;
    int totalLimit = 0;
    apiKeyControllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .forEach((key) {
      totalRemaining += infuraDailyLimit - (_apiKeyUsage[key] ?? 0);
      totalLimit += infuraDailyLimit;
    });
    return TotalStats(remaining: totalRemaining, limit: totalLimit);
  }

  void setMaxWallets() {
    walletsToScanController.text = getTotalStats().remaining.toString();
    notifyListeners();
  }

  // --- Scanning Logic ---
  Future<void> startScanning() async {
    if (isScanning) return;

    final keys = apiKeyControllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    if (keys.isEmpty) {
      showToast("Please set your Infura API Key first", type: ToastType.error);
      return;
    }

    logs.clear();
    winners.clear();
    isScanning = true;
    notifyListeners();

    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final walletsToScan = int.tryParse(walletsToScanController.text) ?? 0;

    _scannerIsolate = await Isolate.spawn(
      scannerIsolateEntry,
      {
        'port': receivePort.sendPort,
        'apiKeys': keys,
        'walletsToScan': walletsToScan,
        'savePath': executableDirectory,
      },
      onError: errorPort.sendPort,
      onExit: errorPort.sendPort,
    );

    receivePort.listen((message) {
      if (message is Map) {
        if (message.containsKey('log')) {
          final logData = message['log'];
          final isWinner = (logData['balance'] as double) > 0;

          // Update and save persistent stats
          totalScanned++;
          _savePersistentStat('totalScanned', totalScanned);

          if (isWinner) {
            totalWinners++;
            _savePersistentStat('totalWinners', totalWinners);
            winners.add(WinnerEntry(
              address: logData['address'],
              privateKey: logData['privateKey'],
              balance: logData['balance'],
            ));
          }

          logs.add(LogEntry(
            totalScan: logData['totalScan'],
            winnerCount: logData['winnerCount'],
            address: logData['address'],
            balance: logData['balance'],
          ));

          if (scrollController.hasClients) {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        } else if (message.containsKey('apiKeyUsage')) {
          _apiKeyUsage = Map<String, int>.from(message['apiKeyUsage']);
          _updateStats();
        } else if (message.containsKey('status') &&
            message['status'] == 'finished') {
          stopScanning();
        }
        notifyListeners();
      }
    });

    errorPort.listen((error) {
      debugPrint("Isolate Error/Exit: $error");
      // Only show the error toast if the scanning was not
      // intentionally stopped by the user.
      if (isScanning) {
        showToast("An error occurred during scanning.", type: ToastType.error);
      }
      stopScanning();
    });
  }

  void stopScanning() {
    // This check prevents redundant calls if stop is triggered from multiple places.
    if (!isScanning && _scannerIsolate == null) return;

    isScanning = false;
    _scannerIsolate?.kill(priority: Isolate.immediate);
    _scannerIsolate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopScanning();
    _toastTimer?.cancel();
    for (var controller in apiKeyControllers) {
      controller.dispose();
    }
    scrollController.dispose();
    walletsToScanController.dispose();
    super.dispose();
  }
}