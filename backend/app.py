from flask import Flask, request, jsonify
from flask_cors import CORS

from db import get_db_connection

app = Flask(__name__)

CORS(app)


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({
        "message": "Calculator Backend is running"
    })


@app.route("/api/calculate", methods=["POST"])
def calculate():

    try:

        data = request.get_json()

        number1 = float(data["number1"])
        operation = data["operation"]
        number2 = float(data["number2"])

        if operation == "+":
            result = number1 + number2

        elif operation == "-":
            result = number1 - number2

        elif operation == "*":
            result = number1 * number2

        elif operation == "/":

            if number2 == 0:
                return jsonify({
                    "error": "Cannot divide by zero"
                }), 400

            result = number1 / number2

        else:
            return jsonify({
                "error": "Invalid operation"
            }), 400

        connection = get_db_connection()

        cursor = connection.cursor()

        query = """
        INSERT INTO calculations
        (number1, operation, number2, result)
        VALUES (%s, %s, %s, %s)
        """

        values = (
            number1,
            operation,
            number2,
            result
        )

        cursor.execute(query, values)

        connection.commit()

        cursor.close()

        connection.close()

        return jsonify({
            "number1": number1,
            "operation": operation,
            "number2": number2,
            "result": result
        })

    except Exception as e:

        return jsonify({
            "error": str(e)
        }), 500


@app.route("/api/history", methods=["GET"])
def get_history():

    try:

        connection = get_db_connection()

        cursor = connection.cursor(dictionary=True)

        query = """
        SELECT
            id,
            number1,
            operation,
            number2,
            result,
            created_at
        FROM calculations
        ORDER BY id DESC
        """

        cursor.execute(query)

        history = cursor.fetchall()

        cursor.close()

        connection.close()

        return jsonify(history)

    except Exception as e:

        return jsonify({
            "error": str(e)
        }), 500


@app.route("/api/history/<int:id>", methods=["DELETE"])
def delete_calculation(id):

    try:

        connection = get_db_connection()

        cursor = connection.cursor()

        query = """
        DELETE FROM calculations
        WHERE id = %s
        """

        cursor.execute(query, (id,))

        connection.commit()

        cursor.close()

        connection.close()

        return jsonify({
            "message": "Calculation deleted successfully"
        })

    except Exception as e:

        return jsonify({
            "error": str(e)
        }), 500


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )