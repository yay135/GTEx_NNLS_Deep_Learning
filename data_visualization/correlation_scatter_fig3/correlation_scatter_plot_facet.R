#05/23/2023 Fengyao Yan 
#Plot the scatter plots for predicted tissue fractions for Gtex semi-silico data.

library(ggplot2)
library(tidyverse)
library(data.table)

data_t <- fread('../../data/gtex/true_gtex_nnls.csv', data.table=FALSE)
data_p <- fread('../../data/gtex/pred_gtex_nnls.csv', data.table=FALSE)
data_t <- data_t[,-1]
data_p <- data_p[,-1]

exclude <- c('Adrenal.Gland', 'Salivary.Gland', 'Vagina', 'Fallopian.Tube')

data_convert <- data.frame(matrix(nrow=0, ncol=3))
colnames(data_convert) <- c('tissue', 'true', 'predict')

stopifnot(nrow(data_t)==nrow(data_p))

# reduce size of dataset

for (i in 1:nrow(data_t)){
  for (name in colnames(data_t)){
    data_convert[nrow(data_convert)+1, ] <- c(name, data_t[i, name], data_p[i, name])
  }
}
data_convert <- data_convert[!data_convert$tissue %in% exclude, ]


data_convert$true <- as.numeric(data_convert$true)
data_convert$predict <- as.numeric(data_convert$predict)

ggplot(data_convert, aes(x=true, y=predict)) + geom_point(size=2, shape=23) + xlim(0, 1) + ylim(0, 1) + facet_wrap(~tissue, ncol=3) + 
  labs(title = "NNLS Deconvolution GTEx Semi in Silico Correlation") +
  xlab('True') + ylab('Predicted')
ggsave('gtex_correlation_nnls.jpg', height=6, width=7)

data_t <- fread('../../data/gtex/true_gtex_deep.csv', data.table=FALSE)
data_p <- fread('../../data/gtex/pred_gtex_deep.csv', data.table=FALSE)

exclude <- c('Adrenal.Gland', 'Salivary.Gland', 'Vagina', 'Fallopian.Tube')

data_convert <- data.frame(matrix(nrow=0, ncol=3))
colnames(data_convert) <- c('tissue', 'true', 'predict')

stopifnot(nrow(data_t)==nrow(data_p))

for (i in 1:nrow(data_t)){
  for (name in colnames(data_t)){
    data_convert[nrow(data_convert)+1, ] <- c(name, data_t[i, name], data_p[i, name])
  }
}
data_convert <- data_convert[!data_convert$tissue %in% exclude, ]


data_convert$true <- as.numeric(data_convert$true)
data_convert$predict <- as.numeric(data_convert$predict)

ggplot(data_convert, aes(x=true, y=predict)) + geom_point(size=2, shape=23) + xlim(0, 1) + ylim(0, 1) + facet_wrap(~tissue, ncol=3) + 
  labs(title = "Deep Learning Deconvolution GTEx Semi in Silico Correlation") +
  xlab('True') + ylab('Predicted')
ggsave('gtex_correlation_deep.jpg', height=6, width=7)
