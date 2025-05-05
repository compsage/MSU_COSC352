use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = WebAssembly, js_name = memory)]
    static memory: wasm_bindgen::JsValue;
}

#[wasm_bindgen]
pub fn get_memory() -> wasm_bindgen::JsValue {
    memory.clone()
}

#[wasm_bindgen]
pub fn greet(name: &str, age: u32, repeat: u32) -> String {
    let message = format!("Hello, {}. You are {} years old.\n", name, age);
    let mut output = String::with_capacity(message.len() * repeat as usize);
    for _ in 0..repeat {
        output.push_str(&message);
    }
    output
}
