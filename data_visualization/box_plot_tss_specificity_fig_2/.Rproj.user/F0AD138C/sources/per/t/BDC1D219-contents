#05/19/2023 Fengyao Yan
#plot TSG genes distribution in 15 tissue types

library(ggplot2)
library(ggpubr)
library(data.table)

convert_dat <- fread('../../data/raw/martquery.txt', data.table=FALSE)

data0 <- fread('../../data/raw/selected_gtex_top_1_NT_1_fc_3_data.csv', data.table=FALSE)
data0 <- data0[,-1]
data0 <- data0[,!duplicated(colnames(data0))]

data1 <- fread('../../data/raw/tcga_15t_tpm_05_11.csv', data.table=FALSE)
data1 <- data1[,!duplicated(colnames(data1))]

# if gene_name is not provided, use a random gene_name
gene_name <- 'MAP4K1'
if (is.null(gene_name)){
  gene <- sample(colnames(data1[,-1]), size=1)
  gene_name <- as.character(convert_dat[convert_dat$`Gene stable ID` == gene, 'Gene name'])
}else{
  gene <- convert_dat[convert_dat$`Gene name` == gene_name, 'Gene stable ID'][2]
}

data <- data0

tissue <- data[, 'tissue']
exp <- data[, gene]

temp <- data[, c('tissue', gene)]
write.csv(temp, file=paste("tss_gtex", gene_name, gene,'data.csv', sep='_'))

p0 <- ggplot(data, aes(x=tissue, y=exp)) + 
  geom_boxplot(width=0.5)
titlename <- paste('GTEX', gene_name, 'Expression Distribution', sep=' ')

p0 <- p0 + ggtitle(titlename)
p0 <- p0 + theme(axis.text.x = element_text(angle=35, hjust=1)) + xlab('Tissue') + ylab('Expression')
p0

ggsave(paste('tss_gtex', gene_name, gene,'box.png', sep='_'), height = 4, width= 6)
data <- data1[data1$tissue!='adrenal_gland',]
tissue = data[, 'tissue']
exp = data[, gene]
temp <- data[, c('tissue', gene)]
write.csv(temp, file=paste('tss_tcga', gene_name, gene,'data.csv', sep='_'))

p1 <- ggplot(data, aes(x=tissue, y=exp)) + 
  geom_boxplot(width=0.5)
titlename <- paste('TCGA', gene_name, 'Expression Distribution', sep=' ')
p1 <- p1 + ggtitle(titlename)
p1 <- p1 + theme(axis.text.x = element_text(angle = 30, hjust=1)) + xlab('Tissue') + ylab('Expression')
p1

ggsave(paste('tss_tcga', gene_name, gene,'box.png', sep='_'), height = 4, width = 6)

