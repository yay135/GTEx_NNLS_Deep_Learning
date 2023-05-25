# 05/18/2023 Fengyao Yan
# Plot the prediction results for patient 2224 with Deep Learning and NNLS

library(ggplot2)

dat_nnls <- read.csv('../../data/2224/res_2224_nnls.csv', row.names=1)
dat_deep <- read.csv('../../data/2224/patient_2224_v2/res_2224_dl.csv')

tissues <- c('Brain', 'Lung', 'Skin')
months <- c('0 month', '3 month', '9 month')

plot_dat <- data.frame(matrix(ncol=4,nrow=0))
colnames(plot_dat) <- c('Fraction', 'Tissue', 'Month', 'Model') 

dat_nnls <- dat_nnls[, colnames(dat_nnls) %in% tissues]
dat_deep <- dat_deep[, colnames(dat_deep) %in% tissues]
# convert columns and rows to values
for(i in 1:nrow(dat_nnls)){
  for(j in 1:ncol(dat_nnls)){
    crow <- nrow(plot_dat) + 1
    plot_dat[crow, ] <- c(dat_nnls[i,j], tissues[j], months[i], 'NNLS')
  }
}

for(i in 1:nrow(dat_deep)){
  for(j in 1:ncol(dat_deep)){
    crow <- nrow(plot_dat) + 1
    plot_dat[crow, ] <- c(dat_deep[i,j], tissues[j], months[i], 'DL')
  }
}

plot_dat$Month <- as.factor(plot_dat$Month)
plot_dat$Fraction <- as.numeric(plot_dat$Fraction)
plot_dat$Tissue <- as.factor(plot_dat$Tissue)
plot_dat$Model <- as.factor(plot_dat$Model)

ggplot(plot_dat, aes(x=Month, y=Fraction)) + 
  geom_point(size=3, aes(colour=Model, shape=Tissue, stroke=1)) + ylim(0, .5) +
  geom_line(data=subset(plot_dat, Model=='NNLS'), aes(group=Tissue, color=Model), linetype=2) + 
  geom_line(data=subset(plot_dat, Model=='DL'), aes(group=Tissue, color=Model), linetype=2) +
  labs(title = 'Deep Learning vs NNLS patient 2224', x='Month', y='Fraction') + 
  scale_shape_manual(values=c(16, 8, 14))

ggsave('fraction_2224_nnls_vs_deep.jpg', width=4, height=4, dpi=300)