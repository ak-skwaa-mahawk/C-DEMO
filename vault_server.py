from flask import Flask, request, jsonify
from sovereign_vault import SovereignVaultClient

vault = SovereignVaultClient()
app = Flask(__name__)

@app.post("/store/<purpose>")
def store_state(purpose):
    data = request.get_json(force=True)
    vault.store_state(data, purpose)
    return jsonify({"status": "ok"})

@app.get("/metric/<metric>")
def metric(metric):
    result = vault.compute_metric(metric)
    return jsonify(result)

app.run(port=7777)