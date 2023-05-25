#05/25/2023 Fengyao Yan
#Make the dot plot for NNLS GTEx sensitivity test

library(tidyverse)
library(ggplot2)

pearson_dots <- data.frame(matrix(ncol=4, nrow=0))
colnames(pearson_dots) <- c('tissue', 'pcc', 'n_gene', 'model')

pcc_nnls <- read.csv('../../data/gtex/pcc_all_gtex_nnls.csv', row.names = 1)
pcc_deep <- read.csv('../../data/gtex/pearson_all_gtex_deep.csv', row.names=1)

pcc_nnls <- pcc_nnls[!rownames(pcc_nnls) %in% c(500, 1000, 1500),]
pcc_deep <- pcc_deep[!rownames(pcc_deep) %in% c('pearson_500', 'pearson_1000', 'pearson_1500'),]

for(i in 1:nrow(pcc_nnls)){
  for (j in 1:ncol(pcc_nnls)){
    crow <- nrow(pearson_dots) + 1
    pearson_dots[crow, 'pcc'] <- as.numeric(pcc_nnls[i, j])
    pearson_dots[crow, 'n_gene'] <- as.numeric(rownames(pcc_nnls)[i])
    pearson_dots[crow, 'model'] <- 'NNLS'
    pearson_dots[crow, 'tissue'] <- colnames(pcc_nnls)[j]
  }
}

for(i in 1:nrow(pcc_deep)){
  for (j in 1:ncol(pcc_deep)){
    crow <- nrow(pearson_dots) + 1
    
    pearson_dots[crow, 'pcc'] <- as.numeric(pcc_deep[i, j])
    pearson_dots[crow, 'n_gene'] <- as.numeric(unlist(strsplit(rownames(pcc_deep)[i], '[_]'))[2])
    pearson_dots[crow, 'model'] <- 'DL'
    pearson_dots[crow, 'tissue'] <- colnames(pcc_deep)[j]
  }
}


pearson_dots$n_gene <- as.factor(pearson_dots$n_gene)
pearson_dots$tissue <- as.factor(pearson_dots$tissue)

p<-ggplot(pearson_dots, aes(x=n_gene, y=pcc, fill=model)) + 
  geom_boxplot()+ geom_point(position=position_dodge(width=0.75),aes(group=model)) +
  labs(title='Deep Learning vs NNLS Correlation Sensitivity') + 
  xlab('Number of random genes selected') +
  ylab('PCC distribution')
p

ggsave('gtex_deep_vs_nnls_pcc_dot.jpg', dpi=300, height=4, width=7)


# plot box tissue wise correlation
#library(data.table)
#library(ggplot2)

#pred_deep <- fread('pred_gtex_deep.csv', data.table=FALSE)
#true_deep <- fread('true_gtex_deep.csv', data.table=FALSE)

#cor_dat <- cor(pred_deep, true_deep, method='pearson')

#deep <- as.vector(diag(as.matrix(cor_dat)))

#pred_nnls <- fread('pred_gtex_nnls.csv', data.table=FALSE)
#true_nnls <- fread('true_gtex_nnls.csv', data.table=FALSE)

#cor_dat <- cor(pred_nnls, true_nnls, method='pearson')

#nnls <- as.vector(diag(as.matrix(cor_dat)))

#deep_dat <- data.frame(deep)
#deep_dat$model <- rep('deep learning', length(deep))

#colnames(deep_dat) <- c('cor', 'model')
#
#nnls_dat <- data.frame(nnls)
#nnls_dat$model <- rep('nnls', length(nnls))

#colnames(nnls_dat) <- c('cor', 'model')

#plot_dat = rbind(deep_dat, nnls_dat)

#plot_dat$model <- as.factor(plot_dat$model)

#p<-ggplot(plot_dat, aes(x=model, y=cor, fill=model)) + 
#  geom_boxplot(width=0.5)+ geom_point(position=position_dodge(width=0.75),aes(group=model)) +
#  labs(title='Deep Learning vs NNLS Tissue-wise PCC') + 
#  xlab('model') +
#  ylab('pcc')
#p

#ggsave('pcc_deep_vs_nnls_gtex_box.jpg', dpi=300, height=7, width=12)






