from flask import Flask, request, jsonify
import random
import time
import os
import psycopg2
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)

# Prometheus Metrics
REQUEST_COUNT = Counter(
    'payment_requests_total',
    'Total payment requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'payment_request_latency_seconds',
    'Payment request latency'
)

# Database connection (Primary DB)
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "postgres"),
        database=os.getenv("DB_NAME", "payments"),
        user=os.getenv("DB_USER", "payuser"),
        password=os.getenv("DB_PASSWORD", "paypass"),
        port=5432
    )

@app.route("/pay", methods=["POST"])
@REQUEST_LATENCY.time()
def process_payment():
    amount = request.json.get("amount")

    if not amount:
        REQUEST_COUNT.labels("POST", "/pay", "400").inc()
        return jsonify({"error": "Amount is required"}), 400

    # Simulate payment processing delay
    time.sleep(random.uniform(0.1, 0.5))

    status = random.choice(["SUCCESS", "FAILED"])

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO transactions (amount, status) VALUES (%s, %s)",
            (amount, status)
        )
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        REQUEST_COUNT.labels("POST", "/pay", "500").inc()
        return jsonify({"error": "Database error", "details": str(e)}), 500

    REQUEST_COUNT.labels("POST", "/pay", "200").inc()
    return jsonify({
        "message": "Payment processed",
        "status": status
    }), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "UP"}), 200


@app.route("/metrics")
def metrics():
    return generate_latest(), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)