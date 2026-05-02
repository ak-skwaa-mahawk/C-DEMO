#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <pigpio.h>   // Real servo PWM (install with sudo apt install pigpio)

// === VAULT CLIENT SHIM (Floor-owned) ===
void vault_store_state(const char* purpose, const char* json_state);
double vault_compute_metric(const char* metric_name);

// === SERVO PWM CONTROL (Floor-mediated actuation) ===
void set_servo_angle(int pin, float angle) {
    // 50Hz PWM, 500-2500us pulse width for 0-180°
    if (angle < 0) angle = 0;
    if (angle > 180) angle = 180;
    int pulse_us = (int)(500 + (angle / 180.0) * 2000);
    gpioServo(pin, pulse_us);
    printf("[SERVO] Pin %d → %.1f° (pulse %dus)  (Floor command)\n", pin, angle, pulse_us);
}

// === HELPER FUNCTIONS (Floor-mediated) ===
void update_segment_state(float x, float y, float vitality) {
    char json[256];
    snprintf(json, sizeof(json),
             "{\"x\": %.3f, \"y\": %.3f, \"vitality\": %.3f, \"timestamp\": %ld}",
             x, y, vitality, time(NULL));
    vault_store_state("segment_state", json);
}

float get_stability(const char* metric) {
    double stability = vault_compute_metric(metric);
    return (float)stability;
}

int main() {
    if (gpioInitialise() < 0) {
        printf("pigpio initialization failed!\n");
        return 1;
    }

    int sensorPin = 7;     // digital sensor
    int servoPin  = 18;    // PWM servo pin (GPIO 18 is hardware PWM on Pi)

    pinMode(sensorPin, 0);  // INPUT
    // servoPin is automatically PWM when gpioServo is called

    printf("=== SOVEREIGN SEGMENT WALKER — Floor Client with Servo PWM ===\n");
    printf("All state + actuation owned by Ch’anchyah Vault (5.5 Pa gravity equilibrium)\n\n");

    for (int i = 0; i < 10; i++) {
        int sensor = digitalRead(sensorPin);

        // === VAULT STORE: Raw state captured inside the Floor ===
        char state_json[128];
        snprintf(state_json, sizeof(state_json),
                 "{\"cycle\":%d,\"sensor\":%d,\"timestamp\":%ld}",
                 i+1, sensor, time(NULL));
        vault_store_state("segment_sensor", state_json);

        // === VAULT COMPUTE: Only derived metric controls the servo ===
        float stability = get_stability("segment_stability");

        // Optional segment state update
        update_segment_state(12.5f + i, 45.3f - i * 0.5f, stability);

        printf("Cycle %d: Sensor = %d | Stability = %.4f → ", i+1, sensor, stability);

        if (sensor && stability > 0.8f) {
            set_servo_angle(servoPin, 120.0f);  // move forward
            printf("Servo MOVE (Floor-approved)\n");
        } else {
            set_servo_angle(servoPin, 60.0f);   // stop / retract
            printf("Servo STOP\n");
        }

        sleep(1);
    }

    gpioTerminate();  // clean shutdown
    printf("\n=== WALK COMPLETE — All state owned by the Floor ===\n");
    return 0;
}