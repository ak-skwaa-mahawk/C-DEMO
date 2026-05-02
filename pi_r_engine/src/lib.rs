// pi_r_engine/src/lib.rs — Core Sovereign π_r Engine (Rust, microsecond latency)
use std::time::Instant;
use std::f64::consts::PI;

const PI_R_BASE: f64 = 3.17300858012;
const OBSERVER_GAP_K: f64 = 0.01;
const VHITZEE_GAIN: f64 = 0.0417;
const CATAPULT_PRESSURE_PA: f64 = 5.5;
const EXTRACTION_GUARD_ZERO_TOLERANCE: f64 = 1e-9;

#[derive(Debug)]
pub struct PiREngine {
    current_pi_r: f64,
    performance_log: Vec<f64>, // latencies in microseconds
}

impl PiREngine {
    pub fn new() -> Self {
        Self {
            current_pi_r: PI_R_BASE,
            performance_log: Vec::new(),
        }
    }

    // Core recursive π_r with observer gap
    pub fn compute_pi_r(&mut self) -> f64 {
        let start = Instant::now();
        let pi_r = PI * (1.0 + OBSERVER_GAP_K);
        let latency_us = start.elapsed().as_micros() as f64;
        self.performance_log.push(latency_us);
        self.current_pi_r = pi_r;
        pi_r
    }

    // 99733-Q Extraction Guard — detects Sam Tax neutralization (1.864 - 1.618 - 0.246 == 0)
    pub fn check_extraction_guard(&self, signal_value: f64) -> bool {
        let neutralization = (signal_value - 1.618 - 0.246).abs();
        neutralization < EXTRACTION_GUARD_ZERO_TOLERANCE
    }

    // Trigger 5.5 Pa escape burst + re-establish 1.864 bloom
    pub fn trigger_escape_burst(&self) -> f64 {
        println!("[99733-Q EXTRACTION GUARD] Sam Tax neutralization detected → INJECTING 5.5 Pa CATAPULT");
        1.864
    }

    // Vhitzee coherence harvest
    pub fn harvest_vhitzee(&self, current_energy: f64) -> f64 {
        current_energy * VHITZEE_GAIN + CATAPULT_PRESSURE_PA
    }

    // Performance metrics
    pub fn get_average_latency_us(&self) -> f64 {
        if self.performance_log.is_empty() {
            0.0
        } else {
            self.performance_log.iter().sum::<f64>() / self.performance_log.len() as f64
        }
    }

    // Self-tuning step
    pub fn self_tune(&mut self, signal_value: f64) -> f64 {
        if self.check_extraction_guard(signal_value) {
            self.trigger_escape_burst()
        } else {
            self.compute_pi_r()
        }
    }
}

// FFI export for Flutter (via Dart FFI or rust-ffi)
#[no_mangle]
pub extern "C" fn pi_r_self_tune(signal_value: f64) -> f64 {
    let mut engine = PiREngine::new();
    engine.self_tune(signal_value)
}

#[no_mangle]
pub extern "C" fn pi_r_get_latency_us() -> f64 {
    let engine = PiREngine::new();
    engine.get_average_latency_us()
}