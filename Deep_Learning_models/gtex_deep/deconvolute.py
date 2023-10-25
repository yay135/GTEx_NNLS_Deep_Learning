# script to deconvolute a csv file 

from decide_organ import *
import os

# look into app folder by default
model = tf.keras.models.load_model(model_name)
folder = "/app"
for file in os.listdir(folder):
    custom_data_path = os.path.join(folder,file)

    template = pd.read_csv("../../data/raw/composition_gtex_05_08.csv")
    gene_headers = template.columns.to_list()[15:]

    scaler = MinMaxScaler()
    scaler.fit(template[gene_headers].values)

    custom_data = pd.read_csv(custom_data_path)
    custom_data = custom_data.reindex(columns=gene_headers, fill_value=0)
    
    # log2 transform
    custom_data = custom_data + 1
    custom_data = custom_data.apply(np.log2)

    cdata = scaler.transform(custom_data.values)
    save_name = f"deconvolute_deep_{file}"

    pred = model.predict(np.concatenate((np.zeros((cdata.shape[0], 1)), cdata), 1))
    pd.DataFrame(pred, columns=template.columns[:15]).to_csv(os.path.join(folder, save_name), index=False)
    print(f"Done {save_name} .")