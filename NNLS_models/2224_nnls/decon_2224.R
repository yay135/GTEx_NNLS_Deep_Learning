#05/23/2023 Fengyao Yan
#Apply NNLS deconvolution on patient 2224 data.

library(tidyverse)
library(ggplot2)
library(nnls)
library(glmnet)
library(Metrics)
library(data.table)

data_folder <- '../../data/2224'
data_raw <- '../../data/raw'

dat<-fread(paste(data_raw, '/selected_gtex_top_1_NT_1_fc_3_data.csv', sep=''), data.table = FALSE)
dat <- dat[,-1]

dat <- na.omit(dat)

ogs <- sort(unique(dat$tissue))

res <- data.frame(matrix(nrow=0, ncol=ncol(dat)-2))

colnames(res) <- colnames(dat[, 3:ncol(dat)])

for (og in ogs){
  sub <- dat[dat$tissue == og, ]
  colmean = colMeans(sub[, 3:ncol(sub)], na.rm=TRUE)
  res[nrow(res)+1, ] <- t(colmean)
}
rownames(res) <- ogs
ref_dat <-res

df_2224 = fread(paste(data_raw, '/Pt2224cpm.tsv', sep=''), data.table = FALSE)
rownames(df_2224) <- df_2224$V1
df_2224 = df_2224[,colnames(df_2224)!= 'V1']

converter <- fread(paste(data_raw,'/martquery_0503203624_374.txt', sep=''), data.table=FALSE)
colnames(converter) <- c('ensembl', 'gname')
converter <- converter[!duplicated(converter$gname), ]

comm <- intersect(converter$gname, rownames(df_2224))
converter <- converter[which(converter$gname %in% comm),]
df_2224 <- df_2224[which(rownames(df_2224) %in% comm),]

old <- rownames(df_2224)

get_ensembl <- function(gname){
  return(as.character(converter[converter$gname==gname,'ensembl']))
}

rownames(df_2224) <- lapply(old, get_ensembl)

df_2224_ <- data.frame(matrix(ncol=0, nrow=ncol(df_2224)))

count = 0

for(ens in colnames(ref_dat)){
  if(ens %in% rownames(df_2224)){
    df_2224_[,ens] <- as.numeric(df_2224[ens,])
  }else{
    df_2224_[,ens] <- rep(0, ncol(df_2224))
  }
  
  count <- count + 1
  print(paste(count, '/', ncol(ref_dat), 'done', sep=' '))
}

rownames(df_2224_) <- colnames(df_2224) 

# log2 transform

ref_dat <- log2(ref_dat + 1)
df_2224_ <- log2(df_2224_ + 1)

pred <- data.frame(matrix(ncol=nrow(ref_dat), nrow = 0))

for(i in 1:nrow(df_2224_)){
  mod1 <- nnls(t(ref_dat), t(df_2224_[i,]))
  pred[i,] <- mod1$x
}

rownames(pred) <- rownames(df_2224_)
colnames(pred) <- rownames(ref_dat)

pred

write.csv(pred, paste(data_folder, '/res_2224_nnls.csv', sep=''))
