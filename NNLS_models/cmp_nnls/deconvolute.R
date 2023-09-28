# 05/23/2023 Fengyao Yan
# Apply tissue deconvolution using NNLS on the CMP data

library(tidyverse)
library(ggplot2)
library(nnls)
library(Metrics)
library(data.table)
library(doParallel)
library(parallel)

# multicore setup
cores <- 48
registerDoParallel(foreach)

mse_all <- NULL
pcc_all <- NULL

is_sens_test <- TRUE
data_folder <- '../../data/cmp' 
data_raw <- '../../data/raw'

use_all_tissue <- FALSE

dat<-fread(paste(data_raw,'/selected_gtex_top_1_NT_1_fc_3_data.csv', sep=''), data.table = FALSE)
dat <- dat[,-1]

all_tissue <- c('Brain', 'Breast', 'Colon', 'Esophagus', 'Kidney', 'Liver', 'Lung', 'Ovary', 'Pancreas', 'Prostate', 'Skin', 'Small Intestine', 'Stomach', 'Thyroid', 'Uterus')

include <- c('Brain', 'Breast', 'Colon', 'Kidney', 'Liver', 'Lung')

if(!use_all_tissue){
  dat <- dat[dat$tissue %in% include,]
  all_tissue <- include
}

ogs <- sort(unique(dat$tissue))

res <- data.frame(matrix(nrow=0, ncol=ncol(dat)-2))

colnames(res) <- colnames(dat[, 3:ncol(dat)])

print('getting ref df ...')
for (og in ogs){
  sub <- dat[dat$tissue == og, ]
  colmean = colMeans(sub[, 3:ncol(sub)], na.rm=TRUE)
  res[nrow(res)+1, ] <- t(colmean)
}
rownames(res) <- ogs
ref_dat <-res

mix_dat <- fread(paste(data_raw, '/composition_cmp_05_05.csv', sep=''), data.table=FALSE)
y_true <- mix_dat[,1:length(include)]
mix_dat <- mix_dat[,-(1:length(include))]


comm_names <- intersect(colnames(mix_dat), colnames(ref_dat))

mix_dat <- mix_dat[, comm_names]
ref_dat <- ref_dat[, comm_names]

ref_dat <- log2(ref_dat+1)
mix_dat <- log2(mix_dat+1)

start <- 5000
if(is_sens_test){start <- 2000}

for (after_mask in seq(from = start, to = 5000, by = 500)){

#random zero genes
print('randomize ...')

sel_idx <- sample(1:ncol(mix_dat), size=min(after_mask, ncol(mix_dat)))

all_idx = 1:ncol(mix_dat)

zero_idx <- all_idx[! all_idx %in% sel_idx]


mix_dat_ <- data.frame(mix_dat)

mix_dat_[, zero_idx] <- 0

y_pred <- data.frame(matrix(ncol=length(all_tissue), nrow=0))
colnames(y_pred) <- all_tissue

mse <- data.frame(matrix(ncol=length(include), nrow=0))
colnames(mse) <-  include

pcc <- data.frame(matrix(ncol=length(include), nrow=0))
colnames(pcc) <- include

# multiprocess nnls
cl <- makeCluster(cores)

registerDoParallel(cl)

run_nnls <- function(i){
  x <- ref_dat
  y <- mix_dat_[i,]
  mod1 <- nnls(t(x), t(y))
  return (mod1$x)
}

clusterExport(cl, list('ref_dat', 'mix_dat_', 'run_nnls', 'nnls'))

id_all<- 1:nrow(mix_dat_)

system.time(res <- c(parLapply(cl, id_all, run_nnls)))
stopCluster(cl)

for(i in id_all){
  y_pred[i, ] <- res[[i]]
}

print(after_mask)

mse_v <- list()
for(t in include){
  mse_v <- append(mse_v, mse(y_pred[,t], y_true[,t]))
}

pcc_v <- list()
for(t in include){
  pcc_v <- append(pcc_v, cor(y_pred[,t], y_true[,t], method='pearson'))
}


mse_v <- unlist(mse_v)
mse[as.character(after_mask),] <- mse_v

pcc_v <- unlist(pcc_v)
pcc[as.character(after_mask),] <- pcc_v

# add mse to final mse results

mse_all = rbind(mse_all, mse)
pcc_all = rbind(pcc_all, pcc)

}

write.csv(y_true, paste(data_folder, '/true_cmp_nnls.csv',sep=''))
write.csv(y_pred, paste(data_folder, '/pred_cmp_nnls.csv',sep=''))

mse_all <- as.data.frame(mse_all)
pcc_all <- as.data.frame(pcc_all)

write.csv(mse_all, paste(data_folder,'/mse_all_cmp_nnls.csv',sep=''))
write.csv(pcc_all, paste(data_folder, '/pcc_all_cmp_nnls.csv', sep=''))



