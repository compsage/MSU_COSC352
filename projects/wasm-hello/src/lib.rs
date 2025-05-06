use wasm_bindgen::prelude::*;

/// Generate a repeated greeting message
#[wasm_bindgen]
pub fn greet(name: &str, age: u32, count: usize) -> String {
    let message = format!("Hello, {}. You are {} years old.\n", name, age);
    let mut result = String::with_capacity(message.len() * count);
    
    for _ in 0..count {
        result.push_str(&message);
    }

    result
}
