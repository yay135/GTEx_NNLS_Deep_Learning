#05/23/2023 Fengyao Yan
#make the pie chart to show to change trend of genes from normal tissue to tumor.

library(ggplot2)
library(ggrepel)
library(scales)
library(tidyverse)

df_tss <- read.csv('../../data/raw/TSS_genes.csv', row.names=1)

tss <- unique(unlist(df_tss['gene']))

res_cancer <- data.frame(matrix(ncol=3, nrow=0))

tcga_t<- read.table('tcga_tissue_selected.txt', header = TRUE)


for (fname in list.files('../../data/pie')){
  if(endsWith(fname, '.DEG.txt')){
    cancer<- unlist(str_split(fname, '[_]'))[2]
    if (cancer %in% tcga_t$project){
      
      full_f <- paste('../../data/pie/', fname, sep='')
      fc_t_v_n <- read.table(full_f, header=TRUE)

      fc_t_v_n <- na.omit(fc_t_v_n)

      rm_version <- function(data){
        return (unlist(str_split(data, '[.]'))[1])
      }

      geneid = list()

      for (id in fc_t_v_n$geneid_full){
        id_ <- rm_version(id)
        geneid <- append(geneid, id_)
      }

      fc_t_v_n$geneid <- unlist(geneid)

      fc_t_v_n<-fc_t_v_n[, colnames(fc_t_v_n) != 'geneid_full']

      comm <- intersect(tss, unlist(fc_t_v_n$geneid))

      fc_t_v_n <- fc_t_v_n[fc_t_v_n$geneid %in% comm,]

      total <- dim(fc_t_v_n)[1]

      sub_paj <- fc_t_v_n[fc_t_v_n$padj <= 0.05,]

      sub_increase <- sub_paj[sub_paj$log2FoldChange > 0,]
      sub_decrease <- sub_paj[sub_paj$log2FoldChange < 0,]

      nc <- dim(fc_t_v_n)[1] - dim(sub_paj)[1]
      ic <- dim(sub_increase)[1]
      dc <- dim(sub_decrease)[1]

      s <- nc + ic + dc

      group <- c('No-change', 'Increase', 'Decrease')

      value <- c(nc, ic, dc)

      res <- data.frame(group, value)

      tiss <- as.character(tcga_t[tcga_t$project==cancer, 'tissue'])

      cancer <- paste(tiss, cancer, sep=' ')

      print(cancer)


      res <- res %>% 
        arrange(desc(group)) %>%
        mutate(prop = value / sum(res$value) *100) %>%
        mutate(ypos = cumsum(prop)- 0.5*prop ) %>% 
        mutate(per = percent(value/sum(value), accuracy=1))


      res$cancer <- rep(cancer, 3)

      res_cancer <- rbind(res_cancer, res)

    }
  }
}

res_cancer <- as.data.frame(res_cancer)

print(str(res_cancer))

# plot

# Create Data
#data <- data.frame(
# group=LETTERS[1:5],
# value=c(13,7,9,21,2)
#)

data <- res_cancer

# Basic piechart
pie <- ggplot(data, aes(x="", y=prop, fill=group)) +
  geom_bar(stat="identity", width=1, color='white') +
  coord_polar("y", start=0) + scale_fill_manual(values=c('green4', 'red3', 'darkgrey')) +
  geom_text_repel(aes(label = per, y = ypos, x=1.5), color = "black", size=3) +
  theme_void() + facet_wrap(~cancer, ncol=5) 

pie + labs('Percentages of Genes Changed from Normal to Tumor')

ggsave('pie_normal_v_tumor_fc.jpg', dpi=300, height=4, width=8)



