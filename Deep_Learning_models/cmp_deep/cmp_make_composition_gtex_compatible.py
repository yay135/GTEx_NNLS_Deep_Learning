# 05/23/2023 Fengyao Yan 
# Make semi silico data from the cmp dataset.
import os
import pandas as pd 
from multiprocessing import Pool, cpu_count
from decide_organ import _gen_comp
from decide_organ import master

data_raw = '../../data/raw'

cpu_count = 12
if not os.path.exists(f'{data_raw}/tissue_cmp_expression.csv'):
    id_to_name = pd.read_csv(f'{data_raw}/martquery_0503203624_374.txt')
    df_cmp_raw = pd.read_csv(f'{data_raw}/tissue_cmp.csv')
    comm_name = set(df_cmp_raw['gene_name'].to_list()).intersection(set(id_to_name['Gene name'].to_list()))
    row_sel = [gn in comm_name for gn in df_cmp_raw['gene_name']]
    df_cmp_raw = df_cmp_raw.loc[row_sel, ]
    df_cmp_raw['name'] = [id_to_name.loc[id_to_name['Gene name']==n, 'Gene stable ID'].values[0] for n in df_cmp_raw['gene_name'].to_list()]
    df_cmp_raw.index = df_cmp_raw['name']
    df_cmp_raw = df_cmp_raw.drop(columns=['gene_name', 'name'])
    df_cmp = df_cmp_raw.T
    df_cmp.to_csv(f'{data_raw}/tissue_cmp_expression.csv')

if __name__ == '__main__':
    df_cmp = pd.read_csv(f'{data_raw}/tissue_cmp_expression.csv', index_col=0)
    df_cmp['tissue'] = df_cmp.index.to_list()
    df_gtex = pd.read_csv(master)
    df_cmp['sample'] = [df_gtex['sample'].to_list()[0]]*len(df_cmp)
    _df_cmp = df_cmp.copy()
    _df_cmp['sample'] = [df_gtex['sample'].to_list()[-1]]*len(df_cmp)
    df_cmp_new = pd.concat((df_cmp, _df_cmp), axis=0)
    cols = df_cmp_new.columns.to_list()
    cols.remove('tissue')
    cols.remove('sample')
    cols = ['tissue', 'sample'] + cols
    df_cmp_new = df_cmp_new[cols]
    dfs = []
    with Pool(cpu_count) as pool:
        for res in pool.imap(_gen_comp, [df_cmp_new for _ in range(300)]):
            dfs.append(res[0])
            print(f'{len(dfs)} comp generated ...') 
    df_cmp_comp_more = pd.concat(dfs, axis=0)
    df_cmp_comp_more.to_csv(f'{data_raw}/composition_cmp_05_18.csv', index=False)