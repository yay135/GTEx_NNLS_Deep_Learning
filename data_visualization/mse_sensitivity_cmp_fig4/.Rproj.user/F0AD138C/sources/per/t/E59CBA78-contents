# 05/23/2023 Fengyao Yan
# Make the distribution plot for MSE change on CMP dataset comparing deep learning vs NNLS

library(ggplot2)
library(tidyverse)
library(data.table)
library(Metrics)



dat_pred <- fread('../../data/cmp/pred_cmp_nnls.csv', data.table = FALSE)
dat_true <- fread('../../data/cmp/true_cmp_nnls.csv', data.table = FALSE)

dat_pred <- dat_pred[,-1]
dat_true <- dat_true[,-1]

pcc <- data.frame(matrix(ncol=ncol(dat_pred), nrow=0))
colnames(pcc) <- colnames(dat_true)

pcc['nnls',] <- diag(cor(dat_pred, dat_true, method='pearson'))

get_mse_sample<-function(dat_pred, dat_true){
  
  mse = list()
  
  for (i in 1:nrow(dat_true)){
    m <- mse(as.numeric(dat_pred[i,]), as.numeric(dat_true[i,]))
    mse <- append(mse, m)
  }
  
  mse <- unlist(mse)
  return (mse)

}

mse_nnls <- get_mse_sample(dat_pred, dat_true)

dat_pred <- fread('../../data/cmp/cmp_res/cmp_pred.csv', data.table = FALSE)
dat_true <- fread('../../data/cmp/cmp_res/cmp_true.csv', data.table = FALSE)


pcc['deep',] <- diag(cor(dat_pred, dat_true, method='pearson'))

mse_deep <- get_mse_sample(dat_pred, dat_true)

plot_dat <- data.frame(mse_nnls, mse_deep)

colnames(plot_dat) <- c('nnls', 'deep')
plot_dat$id <- 1:nrow(plot_dat)

dat <- plot_dat 

dat <- dat %>%
  gather(key = group, value = value, deep:nnls) %>%
  mutate(
    xdot = ifelse(group == "deep", -1, 1),
    xbox = ifelse(group == "deep", -2, 2)
  )


mycol = c(
  "deep" = "#44a0e3",
  "nnls" = "#e91c2b"
)

ggplot(dat, aes(y = value, fill = group, color = group)) +
  geom_line(aes(x = xdot, group = id), color = "grey70", size = 0.1) +
  geom_point(aes(x = xdot), size = 1) +
  geom_violin(aes(x = xbox, group = group), trim = FALSE, width = 1.6, size = 0.3) +
  geom_boxplot(aes(x = xbox, group = group), fill = "grey70", color = "grey70", width = 0.1) +
  stat_summary(aes(x = xbox, group = group), fun = median, geom = "crossbar", size = 0.3, width = 0.1) +
  scale_x_continuous(
    breaks = c(-1.5, 1.5),
    labels = c("DL", "NNLS")
  ) +
  scale_color_manual(values = mycol) +
  scale_fill_manual(values = mycol) +
  #theme_bw() +
  #theme(
  #  legend.position = "none",
  #  panel.grid = element_line(linetype = "dashed", size = 0.1, color = "Gainsboro")
  #) +
  theme(legend.position = 'none')+
  labs(x = 'Models', y = 'MSE', title='Deep Learning vs NNLS MSE')

ggsave("distribution_cmp_nnls_vs_deep_mse_comparison.jpg", width = 4, height = 4, dpi = 300)

# dotplot pcc

rownames(pcc) <- c('NNLS', 'DL')

pcc_ <- data.frame(matrix(ncol=3, nrow=0))
colnames(pcc_) <- c('pcc', 'Model', 'Tissue')
for(i in 1:nrow(pcc)){
  for(j in 1:ncol(pcc)){
    idx <- nrow(pcc_) + 1
    pcc_[idx, ] <- c(pcc[i, j], rownames(pcc)[i], colnames(pcc)[j])
  }
}


pcc_$pcc <- as.numeric(pcc_$pcc)
pcc_$Model <- as.factor(pcc_$Model)
pcc_$Tissue <- as.factor(pcc_$Tissue)

ggplot(pcc_, aes(x=Tissue, y=pcc)) + 
  geom_point(size=3, aes(colour=Model, shape=Tissue, stroke=1)) + ylim(0.73, 1) +
  labs(title = 'Deep Learning vs NNLS correlation', x='Tissue', y='PCC')

ggsave('distribution_cmp_nnls_vs_deep_pearson_comparison.jpg', width=4, height=4, dpi=300)





