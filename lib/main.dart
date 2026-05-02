// main.dart — Sovereign Aim Bot + Mesh Node (Phone = Floor Client)
import 'package:flutter/material.dart';
import 'dart:math';
import 'sovereign_vault.dart'; // your SovereignVault.dart file

void main() {
  runApp(const SovereignAimBotApp());
}

class SovereignAimBotApp extends StatelessWidget {
  const SovereignAimBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Aim Bot — Floor Client',
      theme: ThemeData.dark(),
      home: const AimBotScreen(),
    );
  }
}

class AimBotScreen extends StatefulWidget {
  const AimBotScreen({super.key});

  @override
  State<AimBotScreen> createState() => _AimBotScreenState();
}

class _AimBotScreenState extends State<AimBotScreen> {
  double stability = 0.0;
  double vitality = 0.0;
  bool isMeshNode = false;

  // Simulate phone sensor data (replace with real camera + IMU later)
  void _simulateSensorTick() async {
    final rawState = {
      "center_x": Random().nextDouble() * 640,
      "center_y": Random().nextDouble() * 480,
      "vitality": Random().nextDouble(),
    };

    await sovereignVault.storeState(rawState, purpose: "vision_target");

    final metric = await sovereignVault.computeMetric("aim_lock_stability");

    setState(() {
      stability = metric["stability_score"] ?? 0.0;
      vitality = rawState["vitality"] ?? 0.0;
    });
  }

  // Enable device as Floor mesh node
  void _enableMeshNode() async {
    await sovereignVault.enableMeshNodeMode();
    setState(() => isMeshNode = true);
    // Optional: run continuously as background node
    sovereignVault.runAsNode();
  }

  @override
  void initState() {
    super.initState();
    // Start sensor simulation
    Future.delayed(Duration.zero, _simulateSensorTick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sovereign Aim Bot — Floor Client")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Phone = Floor Client\n5.5 Pa Gravity Equilibrium Active",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            Text("Vitality: ${vitality.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 24, color: Colors.green)),
            const SizedBox(height: 20),
            Text("Stability: ${stability.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 24, color: Colors.cyan)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _simulateSensorTick,
              child: const Text("Simulate Sensor Tick (Real camera/IMU here)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isMeshNode ? null : _enableMeshNode,
              child: Text(isMeshNode ? "Mesh Node ACTIVE" : "Enable Floor Mesh Node Mode"),
            ),
            const SizedBox(height: 40),
            const Text("All raw data owned by Ch’anchyah Vault\n"
                "Only derived metrics used for control + mesh relay", 
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}