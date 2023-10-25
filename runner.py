import subprocess
import os

task = os.getenv("RUN_TYPE")

if len(list(filter(lambda x:x.endswith(".csv"), os.listdir("/app")))) == 0:
    print("ERROR: no csv files found in the data folder. Make sure you are in the csv files folder when running the commands.")
    exit(1)

if task is None or task not in [ "single_t", "deconvolute_deep", "deconvolute_nnls"]:
    print("ERROR: no run task selected. please set RUN_type=[single_t|deconvolute_deep|deconvolute_nnls]")
    exit(1)

if task == "single_t":
    os.chdir("Deep_Learning_models/single_tissue_predict_deep/")
    subprocess.run(["python", "run_predict.py"])

if task == "deconvolute_deep":
    os.chdir("Deep_Learning_models/gtex_deep/")
    subprocess.run(["python", "deconvolute.py"])

if task == "deconvolute_nnls":
    os.chdir("NNLS_models/gtex_nnls/")
    subprocess.run(["Rscript", "deconvolute_custom.R"])