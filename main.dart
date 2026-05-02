// In main.dart or AimBotScreen
@override
void initState() {
  super.initState();
  sovereignPulse.start(); // Start the 79.79 Hz heartbeat
}

@override
void dispose() {
  sovereignPulse.stop();
  super.dispose();
}