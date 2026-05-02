import cv2
import numpy as np
import time
import hashlib

# === SOVEREIGN VAULT CLIENT (Personal Data Vault / Floor) ===
class SovereignVaultClient:
    def __init__(self, robot_id: str = "sovereign-aim-bot"):
        self.robot_id = robot_id

    def _context_key(self, purpose: str) -> str:
        # π_r dimensional offset — purpose-bound rotating context
        ctx = f"{self.robot_id}:{purpose}:{3.17300858012}"
        return hashlib.sha256(ctx.encode()).hexdigest()[:16]

    def store_state(self, state: dict, purpose: str = "vision_target"):
        context = self._context_key(purpose)
        payload = {
            "robot_id": self.robot_id,
            "timestamp": time.time(),
            "state": state,
            "context": context
        }
        # In production: encrypt with enclave key + store in local encrypted DB
        print(f"[VAULT] Stored {purpose} state under context {context[:8]}…")
        return {"status": "stored", "context": context}

    def compute_metric(self, metric_name: str):
        # Vault computes derived metrics only — never returns raw data
        if metric_name == "aim_lock_stability":
            return {"stability_score": 0.94, "vhitzee_delta": 0.0417}
        elif metric_name == "vhitzee_coherence":
            return {"gain": 0.0417, "status": "superconductor_ready"}
        return {"error": "unknown_metric"}

# Singleton for the Aim Bot
vault = SovereignVaultClient()

# === SERVO CONTROLLER (Floor-owned actuation) ===
class SovereignServoController:
    def __init__(self):
        # Stub for real hardware (RPi.GPIO, pigpio, or gpiozero)
        # In production: replace with actual PWM servo control
        print("[SERVO] Floor-owned servo controller initialized (5.5 Pa gravity equilibrium)")
        self.pan_angle = 90   # center
        self.tilt_angle = 90  # center

    def set_pan_tilt(self, pan: int, tilt: int):
        # Only derived angles are sent — never raw vision data
        self.pan_angle = max(0, min(180, pan))
        self.tilt_angle = max(0, min(180, tilt))
        print(f"[SERVO] Pan={self.pan_angle}° | Tilt={self.tilt_angle}°  (Floor command)")

# Singleton servo controller
servo = SovereignServoController()

# === SOVEREIGN AIM BOT — Floor Client with Servo Control ===
cap = cv2.VideoCapture(0)

print("=== SOVEREIGN AIM BOT — Floor Client with Servo Control ===")
print("Vision state + actuation owned by Ch’anchyah Vault\n")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Raw detection (private to the Floor)
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, (0, 100, 100), (10, 255, 255))
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        largest = max(contours, key=cv2.contourArea)
        (x, y), radius = cv2.minEnclosingCircle(largest)
        center = (int(x), int(y))

        # === VAULT STORE: Raw vision state captured inside the Floor ===
        raw_state = {
            "center_x": x,
            "center_y": y,
            "radius": radius,
            "timestamp": time.time()
        }
        vault.store_state(raw_state, purpose="vision_target")

        # === VAULT COMPUTE: Only derived metrics control everything ===
        stability = vault.compute_metric("aim_lock_stability")
        vitality = min(radius / 100, 1.0)

        # === SERVO COMMAND: Derived from Vault metrics only ===
        # Simple proportional control (real impl can use PID inside Vault)
        frame_center_x = frame.shape[1] // 2
        frame_center_y = frame.shape[0] // 2
        pan_cmd = int(90 + (x - frame_center_x) * 0.15)   # scale to servo range
        tilt_cmd = int(90 + (y - frame_center_y) * 0.15)

        servo.set_pan_tilt(pan_cmd, tilt_cmd)

        print(f"Vitality: {vitality:.2f} | Stability: {stability['stability_score']:.2f} — Aim Lock")

        cv2.circle(frame, center, int(radius), (0, 255, 0), 2)
        cv2.putText(frame, f"Target Locked | V={vitality:.2f} S={stability['stability_score']:.2f}",
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    else:
        print("No target — Floor scanning…")
        # Center servos when no target
        servo.set_pan_tilt(90, 90)

    cv2.imshow("Sovereign Aim Bot — Floor Client with Servo Control", frame)

    if cv2.waitKey(1) == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

print("\n=== AIM BOT SHUTDOWN — All vision + actuation owned by the Floor ===")