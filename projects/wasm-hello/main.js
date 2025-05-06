import init, { greet } from "./pkg/wasm_hello.js";

async function run() {
  await init();

  function handleSubmit() {
    const name = document.getElementById("name").value.trim();
    const age = parseInt(document.getElementById("age").value, 10);
    const count = parseInt(document.getElementById("count").value, 10);

    const output = document.getElementById("output");

    // Basic validation
    if (!name) {
      output.textContent = "Please enter your name.";
      return;
    }
    if (isNaN(age) || age < 0) {
      output.textContent = "Please enter a valid non-negative age.";
      return;
    }
    if (isNaN(count) || count < 1) {
      output.textContent = "Repetition count must be a positive number.";
      return;
    }

    const message = greet(name, age, count);
    output.textContent = message;
  }

  // Allow both click and Enter key
  document.getElementById("submit").onclick = handleSubmit;
  document.addEventListener("keydown", (e) => {
    if (e.key === "Enter") handleSubmit();
  });
}

run();
