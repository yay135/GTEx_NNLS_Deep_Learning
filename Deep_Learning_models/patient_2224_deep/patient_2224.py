# 05/24/2023 Fengyao Yan 
# test the model on the patient 2224 sequence data using the model created in file decide_organ.py

import pickle
from numpy import NaN
import numpy as np
import pandas as pd
import tensorflow as tf
from decide_organ import df_master, model_name
from decide_organ import _gen_comp
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler

data_folder = '../../data/2224'
data_raw = '../../data/raw'
res_folder = 'patient_2224_v2'

# apply the mask from training
df_master_meta = df_master[['tissue', 'sample']]
df_master_gene = df_master.drop(columns=['tissue', 'sample'])
with open(f'{data_folder}/mask.pkl', 'rb') as f:
    mask = pickle.load(f)
df_master_gene = df_master_gene.iloc[:, mask]
_df_master = pd.concat((df_master_meta, df_master_gene), axis=1)

float_format = '{:.3f}'.format
np.set_printoptions(formatter={'float_kind':float_format})

df_2224 = pd.read_csv(f'{data_raw}/Pt2224cpm.tsv', delimiter='\t', index_col=0)

df_2224 += 1
df_2224 = df_2224.apply(np.log2)

name_to_id = pd.read_csv(f'{data_raw}/martquery_0503203624_374.txt')

comm_name = list(set(df_2224.index.to_list()).intersection(set(name_to_id['Gene name'].to_list())))

df_2224 = df_2224.loc[comm_name]

converted = [name_to_id.loc[name_to_id['Gene name']==name, 'Gene stable ID'].values[0] for name in df_2224.index]
df_2224.index = converted

df_comp, organs = _gen_comp(_df_master)

or_gens = df_comp.columns.values[len(organs):]
_2224_gens = set(df_2224.index.values.tolist())


data = []
num_overlap  = 0
for gen in or_gens:
    if gen is NaN or not gen in _2224_gens:
        data.append(np.array([0 for _ in range(df_2224.shape[1])]).reshape(-1, 1))
    else:
        num_overlap += 1
        data.append(df_2224.loc[gen, :].values.reshape(-1, 1))

data = np.concatenate(data, axis=1)

model = tf.keras.models.load_model(model_name)

scaler = MinMaxScaler()
X = scaler.fit_transform(data)

pred = model.predict(X)

df_res = pd.DataFrame(data=pred, columns=organs, index=None)

df_res.to_csv(f'./{data_folder}/{res_folder}/res_2224_dl.csv', index=False, float_format='{:.3f}'.format)

#plot
X_axis = np.arange(len(organs))
  
plt.bar(X_axis-0.25, pred[0,:], 0.2, label = '0 month')
plt.bar(X_axis, pred[1,:],0.2, label = '6 month')
plt.bar(X_axis+0.25, pred[2,:], 0.2, label = '9 month')
  
plt.xticks(X_axis, organs, rotation=35, ha='right')
plt.xlabel("tissue")
plt.ylabel("fractions")
plt.title("fractions over time for patient 2224")
plt.legend()
plt.show()
