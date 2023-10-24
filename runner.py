import subprocess
import os

task = os.getenv("RUN_TYPE")

if len(os.listdir("/app")) == 0:
    print("ERROR: not csv files found in the data folder.")
    exit(1)

if task is None:
    print("ERROR: no run task selected.")
    exit(1)

if task == "single_t":
    os.chdir("Deep_Learning_models/single_tissue_predict_deep/")
    subprocess.run(["python", "run_predict.py"])

if task == "deconvolute":
    os.chdir("Deep_Learning_models/gtex_deep/")
    subprocess.run(["python", "deconvolute.py"])