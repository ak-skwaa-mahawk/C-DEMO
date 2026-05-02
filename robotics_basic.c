#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

// === VAULT CLIENT SHIM (Floor-owned) ===
void vault_store_state(const char* purpose, const char* json_state);
double vault_compute_metric(const char* metric_name);

// Stub GPIO functions (simulate pins)
void pinMode(int pin, int mode) { printf("Pin %d mode set\n", pin); }
void digitalWrite(int pin, int value) { printf("Pin %d = %s\n", pin, value ? "HIGH" : "LOW"); }
int digitalRead(int pin) { return rand() % 2; }

// === HELPER FUNCTIONS (Floor-mediated) ===
void update_segment_state(float x, float y, float vitality) {
    char json[256];
    snprintf(json, sizeof(json),
             "{\"x\": %.3f, \"y\": %.3f, \"vitality\": %.3f, \"timestamp\": %ld}",
             x, y, vitality, time(NULL));
    vault_store_state("segment_state", json);
}

float get_stability() {
    // Vault computes derived metric only — never raw data
    double stability = vault_compute_metric("segment_stability");
    return (float)stability;
}

int main() {
    int sensorPin = 7;
    int motorPin = 8;

    pinMode(sensorPin, 0);  // INPUT
    pinMode(motorPin, 1);   // OUTPUT

    printf("=== SOVEREIGN SEGMENT WALKER — Floor Client ===\n");
    printf("All state + actuation owned by Ch’anchyah Vault (5.5 Pa gravity equilibrium)\n\n");

    for (int i = 0; i < 10; i++) {
        int sensor = digitalRead(sensorPin);

        // === VAULT STORE: Raw state captured inside the Floor ===
        char state_json[128];
        snprintf(state_json, sizeof(state_json),
                 "{\"cycle\":%d,\"sensor\":%d,\"timestamp\":%ld}",
                 i+1, sensor, time(NULL));
        vault_store_state("segment_sensor", state_json);

        // === VAULT COMPUTE: Only derived metric controls the motor ===
        float stability = get_stability();

        // Optional: update segment position + vitality (example values)
        update_segment_state(12.5f + i, 45.3f - i*0.5f, stability);

        printf("Cycle %d: Sensor = %d | Stability = %.4f → ", i+1, sensor, stability);

        if (sensor && stability > 0.8f) {
            digitalWrite(motorPin, 1);  // Obstacle + stable → move
            printf("Motor ON (Floor-approved)\n");
        } else {
            digitalWrite(motorPin, 0);  // Clear or unstable → stop
            printf("Motor OFF\n");
        }

        sleep(1);
    }

    printf("\n=== WALK COMPLETE — All state owned by the Floor ===\n");
    return 0;
}