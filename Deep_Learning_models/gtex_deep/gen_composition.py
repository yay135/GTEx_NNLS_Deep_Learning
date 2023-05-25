#05/23/2023 Fengyao Yan
#helper functions

import numpy as np
import pandas as pd
from random import sample

data_raw = '../../data/raw'

def organs_composition(organs):
        if len(organs) < 1:
            return {}

        if len(organs) == 1:
            return {organs[0]: 1}

        splits = sample([t for t in range(0, 101)], k=len(organs)-1)
        splits = sorted(splits)
        ans = {}

        d = 0
        for k in splits:
            ans[organs.pop()] = (k - d)/100
            d = k 

        ans[organs.pop()] = (100 - d)/100
    
        return ans

def gen_comp(df=None):
    print('started gen comp ...')
    df_gtex = df

    organs = df_gtex['tissue'].value_counts().index.to_list()

    organs = sorted(organs)

    gen_names = df_gtex.columns.values.tolist()[2:]

    current_pid = None
    current_organs = []
    current_gens = []

    da = []

    for i, row in df_gtex.iterrows():
        sample_id = row.at['sample']
        if sample_id is np.NaN:
            continue
        pid = sample_id.split('-')[1]
        if current_pid is None or pid != current_pid:

            if len(current_gens) > 0 and len(current_organs) > 0:
                comp_dict = organs_composition(list(current_organs))
                new_gens = np.zeros(shape=current_gens[0].shape)
                for og in comp_dict:
                    new_gens = new_gens + comp_dict[og]*current_gens[current_organs.index(og)].astype('float')

                comp_arr = []
                for og in organs:
                    if og in comp_dict:
                        comp_arr.append(comp_dict[og])
                    else:
                        comp_arr.append(0)
                new_ = np.concatenate((np.array(comp_arr), new_gens))

                da.append(new_)

            current_organs.clear()
            current_gens.clear()
        
        current_organs.append(row.at['tissue'])
        current_gens.append(row.values[2:])

        current_pid = pid
    
    new_df = pd.DataFrame(data=da, columns=organs+gen_names)
    return new_df, organs
if __name__ == '__main__':
    df_master = pd.read_csv(f'{data_raw}/selected_gtex_top_1_NT_1_fc_3_data.csv', index_col=0)
    dfs = []
    for _ in range(20):
        new_df, _ = gen_comp(df=df_master)
    dfs.append(new_df)

    wdf = pd.concat(dfs, axis=0)

    wdf.to_csv(f'{data_raw}/composition_gtex_05_08.csv', index=False)