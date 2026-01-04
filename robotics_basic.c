#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>  // For sleep

// Stub GPIO functions (simulate pins)
void pinMode(int pin, int mode) { printf("Pin %d mode set\n", pin); }
void digitalWrite(int pin, int value) { printf("Pin %d = %s\n", pin, value ? "HIGH" : "LOW"); }
int digitalRead(int pin) { return rand() % 2; }  // Simulate sensor

int main() {
    int sensorPin = 7;
    int motorPin = 8;
    
    pinMode(sensorPin, 0);  // INPUT
    pinMode(motorPin, 1);   // OUTPUT
    
    printf("Simple Robot Loop — Sensor → Motor\n");
    
    for (int i = 0; i < 10; i++) {
        int sensor = digitalRead(sensorPin);
        printf("Cycle %d: Sensor = %d → ", i+1, sensor);
        
        if (sensor) {
            digitalWrite(motorPin, 1);  // Obstacle → move
            printf("Motor ON\n");
        } else {
            digitalWrite(motorPin, 0);  // Clear → stop
            printf("Motor OFF\n");
        }
        
        sleep(1);
    }
    
    return 0;
}