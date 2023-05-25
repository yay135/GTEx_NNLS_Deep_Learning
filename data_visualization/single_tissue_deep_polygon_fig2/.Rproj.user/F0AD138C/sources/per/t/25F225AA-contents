#05/23/2023 Fengyao Yan
#plot a polygon rank to show the model performance.


# functions ---------------------------------------------------------------

.radial <- function(data, r0 = 0.2, r = 1, theta0 = pi/2){
  
  n <- ncol(dat) - 1
  theta <- seq(theta0, theta0 + 2 * pi, length.out = n + 1)[-(n + 1)]
  
  tb <- tibble(
    group = names(dat)[-1],
    x_min = r0 * cos(theta),
    y_min = r0 * sin(theta),
    x_max = (r0 + r) * cos(theta),
    y_max = (r0 + r) * sin(theta)
  ) %>%
    mutate(
      group = factor(group, levels = group)
    ) %>%
    gather(key, coord, 2:ncol(.)) %>%
    separate(key, into = c("axis", "endpoint"), sep = "_") %>%
    spread(axis, coord)
  
  return(tb)
}


.spiral <- function(data, r0 = 0.2, r = 1, theta0 = pi/2){
  
  n <- ncol(dat) - 1
  theta <- seq(theta0, theta0 + 2 * pi, length.out = n + 1)
  
  tb <- tibble(
    x = (r0 + r) * cos(theta),
    y = (r0 + r) * sin(theta)
  )
  
  return(tb)
}


.path <- function(data, r0 = 0.2, theta0 = pi/2){
  
  n <- ncol(dat) - 1
  theta <- seq(theta0, theta0 + 2 * pi, length.out = n + 1)
  
  tb <- data %>%
    rename(group = 1) %>%
    mutate(
      .circle = .[[2]],
    ) %>%
    gather(vars, vals, 2:ncol(.), factor_key = TRUE) %>%
    group_by(group) %>%
    mutate(
      x = (r0 + vals) * cos(theta),
      y = (r0 + vals) * sin(theta)
    ) %>%
    ungroup()
  
  return(tb)
}



# main --------------------------------------------------------------------

rm(list = ls())

library(data.table)
library(tidyverse)


dat <- tibble(
  ID = paste0("ID", 1:3),
  Chinese = c(90, 60, 70),
  Math = c(11, 89, 60),
  English = c(95, 60, 80),
  Physics = c(30, 100, 60),
  Chemical = c(40, 95, 70),
  Biology = c(60, 85, 85),
  History = c(90, 60, 70),
  Geography = c(90, 85, 85)
) %>%
  mutate(
    ID = factor(ID),
    across(2:ncol(.), scales::rescale, from = c(0, 100), to = c(0, 1))
  )

view(dat)
############### insert my data
metrics <- read.csv('../../data/single_t/metrics.csv')
print(rownames(metrics))
metrics <- metrics[metrics$Metrics != 'support', ]
view(metrics)

dat <- metrics

## radial
radial <- .radial(dat)


## spiral
spiral_q0 <- .spiral(dat, r = 0)
spiral_q1 <- .spiral(dat, r = 0.25)
spiral_q2 <- .spiral(dat, r = 0.5)
spiral_q3 <- .spiral(dat, r = 0.75)
spiral_q4 <- .spiral(dat, r = 1)


## data path
path <- .path(dat)


## labs
labx <- radial %>%
  filter(endpoint == "max") %>%
  transmute(
    x = x * 1.1,
    y = y * 1.1,
    label = group
  )

laby <- tibble(
  at = seq(0, 1, by = 0.25),
  x = 0,
  y = at + 0.2,
  label = scales::percent(at)
)

mycol <- structure(
  RColorBrewer::brewer.pal(nrow(dat), "Set1"),
  ############ insert my color
  names = as.character(dat$Metrics)
)

view(mycol)

ggplot() +
  geom_polygon(data = spiral_q4, aes(x = x,  y = y), size = 0.1, fill = "Gainsboro") +
  geom_polygon(data = spiral_q3, aes(x = x,  y = y), size = 0.1, fill = "white") +
  geom_polygon(data = spiral_q2, aes(x = x,  y = y), size = 0.1, fill = "Gainsboro") +
  geom_polygon(data = spiral_q1, aes(x = x,  y = y), size = 0.1, fill = "white") +
  geom_polygon(data = spiral_q0, aes(x = x,  y = y), size = 0.1, fill = "Gainsboro") +
  geom_path(data = spiral_q0, aes(x = x,  y = y), size = 0.1, color = "Gainsboro") +
  geom_path(data = spiral_q1, aes(x = x,  y = y), size = 0.1, color = "Gainsboro") +
  geom_path(data = spiral_q2, aes(x = x,  y = y), size = 0.1, color = "Gainsboro") +
  geom_path(data = spiral_q3, aes(x = x,  y = y), size = 0.1, color = "Gainsboro") +
  geom_path(data = spiral_q4, aes(x = x,  y = y), size = 0.1, color = "Gainsboro") +
  geom_path(data = radial, aes(x = x,  y = y, group = group), size = 0.1, color = "Gainsboro") +
  geom_path(data = path, aes(x = x,  y = y, group = group, color = group), size = 1) +
  geom_point(data = path, aes(x = x,  y = y, group = group, color = group), size = 3) +
  geom_text(data = labx, aes(x = x, y = y, label = label), size=3) +
  geom_text(data = laby, aes(x = x, y = y, label = label), angle = 0, size=3) +
  scale_x_continuous(expand = expansion(mult = c(0.1, 0.1))) +
  scale_color_manual(values = mycol) +
  coord_equal() +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    legend.margin = margin(-10, 0, 0, 0, unit = "pt"),
    legend.position = "bottom"
  ) +
  labs(color = NULL, title = 'Single Tissue Prediction Performance Metrics')

ggsave("result/ranking_ggplot_spider.jpg", width = 4, height = 4, dpi = 300)



# AUC plot -------------------------------------------------------------------------------------------------------


