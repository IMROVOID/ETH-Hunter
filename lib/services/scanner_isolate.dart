import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// This is the entry point for the new isolate.
void scannerIsolateEntry(Map<String, dynamic> context) async {
  final port = context['port'] as SendPort;
  final apiKeys = context['apiKeys'] as List<String>;
  final walletsToScan = context['walletsToScan'] as int;
  final savePath = context['savePath'] as String;

  if (apiKeys.isEmpty) {
    port.send({'status': 'finished'});
    return;
  }

  int currentApiKeyIndex = 0;
  var client = Web3Client('https://mainnet.infura.io/v3/${apiKeys[currentApiKeyIndex]}', Client());

  int z = 1;
  int winners = 0;
  final random = Random.secure();
  final Map<String, int> apiKeyUsage = {};

  while (z <= walletsToScan) {
    try {
      final privateKey = EthPrivateKey.createRandom(random);
      final address = privateKey.address;
      
      final balance = await client.getBalance(address);
      final ethBalance = balance.getInWei / BigInt.from(10).pow(18);

      final activeKey = apiKeys[currentApiKeyIndex];
      apiKeyUsage[activeKey] = (apiKeyUsage[activeKey] ?? 0) + 1;

      final logMessage = {
        'totalScan': z,
        'winnerCount': winners,
        'address': address.hexEip55,
        'balance': ethBalance,
      };

      if (ethBalance > 0) {
        winners++;
        final winnerFile = File('$savePath/winner.txt');
        // MODIFICATION: The 'privateKey' getter returns a Uint8List, which is passed to the existing helper function.
        final privateKeyHex = bytesToHex(privateKey.privateKey);
        // Add private key to the message map to send back to the provider
        logMessage['privateKey'] = privateKeyHex;
        
        final content = '''
Address: ${address.hexEip55}
Private Key: $privateKeyHex
Balance: $ethBalance ETH
============================================================
''';
        await winnerFile.writeAsString(content, mode: FileMode.append);
      }

      port.send({'log': logMessage});
      port.send({'apiKeyUsage': apiKeyUsage});

      z++;
    } catch (e) {
      // Switch API key on error
      currentApiKeyIndex = (currentApiKeyIndex + 1) % apiKeys.length;
      client = Web3Client('https://mainnet.infura.io/v3/${apiKeys[currentApiKeyIndex]}', Client());
      await Future.delayed(const Duration(seconds: 1)); // Wait a bit before retrying
    }
  }

  await client.dispose();
  port.send({'status': 'finished'});
}

// Helper to convert byte array to hex string
String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}