import subprocess
import os

task = os.getenv("RUN_TYPE")

if task is None:
    print("ERROR: no run task selected.")

if task == "single_t":
    os.chdir("Deep_Learning_models/single_tissue_predict_deep/")
    subprocess.run(["python", "run_predict.py"])

if task == "deconvolute":
    os.chdir("Deep_Learning_models/gtex_deep/")
    subprocess.run(["python", "deconvolute.py"])