library(nnls)
library(data.table)
library(pbapply)
library(glue)

f_name_ref <- "../../data/raw/selected_gtex_top_1_NT_1_fc_3_data.csv"
dat <- fread(f_name_ref, data.table = FALSE)
dat <- dat[, -1]

exclude <- c("Adrenal Gland", "Fallopian Tube", "Vagina", "Salivary Gland")

dat <- dat[!dat$tissue %in% exclude, ]

ogs <- sort(unique(dat$tissue))

res <- data.frame(matrix(nrow = 0, ncol = ncol(dat) - 2))

colnames(res) <- colnames(dat[, 3:ncol(dat)])


for (og in ogs) {
    sub <- dat[dat$tissue == og, ]
    res[nrow(res) + 1, ] <- t(colMeans(sub[, 3:ncol(sub)], na.rm = TRUE))
}
rownames(res) <- ogs
ref_dat <- res

custom_data_folder = "/app"

for (custom_file in list.files(custom_data_folder)) {
    f_name <- glue("{custom_data_folder}/{custom_file}")
    mix_dat <- fread(f_name, data.table = FALSE)

    comm_names <- intersect(colnames(mix_dat), colnames(ref_dat))
    mix_dat <- mix_dat[, comm_names]
    ref_dat <- ref_dat[, comm_names]

    ref_dat <- log2(ref_dat + 1)
    mix_dat <- log2(mix_dat + 1)

    y_pred <- data.frame(matrix(ncol = length(ogs), nrow = 0))
    colnames(y_pred) <- ogs

    mse <- data.frame(matrix(ncol = length(ogs), nrow = 0))
    colnames(mse) <- ogs

    pcc <- data.frame(matrix(ncol = length(ogs), nrow = 0))
    colnames(pcc) <- ogs


    run_nnls <- function(i) {
        x <- ref_dat
        y <- mix_dat[i, ]
        mod1 <- nnls(t(x), t(y))
        return(mod1$x)
    }


    id_all <- 1:nrow(mix_dat)
    print("running nnls ...")
    res <- pblapply(FUN = run_nnls, id_all)

    for (i in id_all) {
        y_pred[i, ] <- res[[i]]
    }

    new_name <-
        glue("{custom_data_folder}/deconvolute_nnls_{custom_file}")

    write.csv(y_pred, new_name, row.names=FALSE)

    print(glue("Done deconvolute_nnls_{custom_file} ."))
}
