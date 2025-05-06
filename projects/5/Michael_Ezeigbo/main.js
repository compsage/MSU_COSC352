import init, { generate_greeting } from '../pkg/wasm_greeting.js';

async function run() {
    await init();

    document.getElementById("submit").onclick = () => {
        const name = document.getElementById("name").value;
        const age = parseInt(document.getElementById("age").value);
        const repeat = parseInt(document.getElementById("repeat").value);

        if (!name || isNaN(age) || isNaN(repeat) || repeat <= 0) {
            alert("Please enter valid input for all fields.");
            return;
        }

        const result = generate_greeting(name, age, repeat);
        document.getElementById("output").textContent = result;
    };
}

run();
