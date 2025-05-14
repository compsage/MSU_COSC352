use wasm_bindgen::prelude::*;

// Use wee_alloc as the global allocator for efficient memory management in WASM
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

/// Generate a repeated greeting message.
#[wasm_bindgen]
pub fn generate_greeting(name: &str, age: u32, repeat: usize) -> String {
    // Validate inputs to prevent empty names or zero repetitions
    if name.is_empty() || repeat == 0 {
        return String::new();
    }

    // Create the single greeting message
    let message = format!("Hello, {}. You are {} years old.\n", name, age);

    // Pre-allocate a String buffer with exact capacity to avoid reallocations
    let total_len = message.len() * repeat;
    let mut result = String::with_capacity(total_len);

    // Manually append the message `repeat` times
    for _ in 0..repeat {
        result.push_str(&message);
    }

    result
}
