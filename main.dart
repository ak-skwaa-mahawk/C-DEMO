// Inside AimBotScreen class
class _AimBotScreenState extends State<AimBotScreen>
    with SingleTickerProviderStateMixin {
  // ... existing variables
  late AnimationController _bloomController;
  double bloomPiR = 3.17300858012; // current value from Rust

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // fast 5.5 Pa burst
    );
    sovereignPulse.onBloom = _triggerBloom; // callback from pulse
    _initializeCamera();
  }

  void _triggerBloom(double piRValue) {
    setState(() => bloomPiR = piRValue);
    _bloomController.forward(from: 0.0); // fire Bloom
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing appBar and camera preview
      body: Stack(
        children: [
          // Camera preview (existing)
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!),

          // Bloom overlay
          AnimatedBuilder(
            animation: _bloomController,
            builder: (context, child) {
              return CustomPaint(
                painter: BloomPainter(
                  progress: _bloomController.value,
                  piRValue: bloomPiR,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Existing UI metrics and buttons...
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bloomController.dispose();
    super.dispose();
  }
}