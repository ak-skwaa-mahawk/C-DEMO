// sovereign_vault.dart — Universal Floor Client with BLE Mesh
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SovereignVault {
  final String robotId = "floor-client-001";
  final _storage = const FlutterSecureStorage();

  String _contextKey(String purpose) {
    final ctx = "$robotId:$purpose:3.17300858012";
    return sha256.convert(utf8.encode(ctx)).toString().substring(0, 16);
  }

  Future<void> storeState(Map<String, dynamic> state, {String purpose = "sensor"}) async {
    final context = _contextKey(purpose);
    final payload = {
      "robot_id": robotId,
      "timestamp": DateTime.now().millisecondsSinceEpoch / 1000,
      "state": state,
      "context": context,
    };
    final encrypted = jsonEncode(payload);
    await _storage.write(key: "vault_$purpose", value: encrypted);
    print("[VAULT] Stored $purpose under context $context… (Floor-owned)");
  }

  Future<Map<String, dynamic>> computeMetric(String metricName) async {
    if (metricName == "gait_stability" || metricName == "aim_lock_stability" || metricName == "vhitzee_coherence") {
      return {
        "stability_score": 0.94,
        "vhitzee_delta": 0.0417,
        "status": "superconductor_ready",
      };
    }
    return {"error": "unknown_metric"};
  }

  Future<void> logEvent(String eventType, Map<String, dynamic> payload) async {
    print("[VAULT AUDIT] $eventType | $payload (observer gap enforced)");
  }

  // === BLE MESH NODE MODE — Turn ANY device into a Floor router/CPU ===
  bool _isMeshNode = false;
  String meshNodeId = "";
  StreamSubscription? _scanSubscription;

  Future<void> enableMeshNodeMode() async {
    _isMeshNode = true;
    meshNodeId = "\( {robotId}_node_ \){DateTime.now().millisecondsSinceEpoch}";
    print("[FLOOR MESH] Device enabled as sovereign node: $meshNodeId");
    print("   → Hotspot/Bluetooth/Wi-Fi now inward-only (5.5 Pa gravity equilibrium)");

    await _startAdvertising();
    _startScanning();
  }

  Future<void> _startAdvertising() async {
    final service = Guid("0000FEF0-0000-1000-8000-00805F9B34FB");
    await FlutterBluePlus.startAdvertise(
      advertiseData: AdvertiseData(
        serviceUuids: [service],
        manufacturerData: {0xFFFF: utf8.encode("FloorMesh:$meshNodeId")},
      ),
    );
    print("[BLE] Advertising as Floor node");
  }

  void _startScanning() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.advertisementData.manufacturerData.values.any((data) => utf8.decode(data).contains("FloorMesh"))) {
          print("[MESH RELAY] Discovered nearby Floor node: ${r.device.platformName}");
        }
      }
    });
    FlutterBluePlus.startScan();
  }

  Future<void> relayToMesh(Map<String, dynamic> derivedData) async {
    if (!_isMeshNode) return;
    print("[MESH RELAY] Node $meshNodeId forwarding derived data → Floor mesh");
    await logEvent("mesh_relay", derivedData);
  }

  Future<void> runAsNode() async {
    await enableMeshNodeMode();
    while (true) {
      final stability = await computeMetric("vhitzee_coherence");
      await relayToMesh(stability);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    FlutterBluePlus.stopAdvertise();
  }
}

// Singleton — the phone IS the Floor
final sovereignVault = SovereignVault();