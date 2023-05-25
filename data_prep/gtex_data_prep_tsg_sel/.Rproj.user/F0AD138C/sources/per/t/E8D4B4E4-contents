#05/19/2023 Fengyao Yan 
# This file is written to create the dataset of mean gene expression values of all genes in each tissue type

library(tidyverse)
library(data.table)

data_folder <- '../../data/raw'

tissue_list=c('Brain', 'Breast', 'Colon', 'Kidney', 'Liver', 'Lung', 'Ovary', 'Pancreas', 'Prostate', 'Skin', 'Small Intestine', 'Stomach', 'Thyroid', 'Uterus', 'Esophagus')
full_gtex <- fread(paste(data_folder,'/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct', sep=''), data.table = FALSE)
anno <- fread(paste(data_folder,'/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt', sep=''), data.table = FALSE)

#remove ensembl id version
remove_ver <- function(ensembl){
  return(str_split_1(ensembl, '[.]')[1])
}

full_gtex$Name <- sapply(full_gtex$Name, remove_ver)

anno <- anno[anno$SMTS %in% tissue_list, ]

cols <- c('Name', anno$SAMPID)

full_gtex <- full_gtex %>% 
  select(any_of(cols))

mean_dat = data.frame(matrix(ncol=nrow(full_gtex), nrow=0))

for (t in unique(anno$SMTS)){
  print(t)
  bars <- anno[anno$SMTS==t, 'SAMPID']
  sub_gtex <- full_gtex %>% select(any_of(bars))
  print(dim(sub_gtex))
  rm <- rowMeans(sub_gtex)
  mean_dat[t,] <- rm
}

colnames(mean_dat) <- full_gtex$Name

write.csv(mean_dat, paste(data_folder,'/mean_df.csv',sep=''))


