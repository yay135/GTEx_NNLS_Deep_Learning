# 05/23/2023 Fengyao Yan
# Make a dot plot to show the change of pcc for NNLS cmp sensitivity test.

library(tidyverse)
library(ggplot2)

pearson_dots <- data.frame(matrix(ncol=4, nrow=0))
colnames(pearson_dots) <- c('tissue', 'pcc', 'n_gene', 'model')

pcc_nnls <- read.csv('../../data/cmp/pcc_all_cmp_nnls.csv', row.names = 1)
pcc_deep <- read.csv('../../data/cmp/cmp_res/pearson_all_cmp_deep.csv', row.names=1)

pcc_nnls <- pcc_nnls[!rownames(pcc_nnls) %in% c(500, 1000, 1500, 5500, 6000),]
pcc_deep <- pcc_deep[!rownames(pcc_deep) %in% c('pearson_500', 'pearson_1000', 'pearson_1500', 'pearson_5500', 'pearson_6000'),]

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

# remove outliers

dots <- pearson_dots
# turn of quantile outlier removal
dots <- NULL

if(!is.null(dots)){

quartiles <- quantile(dots$mse, probs=c(.05, .95), na.rm = FALSE)
IQR <- IQR(dots$mse)

Lower <- quartiles[1] - 1.5*IQR
Upper <- quartiles[2] + 1.5*IQR 

print(Lower)
print(Upper)

dots <- subset(dots, dots$mse > Lower & dots$mse < Upper)
print(dots)

dots$n_gene <- as.factor(dots$n_gene)
dots$tissue <- as.factor(dots$tissue)
pearson_dots <- dots
}

# drop tissue breast
#pearson_dots <- pearson_dots[pearson_dots$tissue!='Breast',]


pearson_dots$n_gene <- as.factor(pearson_dots$n_gene)
pearson_dots$Tissue <- as.factor(pearson_dots$tissue)
pearson_dots$Model <- as.factor(pearson_dots$model)


p<-ggplot(pearson_dots, aes(x=n_gene, y=pcc)) + 
  geom_point(position=position_dodge(width=0.75),
             aes(group=Model, color=Model, shape=Tissue, stroke=0.5), 
             size=2.5)+
  stat_summary(position=position_dodge(width=0.75),
               fun.y="mean", 
               mapping = aes(group = Model, color=Model), 
               geom="line",
               linetype='dashed')+
  labs(title='Deep Learning vs NNLS Correlation Sensitivity') + 
  ylim(0.6, 1) +
  xlab('Number of random genes selected') +
  ylab('PCC')
p

ggsave('cmp_deep_vs_nnls_pcc_dot0.jpg', dpi=300, height=4, width=6)
