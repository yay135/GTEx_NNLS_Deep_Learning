#05/23/2023 Fengyao Yan
#Validation test on semi silico cmp data

import random
import numpy as np
import pandas as pd
from numpy import NaN
import tensorflow as tf
from sklearn.metrics import mean_squared_error
from scipy.stats import pearsonr
from gen_composition import gen_comp
from decide_organ import model_name, df_master
from sklearn.preprocessing import MinMaxScaler

# start sensitivity test by random mask genes 
is_sens_test = True

data_folder = '../../data/cmp'
res_folder = 'cmp_res'
data_raw = '../../data/raw'

mse_dat = {}
pearson_dat = {}
df_comp, ogs_all = None, None
if df_comp is None or ogs_all is None:
    df_comp, ogs_all = gen_comp(df=df_master)
n_ogs_all = len(ogs_all)
or_gens = df_comp.columns.values[n_ogs_all:]
folder = 'cmp_res_random_mask'
ogs = ['Brain', 'Breast', 'Colon', 'Kidney', 'Liver', 'Lung']
float_format = '{:.3f}'.format
np.set_printoptions(formatter={'float_kind':float_format})

# tissue_cmp process

df_cmp = pd.read_csv(f'{data_raw}/composition_cmp_05_05.csv')
print(f'max:{df_cmp.max().max()}')
y_true = df_cmp[ogs]
X = df_cmp.loc[:, [col for col in df_cmp.columns if not col in ogs]]
# log2 transform
X += 1
X = X.apply(np.log2)
cmp_gens = set(X.columns.to_list())

data_match = []
num_overlap  = 0
for gen in or_gens:
    if gen is NaN or not gen in cmp_gens:
        data_match.append(np.array([0.0 for _ in range(df_cmp.shape[0])]).reshape(-1, 1))
    else:
        num_overlap += 1
        data_match.append(X[gen].values.reshape(-1, 1))
data_match = np.concatenate(data_match, axis=1)

start = 2000 if is_sens_test else 5000

for after_mask in range(start, 5001, 500):

    data = np.copy(data_match)
    col_sum = np.sum(data, axis=0)
    non_zero_col = np.where(col_sum != 0)[0]
    sel_mask = random.sample(non_zero_col.tolist(), k=non_zero_col.shape[0]-after_mask if after_mask <= non_zero_col.shape[0] else 0)
    data[:, sel_mask] = 0
    model = tf.keras.models.load_model(model_name)

    scaler = MinMaxScaler()
    X = scaler.fit_transform(data)

    pred = model.predict(X)

    df_res = pd.DataFrame(data=pred, columns=ogs_all, index=None)
    y_true.to_csv(f'{data_folder}/{res_folder}/cmp_true.csv', index=False, float_format='{:.3f}'.format)
    df_res.to_csv(f'{data_folder}/{res_folder}/cmp_pred.csv', index=False, float_format='{:.3f}'.format)

    df_tissue = y_true

    pearson_mask = [pearsonr(df_res[og], df_tissue[og])[0] for og in ogs]
    mse_mask = [mean_squared_error(df_res[og], df_tissue[og]) for og in ogs]
    key = f'pearson_{after_mask}'
    pearson_dat[key] = pearson_mask

    key = f'mse_{after_mask}'
    mse_dat[key] = mse_mask

pearson_df = pd.DataFrame(data=pearson_dat, index=ogs)
mse_df = pd.DataFrame(data=mse_dat, index=ogs)

pearson_df = pearson_df.T
mse_df = mse_df.T

pearson_df.to_csv(f'{data_folder}/{res_folder}/pearson_all_cmp_deep.csv')
mse_df.to_csv(f'{data_folder}/{res_folder}/mse_all_cmp_deep.csv')