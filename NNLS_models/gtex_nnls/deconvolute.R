# 05/23/2023 Fengyao Yan
# apply NNLS deconvolution on the Gtex semi-silico data

library(tidyverse)
library(ggplot2)
library(nnls)
library(Metrics)
library(data.table)
library(doParallel)
library(parallel)

# multicore setup
cores = 2
registerDoParallel(foreach)


mse_all = NULL
pcc_all = NULL

is_sens_test <- FALSE

data_folder <- '../../data/gtex'
data_raw <- '../../data/raw'

f_name <- paste(data_raw, '/selected_gtex_top_1_NT_1_fc_3_data.csv', sep='')

dat<-fread(f_name, data.table = FALSE)
dat <- dat[,-1]

exclude <- c('Adrenal Gland', 'Fallopian Tube', 'Vagina', 'Salivary Gland')

dat <- dat[!dat$tissue %in% exclude,]

ogs <- sort(unique(dat$tissue))

res <- data.frame(matrix(nrow=0, ncol=ncol(dat)-2))

colnames(res) <- colnames(dat[, 3:ncol(dat)])


for (og in ogs){
  sub <- dat[dat$tissue == og, ]
  res[nrow(res)+1, ] <- t(colMeans(sub[, 3:ncol(sub)], na.rm=TRUE))
}
rownames(res) <- ogs
ref_dat <-res

f_name <- paste(data_raw, '/composition_gtex_05_08.csv', sep='')
mix_dat <- fread(f_name, data.table = FALSE)

mix_dat <- mix_dat[sample(1:nrow(mix_dat), size=100),]

y_true <- mix_dat[, 1:length(ogs)]
mix_dat <- mix_dat[, -(1:length(ogs))]


comm_names <- intersect(colnames(mix_dat), colnames(ref_dat))
mix_dat <- mix_dat[, comm_names]
ref_dat <- ref_dat[, comm_names]

ref_dat <- log2(ref_dat+1)
mix_dat <- log2(mix_dat+1)

start <- 6000
if(is_sens_test){start <- 2000}
for (after_mask in seq(from = start, to = 6000, by = 500)){
  
#random zero genes

sel_idx <- sample(1:ncol(mix_dat), size=min(after_mask, ncol(mix_dat)))

all_idx = 1:ncol(mix_dat)

zero_idx <- all_idx[! all_idx %in% sel_idx]

mix_dat_ <- data.frame(mix_dat)

mix_dat_[, zero_idx] <- 0

y_pred <- data.frame(matrix(ncol=length(ogs), nrow=0))
colnames(y_pred) <- colnames(y_true)

mse <- data.frame(matrix(ncol=length(ogs), nrow=0))
colnames(mse) <-  colnames(y_true)

pcc <- data.frame(matrix(ncol=length(ogs), nrow=0))
colnames(pcc) <- colnames(y_true)

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
for(j in 1:ncol(y_pred)){
  mse_v <- append(mse_v, mse(y_pred[,j], y_true[,j]))
}

pcc_v <- list()
for(j in 1:ncol(y_pred)){
  pcc_v <- append(pcc_v, cor(y_pred[,j], y_true[,j], method='pearson'))
}


mse_v <- unlist(mse_v)
mse[as.character(after_mask),] <- mse_v

pcc_v <- unlist(pcc_v)
pcc[as.character(after_mask),] <- pcc_v
# add mse pcc to final results

print(paste('mean mse', mean(mse_v, na.rm = TRUE), sep=' '))
print(paste('mean pcc', mean(pcc_v, na.rm = TRUE), sep=' '))

mse_all = rbind(mse_all, mse)
pcc_all = rbind(pcc_all, pcc)

}

write.csv(y_true, paste(data_folder, '/true_gtex_nnls.csv', sep=''))
write.csv(y_pred, paste(data_folder, '/pred_gtex_nnls.csv', sep=''))

mse_all <- as.data.frame(mse_all)
pcc_all <- as.data.frame(pcc_all)

write.csv(mse_all, paste(data_folder, '/mse_all_gtex_nnls.csv', sep=''))
write.csv(pcc_all, paste(data_folder, '/pcc_all_gtex_nnls.csv', sep=''))


