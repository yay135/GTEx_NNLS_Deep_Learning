#05/23/2023 Fengyao Yan
#plot dot plot of mse change for CMP dataset comparing NNLS vs DL

library(ggplot2)
library(tidyverse)

mse_dots <- data.frame(matrix(ncol=4, nrow=0))
colnames(mse_dots) <- c('tissue', 'mse', 'n_gene', 'model')

mse_nnls <- read.csv('../../data/gtex/mse_all_gtex_nnls.csv', row.names = 1)
mse_deep <- read.csv('../../data/gtex/mse_all_gtex_deep.csv', row.names=1)

mse_nnls <- mse_nnls[!rownames(mse_nnls) %in% c(500, 1000, 1500),]
mse_deep <- mse_deep[!rownames(mse_deep) %in% c('mse_500', 'mse_1000', 'mse_1500'),]


for(i in 1:nrow(mse_nnls)){
  for (j in 1:ncol(mse_nnls)){
    crow <- nrow(mse_dots) + 1
    mse_dots[crow, 'mse'] <- as.numeric(mse_nnls[i, j])
    mse_dots[crow, 'n_gene'] <- as.numeric(rownames(mse_nnls)[i])
    mse_dots[crow, 'model'] <- 'NNLS'
    mse_dots[crow, 'tissue'] <- colnames(mse_nnls)[j]
  }
}

for(i in 1:nrow(mse_deep)){
  for (j in 1:ncol(mse_deep)){
    crow <- nrow(mse_dots) + 1
    
    mse_dots[crow, 'mse'] <- as.numeric(mse_deep[i, j])
    mse_dots[crow, 'n_gene'] <- as.numeric(unlist(strsplit(rownames(mse_deep)[i], '[_]'))[2])
    mse_dots[crow, 'model'] <- 'DL'
    mse_dots[crow, 'tissue'] <- colnames(mse_deep)[j]
  }
}

# remove outliers

quartiles <- quantile(mse_dots$mse, probs=c(.15, .85), na.rm = FALSE)
IQR <- IQR(mse_dots$mse)

Lower <- quartiles[1] - 1.5*IQR
Upper <- quartiles[2] + 1.5*IQR 

mse_dots <- subset(mse_dots, mse_dots$mse > Lower & mse_dots$mse < Upper)

mse_dots$n_gene <- as.factor(mse_dots$n_gene)
mse_dots$tissue <- as.factor(mse_dots$tissue)

p<-ggplot(mse_dots, aes(x=n_gene, y=mse, fill=model)) + 
  geom_boxplot()+ geom_point(position=position_dodge(width=0.75),aes(group=model)) +
  labs(title='Deep Learning vs NNLS MSE Sensitivity') + 
  xlab('Number of random genes selected') +
  ylab('MSE distribution')
p

ggsave('gtex_deep_vs_nnls_mse_dot.jpg', dpi=300, height=4, width=7)
