# 05/23/2023 Fengyao Yan
# construct a deep learning model and train the model for tissue deconvolution.

import os
import pickle
import pandas as pd
import numpy as np
import random
import tensorflow as tf
from scipy.stats import pearsonr
from sklearn.preprocessing import MinMaxScaler
from sklearn.utils import shuffle
from gen_composition import gen_comp
from multiprocessing import Pool, cpu_count

cpu_count = 12
# whether to train use 6 tissue or 15 tissue
use_all_tissue = False
data_folder = '../../data/cmp'
data_raw = '../../data/raw'

ogs = ['Brain', 'Breast', 'Colon', 'Kidney', 'Liver', 'Lung']
master = f'{data_raw}/selected_gtex_top_1_NT_1_fc_3_data.csv'
df_master = pd.read_csv(master, low_memory=False)
# log2 transform
df_master_meta = df_master[['tissue', 'sample']]
df_master_gene = df_master.drop(columns=['tissue', 'sample'])

df_master_gene += 1
df_master_gene = df_master_gene.apply(np.log2)
df_master = pd.concat((df_master_meta, df_master_gene), axis=1)
if not use_all_tissue:
    sel = [t in ogs for t in df_master['tissue']]
    df_master = df_master.loc[sel, :]
repeat_comp = 30
model_name = f'{data_folder}/model_05_03_rpt_{repeat_comp}_cpm'

validation_on = True
repeat_comp_validation = 20
validation_run = 1

float_format = '{:.3f}'.format
np.set_printoptions(formatter={'float_kind':float_format})

def _gen_comp(df_master):
    return gen_comp(df=df_master)

def random_mask(val):
    return random.sample((0,1), counts=(6, 4), k=1)[0]*val

if __name__ == '__main__':

        organs = df_master['tissue'].value_counts().index.to_list()
        n_organs = len(organs)
        if not os.path.exists(model_name):

            dfs = []
            with Pool(cpu_count) as p:
                for res in p.imap(_gen_comp, [df_master for _ in range(repeat_comp)]):
                    dfs.append(res[0])
                    print(f'{len(dfs)}/{repeat_comp} added')

            df_gtex_comp = pd.concat(dfs, axis=0, ignore_index=True)

            X = df_gtex_comp.iloc[:, n_organs:].values
            y = df_gtex_comp.iloc[:, :n_organs].values
            scaler = MinMaxScaler()

            X = scaler.fit_transform(X)
            with open(f'{data_folder}/scaler.pkl', 'wb') as f:
                pickle.dump(scaler, f)
            X, y = shuffle(X, y)
            model = tf.keras.models.Sequential()
            model.add(tf.keras.Input(shape=(X.shape[1])))
            model.add(tf.keras.layers.Dense(512, activation='relu'))
            model.add(tf.keras.layers.Dense(n_organs, activation='softmax'))
            model.compile(
                loss = 'mean_squared_error', 
                optimizer = "adam",               
                        metrics = ['mean_absolute_error']
            )
            model.summary()
            callback = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)
            model.fit(X, y, batch_size=128, epochs=200, verbose=1, validation_split=0.1, callbacks=[callback])

            model.save(model_name)

        # validation 
        if validation_on:
            model = tf.keras.models.load_model(model_name)
            def get_y_true_pred_df():
                dfs = []
                with Pool(cpu_count) as p:
                    dfs = p.map(_gen_comp, [df_master for _ in range(repeat_comp_validation)])
                dfs_frame = [res[0] for res in dfs]
                df_vali = pd.concat(dfs_frame, axis=0, ignore_index=True)
                X = df_vali.values[:, n_organs:]
                y = df_vali.values[:, :n_organs]
                scaler = MinMaxScaler()
                X = scaler.fit_transform(X)
                y_pred = model.predict(X)
                y_true_df = df_vali.iloc[:, :n_organs]
                y_pred_df = pd.DataFrame(data=y_pred, columns=df_vali.iloc[:, :n_organs].columns)
                return y_true_df, y_pred_df

            y_true_dfs, y_pred_dfs = [],[]
            for i in range(validation_run):
                t, p = get_y_true_pred_df()
                y_true_dfs.append(t)
                y_pred_dfs.append(p)
            y_true_df = pd.concat(y_true_dfs, axis=0)
            y_pred_df = pd.concat(y_pred_dfs, axis=0)
            orgs = []
            pearson  = []
            for organ in y_true_df.columns.values:
                orgs.append(organ)
                pearson.append(pearsonr(y_true_df[organ].values, y_pred_df[organ].values)[0])
                print(f'{orgs[-1]}:{pearson[-1]}')
            pd.DataFrame(data=np.array(pearson).reshape(1, -1), columns=orgs, index=[0]).to_csv(f'{data_folder}/{master}_pearson_validation.csv', index=False)








