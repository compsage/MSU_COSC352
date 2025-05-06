use wasm_bindgen::prelude::*;

/// Generate a repeated greeting message.
#[wasm_bindgen]
pub fn generate_greeting(name: &str, age: u32, repeat: usize) -> String {
    let message = format!("Hello, {}. You are {} years old.\n", name, age);
    message.repeat(repeat)
}
