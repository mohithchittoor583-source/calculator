import { useState } from "react";
import "./App.css";

const API_URL = "http://54.85.22.118:5000";

function App() {
  const [number1, setNumber1] = useState("");
  const [number2, setNumber2] = useState("");
  const [operation, setOperation] = useState("+");
  const [result, setResult] = useState(null);
  const [error, setError] = useState("");

  const calculate = async () => {
    setError("");
    setResult(null);

    if (number1 === "" || number2 === "") {
      setError("Please enter both numbers");
      return;
    }

    try {
      const response = await fetch(`${API_URL}/api/calculate`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          number1: Number(number1),
          operation: operation,
          number2: Number(number2),
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setError(data.error || "Calculation failed");
        return;
      }

      setResult(data.result);
    } catch (error) {
      console.error(error);
      setError("Unable to connect to backend");
    }
  };

  return (
    <div className="container">
      <div className="calculator">
        <h1>Calculator</h1>

        <input
          type="number"
          placeholder="Enter first number"
          value={number1}
          onChange={(e) => setNumber1(e.target.value)}
        />

        <select
          value={operation}
          onChange={(e) => setOperation(e.target.value)}
        >
          <option value="+">Addition (+)</option>
          <option value="-">Subtraction (-)</option>
          <option value="*">Multiplication (*)</option>
          <option value="/">Division (/)</option>
        </select>

        <input
          type="number"
          placeholder="Enter second number"
          value={number2}
          onChange={(e) => setNumber2(e.target.value)}
        />

        <button onClick={calculate}>
          Calculate
        </button>

        {result !== null && (
          <div className="result">
            Result: {result}
          </div>
        )}

        {error && (
          <div className="error">
            {error}
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
