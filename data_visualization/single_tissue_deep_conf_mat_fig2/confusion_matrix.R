#05/24/2023 Fengyao Yan
#Plot the confusion matrix to show the performance of DL model when predicting single tissue.

library(cvms)
library(data.table)
library(ggplot2)

pred_dat <- fread('../../data/single_t/pred.csv', data.table = FALSE)
true_dat <- fread('../../data/single_t/true.csv', data.table = FALSE)

dat <- cbind(pred_dat, true_dat)
colnames(dat) <- c('y_pred_name', 'y_true_name')

conf_mat <- confusion_matrix(targets = dat$y_true_name, predictions = dat$y_pred_name)

plot_confusion_matrix(conf_mat$`Confusion Matrix`[[1]], 
                      add_normalized = FALSE, 
                      add_row_percentages = FALSE, 
                      add_col_percentages = FALSE, 
                      add_sums = TRUE,
                      add_zero_shading = TRUE,
                      place_x_axis_above = FALSE,
                      rotate_y_text = TRUE) + 
  theme(axis.text.x = element_text(angle = 30, hjust=1), 
        axis.text.y=element_text(angle=0, vjust=0.5, hjust=1),
        text = element_text(size = 13)) +
  labs(title='Confusion Matrix Single Tissue')

ggsave('confusion_matrix_single_tissue.jpg', height=5, width=5, dpi=300)