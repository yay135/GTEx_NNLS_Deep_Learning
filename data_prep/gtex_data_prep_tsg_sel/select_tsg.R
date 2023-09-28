# 05/19/2023 Fengyao Yan 
# This file is written to select TSG (tissue specific genes)

library(matrixStats)
library(tidyverse)
library(data.table)

data_folder <- '../../data/raw'

dat <- fread(paste(data_folder,'/mean_df.csv',sep=''), data.table=FALSE)
rownames(dat) <- dat[,1]
dat <- dat[, -1]
dat <- as.data.frame(t(dat))

# tissues to consider
tissue_list=c('Brain', 'Breast', 'Colon', 'Kidney', 'Liver', 'Lung', 'Ovary', 'Pancreas', 'Prostate', 'Skin', 'Small Intestine', 'Stomach', 'Thyroid', 'Uterus', 'Esophagus')
sel_t_list <- tissue_list
mean_dat <- dat[, sel_t_list]
l=which(rowMaxs(as.matrix(mean_dat))<1)
mean_dat1=mean_dat[-l, ]

# NT is number of tissue to tolerate for not meeting fold change requirement other than this tissue for all genes
# fc is fold change requirement.
NT=1
fc = 3
# select TSG
TS_genes=data.frame(matrix(nrow=0, ncol=2))

for (i in rownames(mean_dat1)){
  max_index=which(mean_dat1[i,]==max(mean_dat1[i,]))
  FCs=max(mean_dat1[i,])/mean_dat1[i,]
  if(!(sum(FCs<fc)-1)>NT){
    res=c(sel_t_list[max_index], i, as.numeric(rowMeans(FCs)))
    TS_genes=rbind(TS_genes, res)
  }
}

colnames(TS_genes) <- c('tissue', 'gene', 'mean_fc')
write.csv(TS_genes, paste(data_folder,'/TSS_genes.csv', sep=''))

ts_mean_dat <- mean_dat1[rownames(mean_dat1) %in% unique(TS_genes$gene),]
rm <- rowMeans(ts_mean_dat)
gene <- rownames(ts_mean_dat)
ts_mean <- data.frame(gene, rm) %>% 
  arrange(desc(rm))

# save only TSG info
top <- 1
ts_mean_top <- ts_mean[1:as.integer(top*nrow(ts_mean)),]
f_name <- paste('selected_gtex_top', top, 'NT', NT, 'fc', fc,'gene.csv', sep='_')
f_name <- paste(data_folder, '/', f_name, sep='')
write.csv(ts_mean_top, f_name)

# select data from GTEx original file
full_gtex <- fread(paste(data_folder,'/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct',sep=''), data.table = FALSE)
#remove ensembl id version
remove_ver <- function(ensembl){
  return(str_split_1(ensembl, '[.]')[1])
}

full_gtex$Name <- sapply(full_gtex$Name, remove_ver)
anno <- fread(paste(data_folder,'/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt', sep=''), data.table=FALSE)

# filter tissue types
anno <- anno[anno$SMTS %in% sel_t_list, ]
sel_gtex <- full_gtex %>% 
  filter(Name %in% ts_mean_top$gene) %>% 
  select(any_of(c('Name', anno$SAMPID))) 
sel_gtex_t <- as.data.frame(t(sel_gtex))

# make Name column
colnames(sel_gtex_t) <- sel_gtex_t['Name', ]
sel_gtex_t <- sel_gtex_t[rownames(sel_gtex_t) != 'Name',]
sel_gtex_t$sample <- rownames(sel_gtex_t)
rownames(sel_gtex_t) <- NULL
rownames(anno) <- anno$SAMPID
tissues <- list()
for (bar in sel_gtex_t$sample){
  tissues <- append(tissues, as.character(anno[bar, 'SMTS']))
}
sel_gtex_t$tissue <- as.character(tissues)

# select samples
old <- read.csv(paste(data_folder,'/selected_gtex_barcode.csv',sep=''))
sel_gtex_t<-sel_gtex_t[sel_gtex_t$sample %in% old$sample,]

# arrange columns
cols <- as.vector(colnames(sel_gtex_t))
cols <- cols[!cols %in% c('sample', 'tissue')]
sel_gtex_t <- sel_gtex_t[,c('sample', 'tissue', cols)]
f_name <- paste('selected_gtex_top', top, 'NT', NT, 'fc', fc,'data.csv', sep='_')
f_name <- paste(data_folder,'/',f_name, sep='')
write.csv(sel_gtex_t, f_name)



