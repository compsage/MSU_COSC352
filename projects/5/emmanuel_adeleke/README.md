# Hello WebAssembly (WASM)

This project demonstrates a complete flow of passing input data from HTML to a Rust-compiled WebAssembly module and displaying the results in the browser. The WebAssembly module returns a repeated greeting message based on user input.

## Features

- Input fields for name, age, and repeat count
- Efficient string repetition inside WebAssembly
- TailwindCSS-styled UI with Quicksand font
- Optional developer panel displaying live memory usage and FPS

---

## Data Path: HTML → JS → WASM → JS → HTML

1. **HTML Input:** The user enters:
   - Name (`<input type="text">`)
   - Age (`<input type="number">`)
   - Repeat Count (`<input type="number">`)

2. **JavaScript:**
   - On form submission, values are fetched via DOM.
   - JS calls the exported `greet(name, age, repeat)` function in the WASM module.
   - The result string is returned from Rust back to JS.

3. **WASM (Rust):**
   - `greet()` constructs a string message.
   - The message is repeated `repeat` times efficiently.
   - Rust returns the full result back to JS as a `String`.

4. **JS → HTML:**
   - The repeated message is placed in a `<pre>` element and displayed.

---

## Memory Handling

### String Passing (JS → WASM)
- JavaScript uses `TextEncoder` to convert strings into UTF-8 byte arrays.
- These bytes are copied into WASM memory using `wasm.__wbindgen_malloc`.
- WASM receives a pointer and a length to the UTF-8 string.

### String Return (WASM → JS)
- The `String` created in Rust is returned as a pointer and length.
- JavaScript uses `TextDecoder` to convert the raw bytes into a JS string.
- JS frees the memory afterward using `wasm.__wbindgen_free`.

### Accessing WebAssembly Memory
- Memory is imported into Rust using:

```rust
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = WebAssembly, js_name = memory)]
    static memory: wasm_bindgen::JsValue;
}
```

```
+------------------------+
| JS String ("John")     |
| Encoded (UTF-8)        |
+------------------------+
           ↓
+------------------------+
| WASM Memory Buffer     |
| [Ptr] ------> "John"   |
+------------------------+
           ↓
+------------------------+
| Rust `&str`            |
| format!() output       |
| repeated N times       |
+------------------------+
           ↓
+------------------------+
| Return [Ptr, Len]      |
| JS decodes result      |
+------------------------+
```

## How to Run (run with python `python3 -m http.server 8080`)

1. **Install live-server globally (if not already installed):**

   ```bash
   npm install -g live-server
   ```

2. **Build the Rust WASM package:**

   ```bash
   cd hello-wasm
   wasm-pack build --target web
   ```

3. **Go back to the root directory (with `index.html`) and run:**

   ```bash
   live-server .
   ```

4. **Open the browser at** `http://127.0.0.1:8080` **or wherever live-server launches.**

