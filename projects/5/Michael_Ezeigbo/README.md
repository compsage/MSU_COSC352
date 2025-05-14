Interactive Hello World with WebAssembly
Project Overview
This project implements an interactive "Hello World" application using WebAssembly (WASM) for the MSU COSC352 Project 5. It takes a user’s name, age, and repetition count via an HTML form, processes them in a Rust-based WASM module, and displays a repeated greeting ("Hello, [Name]. You are [Age] years old.") in the browser. The project uses Rust with wasm-pack for WASM compilation, HTML for the UI, and JavaScript for integration.
Project Structure
MSU_COSC352/projects/5/Michael_Ezeigbo/
├── src/
│   └── lib.rs          # Rust source code for WASM module
├── Cargo.toml          # Rust project configuration
├── index.html          # HTML UI with form
├── main.js             # JavaScript glue code
└── README.md           # This file

Prerequisites

Rust: Install via rustup.
wasm-pack: Install with cargo install wasm-pack.
Node.js: For running a local web server (e.g., http-server).
Browser: A modern web browser.

How to Compile and Run

Clone the Repository:git clone <repository-url>



