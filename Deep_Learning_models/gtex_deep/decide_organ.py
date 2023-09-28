# 05/23/2023 Fengyao Yan
# Construct and train a deep learning model for tissue deconvolution and test the model on semi silico gtex data.

import os
import pickle
import random
import pandas as pd
import numpy as np
import tensorflow as tf
from scipy.stats import pearsonr
from sklearn.preprocessing import MinMaxScaler
from sklearn.utils import shuffle
from gen_composition import gen_comp
from sklearn.metrics import mean_squared_error
from multiprocessing import Pool, cpu_count

cpu_count = 6
data_folder = '../../data/gtex'
data_raw = '../../data/raw'
master = f'{data_raw}/selected_gtex_top_1_NT_1_fc_3_data.csv'
df_master = pd.read_csv(master, low_memory=False)
is_sens_test = True
df_master_meta = df_master[['tissue', 'sample']]
df_master_gene = df_master.drop(columns=['tissue', 'sample'])
df_master_gene += 1
df_master_gene = df_master_gene.apply(np.log2)
df_master = pd.concat((df_master_meta, df_master_gene), axis=1)
repeat_comp = 20
model_name = f'{data_folder}/model_05_03_rpt_{repeat_comp}'
validation_on = True
repeat_comp_validation = 20

float_format = '{:.3f}'.format
np.set_printoptions(formatter={'float_kind':float_format})

def _gen_comp(df_master):
    return gen_comp(df=df_master)

if __name__ == '__main__':

    mse_dat = {}
    pearson_dat = {}
    validation_set = None
    start = 2000 if is_sens_test else 6000
    for after_mask in range(start, 6001, 500):
        print(f'after masking {after_mask} ...')
        organs = df_master['tissue'].value_counts().index.to_list()
        n_organs = len(organs)
        if not os.path.exists(model_name):
            dfs = []
            with Pool(cpu_count) as p:
                for res in p.imap(_gen_comp, [df_master for _ in range(repeat_comp)]):
                    dfs.append(res[0])
                    print(f'{len(dfs)}/{repeat_comp} added')
            df_gtex_comp = pd.concat(dfs, axis=0, ignore_index=True)
            print(f'df shape:{df_gtex_comp.shape}')

            X = df_gtex_comp.iloc[:, n_organs:].values
            y = df_gtex_comp.iloc[:, :n_organs].values
            print(f'xshape:{X.shape}')
            print(f'yshape:{y.shape}')
            scaler = MinMaxScaler()

            X = scaler.fit_transform(X)
            with open(f'{data_folder}/scaler.pkl', 'wb') as f:
                pickle.dump(scaler, f)
            X, y = shuffle(X, y)
            model = tf.keras.models.Sequential()
            model.add(tf.keras.Input(shape=(X.shape[1])))
            model.add(tf.keras.layers.Dense(48, activation='relu'))
            model.add(tf.keras.layers.Dense(n_organs, activation='softmax'))
            model.compile(
                loss = 'mean_squared_error', 
                optimizer = "adam",               
                        metrics = ['mean_absolute_error']
            )
            model.summary()
            callback = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
            model.fit(X, y, batch_size=64, epochs=200, verbose=1, validation_split=0.1, callbacks=[callback])
            model.save(model_name)

        # validation 
        if validation_on:
            model = tf.keras.models.load_model(model_name)
            def get_y_true_pred_df():
                global validation_set
                if validation_set is None:
                    dfs = []
                    with Pool(cpu_count) as p:
                        for res in p.imap(_gen_comp, [df_master for _ in range(repeat_comp_validation)]):
                            dfs.append(res[0])
                            print(f'{len(dfs)}/{repeat_comp_validation} added')
                    validation_set = pd.concat(dfs, axis=0, ignore_index=True)
                df_vali = validation_set.copy()
                X = df_vali.values[:, n_organs:]
                y = df_vali.values[:, :n_organs]
                data = X
                print(f'non zero col before: {np.where(np.sum(data, axis=0) != 0)[0].shape[0]}')
                col_sum = np.sum(data, axis=0)
                non_zero_col = np.where(col_sum != 0)[0]
                sel_mask = random.sample(non_zero_col.tolist(), k=non_zero_col.shape[0]-after_mask if after_mask <= non_zero_col.shape[0] else 0)
                data[:, sel_mask] = 0
                print(f'non zero col after: {np.where(np.sum(data, axis=0) != 0)[0].shape[0]}')
                X = data
                scaler = MinMaxScaler()
                print('predicting ...')
                X = scaler.fit_transform(X)
                y_pred = model.predict(X)
                y_true_df = df_vali.iloc[:, :n_organs]
                y_pred_df = pd.DataFrame(data=y_pred, columns=df_vali.iloc[:, :n_organs].columns)
                return y_true_df, y_pred_df
            y_true_df, y_pred_df = get_y_true_pred_df()
            y_true_df.to_csv(f'{data_folder}/true_gtex_deep.csv', index=False)
            y_pred_df.to_csv(f'{data_folder}/pred_gtex_deep.csv', index=False)
            orgs = []
            pearson  = []

            for organ in y_true_df.columns.values:
                orgs.append(organ)
                pearson.append(pearsonr(y_true_df[organ].values, y_pred_df[organ].values)[0])
                print(f'{orgs[-1]}:{pearson[-1]}')
            
            mse_mask = [mean_squared_error(y_true_df.values[:, i], y_pred_df.values[:, i]) for i in range(y_true_df.shape[1])]

            key = f'mse_{after_mask}'
            mse_dat[key] = mse_mask 
            key = f'pearson_{after_mask}'
            pearson_dat[key] = pearson

    pearson_df = pd.DataFrame(data=pearson_dat, index=orgs)
    mse_df = pd.DataFrame(data=mse_dat, index=orgs)
    pearson_df = pearson_df.T
    mse_df = mse_df.T

    pearson_df.to_csv(f'{data_folder}/pearson_all_gtex_deep.csv')
    mse_df.to_csv(f'{data_folder}/mse_all_gtex_deep.csv')



