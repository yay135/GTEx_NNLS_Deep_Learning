#05/19/2023 Fengyao Yan 
# train single tissue classification model
# plot ROC curve


import pickle 
import matplotlib
import numpy as np
import pandas as pd
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import OneHotEncoder, MinMaxScaler
from sklearn.metrics import RocCurveDisplay, classification_report
matplotlib.rcParams.update({'font.size': 11})

data_folder = '../../data/single_t'
data_raw = '../../data/raw'

df_tcga = pd.read_csv(f'{data_raw}/selected_data_TCGA_validation.csv')
df_tcga = df_tcga.drop(axis=0, index=[0,1])
df_tcga = df_tcga.drop(columns='sample')

smote = SMOTE()
df_gtex = pd.read_csv(f'{data_raw}/selected_gtex_top_1_NT_1_fc_3_data.csv', low_memory=False, index_col=0)
df_gtex = df_gtex.drop(columns='sample')

sel = [col_name for col_name in df_gtex.columns if col_name in df_tcga.columns]

df_gtex = df_gtex[sel]
df_tcga = df_tcga[sel]

com_t = set(df_gtex['tissue'].to_list()).intersection(df_tcga['tissue'].to_list())

gtex_row = [t in com_t for t in df_gtex['tissue']]
df_gtex = df_gtex.loc[gtex_row, :]
tcga_row = [t in com_t for t in df_tcga['tissue']]
df_tcga = df_tcga.loc[tcga_row, :]

X = df_gtex.drop(columns='tissue').values
y = df_gtex['tissue'].values.reshape(-1, 1)
# log2 transform
X += 1
X = np.log2(X)

onehot = OneHotEncoder(sparse=False)
y = onehot.fit_transform(y)

X, y = smote.fit_resample(X,y)

scaler = MinMaxScaler()
X = scaler.fit_transform(X)

with open(f'{data_folder}/scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

X, y = shuffle(X, y)
model = tf.keras.models.Sequential()
model.add(tf.keras.Input(shape=(X.shape[1])))
model.add(tf.keras.layers.Dense(256, activation='relu'))
model.add(tf.keras.layers.Dense(len(onehot.categories_[0]), activation='softmax'))
model.compile(
    loss = 'categorical_crossentropy', 
     optimizer = "adam",               
              metrics = ['accuracy']
)
model.summary()
callback = tf.keras.callbacks.EarlyStopping(monitor='accuracy', restore_best_weights=True)
model.fit(X, y, batch_size=64, epochs=100, verbose=1, validation_split=0.1, callbacks=[callback])

model.save(f'{data_folder}/single_t')

#log2 transform
X_vali = (df_tcga.iloc[:, 1:].astype(float) + 1).applymap(np.log2).values

X_vali = scaler.transform(X_vali)

y_vali = df_tcga.loc[:, 'tissue'].values.reshape(-1, 1)
y_vali = onehot.transform(y_vali)

y_score = model.predict(X_vali)

pd.DataFrame(data=y_score, columns=onehot.categories_).to_csv(f'{data_folder}/pred_score_onehot.csv', index=False)
pd.DataFrame(data=y_vali, columns=onehot.categories_).to_csv(f'{data_folder}/true_onehot.csv', index=False)

loss, acc = model.evaluate(X_vali, y_vali)

y_vali_or = onehot.inverse_transform(y_vali)
y_predict_or = onehot.inverse_transform(y_score)

pd.DataFrame(data=y_vali_or.reshape(-1,1), columns=['tissue']).to_csv(f'{data_folder}/true.csv', index=False)
pd.DataFrame(data=y_predict_or.reshape(-1,1), columns=['tissue']).to_csv(f'{data_folder}/pred.csv', index=False)

report_dict = classification_report(y_vali_or, y_predict_or, output_dict=True)
report_df = pd.DataFrame(report_dict)
report_df = report_df.drop(columns=['accuracy', 'macro avg', 'weighted avg'])
report_df['Metrics'] = report_df.index
r = report_df.columns.to_list()
r.remove('Metrics')
report_df = report_df[['Metrics']+r]

report_df.to_csv(f'{data_folder}/metrics.csv', index=False)

fig, ax = plt.subplots(figsize=(5,5), dpi=300)

def get_cmap(n, name='hsv'):
    '''Returns a function that maps each index in 0, 1, ..., n-1 to a distinct 
    RGB color; the keyword argument name must be a standard mpl colormap name.'''
    return plt.cm.get_cmap(name, n)

cmap = get_cmap(13)
for i in range(len(onehot.categories_[0])):
    RocCurveDisplay.from_predictions(
        y_vali[:, i],
        y_score[:, i],
        name=f"{onehot.categories_[0][i]}",
        color=cmap(i),
        ax = ax
    )

#plt.plot([0, 1], [0, 1], "k--", label="chance level (AUC = 0.5)")
plt.axis("square")
plt.xlabel("specificity")
plt.ylabel("sensitivity")
plt.title("Single Tissue Prediction Performance ROC Curves ")
plt.legend()
plt.savefig(f'{data_folder}/ROC.jpg')
plt.show()
