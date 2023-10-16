import os
import json
import uvicorn
import datetime
import numpy as np
from fastapi import FastAPI
from apscheduler.schedulers.background import BackgroundScheduler

k_file = "./data/model.json"
X = json.loads('{"x": 0}')

def write_log(level, msg):
    formatted_message = '[{}] [{}] - {}'.format(datetime.datetime.now(), level, msg)
    print(formatted_message)

app = FastAPI()

def read_model():
    global X
    if os.path.exists(k_file):
        with open(k_file, 'r') as f:
            X = json.load(f)
        os.remove(k_file)
        write_log("Info", "New model")

scheduler = BackgroundScheduler()
scheduler.add_job(read_model, "interval", seconds=60)
scheduler.start()

@app.get("/api-test/check")
async def check():
    return {"date": datetime.datetime.now(), "value": np.asarray(np.sum(X["x"])).tolist()}

uvicorn.run(app, host="0.0.0.0", port=8003)
