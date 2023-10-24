from which_tissue import *
import os

folder = "/app"
model = tf.keras.models.load_model("../../data/single_t/single_t")

for file in os.listdir(folder):
    path = os.path.join(folder, file)
    data = pd.read_csv(path)
    data = data.reindex(columns=df_gtex.drop(columns="tissue").columns, fill_value=0)
    data = data + 1
    data = data.apply(np.log2)
    data = scaler.transform(data.values)

    pred = model.predict(data)
    pred = onehot.inverse_transform(pred)

    save_name = f"tissue_type_{file}"

    pd.DataFrame(pred).to_csv(os.path.join(folder, save_name), index=False, header=False)
    print(f"Done {save_name}")



    
