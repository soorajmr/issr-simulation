library(ggplot2)
library(gridExtra)
library(scales)
library(ggridges)
library(treeheatr)

plot_density_ridges <- function(data, plot_var, plot_var_lab, title = "") {
  plot_var <- enquo(plot_var)
  
  data %>% 
    group_by(city) %>% 
    mutate(
      median_var = median(if_else(`Data Processing` == "Imputation and Upsampling",
                                      !!plot_var, NaN),
                              na.rm = TRUE)
    ) %>% 
    ungroup() %>% 
    ggplot(aes(x = !!plot_var, y = reorder(city, median_var))) +
    geom_density_ridges(alpha = 0.6) +
    labs(x = plot_var_lab, y = "Cities: Probability Density", title = title) +
    facet_wrap(~`Data Processing`) +
    theme_minimal(base_size = 12) +
    theme(axis.text.y = element_text(vjust = 0))
}

## 90% interval of the variables
get_var_ranges_sale <- function(data) {
  data %>% 
    select(city, slum_land_shape, slum_density, floor_area_ratio, constr_cost_prem_housing,
           sale_price_building, sale_price_rights) %>% 
    pivot_longer(cols = -city, names_to = "variable") %>% 
    group_by(city, variable) %>% 
    summarise(
      low = quantile(value, c(0.05)),
      high = quantile(value, c(0.95)),
      median = median(value)
    ) 
}

## 90% interval of the variables
get_var_ranges_rent <- function(data) {
  data %>% 
    select(city, slum_land_shape, slum_density, floor_area_ratio, constr_cost_commercial,
           commercial_rent, sale_price_rights) %>% 
    pivot_longer(cols = -city, names_to = "variable") %>% 
    group_by(city, variable) %>% 
    summarise(
      low = quantile(value, c(0.05)),
      high = quantile(value, c(0.95)),
      median = median(value)
    ) 
}

plot_errorbars <- function(data) {
  data %>% 
    ggplot() +
    geom_errorbarh(aes(y = fct_reorder(city, median_density),
                       xmin = low, 
                       xmax = high,
                       colour = type), position = "dodge", size = 1.3) +
    scale_x_continuous(limits = c(0, NA), labels = scales::comma) +
    scale_colour_manual(values = c("Profitable" = "#009E73", "Infeasible" = "#D55E00",
                                   "Not Profitable" = "#E69F00")) +
    facet_wrap(~variable, scales = "free_x") +
    labs(x = "", y = "", title = "5% Trimmed Range of the Variables") +
    theme_minimal() + 
    theme(axis.text = element_text(colour="black", size = 12),
          axis.text.x = element_text(angle = 15, hjust = 1))
}

get_var_limits_sale <- function(data, profit = irr_sale, threshold = 0.35) {
  profit = enquo(profit)
  
  cities <- data %>%
    group_by(city) %>%
    summarise(
      median_density = median(slum_density),
    )
  
  not_profitable <- data %>% 
    filter(!!profit <= threshold & !infeasible) %>% 
    get_var_ranges_sale() %>% 
    mutate(type = "Not Profitable")
  
  profitable <- data %>% 
    filter(!!profit > threshold & !infeasible)  %>% 
    get_var_ranges_sale() %>% 
    mutate(type = "Profitable")
  
  infeasible <- data %>% 
    filter(infeasible)  %>% 
    get_var_ranges_sale() %>% 
    mutate(type = "Infeasible")
  
  not_profitable %>% 
    rbind(profitable) %>%
    rbind(infeasible) %>% 
    inner_join(cities, by = "city")
}

get_var_limits_rent <- function(data) {
  cities <- data %>%
    group_by(city) %>%
    summarise(
      median_density = median(slum_density),
    )
  
  not_profitable <- data %>% 
    filter(npv_rent <= 0 & !infeasible) %>% 
    get_var_ranges_rent() %>% 
    mutate(type = "Not Profitable")
  
  profitable <- data %>% 
    filter(npv_rent > 0 & !infeasible)  %>% 
    get_var_ranges_rent() %>% 
    mutate(type = "Profitable")
  
  infeasible <- data %>% 
    filter(infeasible)  %>% 
    get_var_ranges_rent() %>% 
    mutate(type = "Infeasible")
  
  not_profitable %>% 
    rbind(profitable) %>%
    rbind(infeasible) %>% 
    inner_join(cities, by = "city")
}

plot_points <- function(data, x_name, y_name) {
  ggplot(data) +
    geom_point(aes(x = x, y = y, colour = profitability), alpha = 0.5) +
    scale_colour_manual(values = c("grey", "#D55E00", "#009E73")) +
    scale_y_continuous(labels = scales::comma) +
    labs(x = x_name, y = y_name) +
    facet_wrap(~city, ncol = 5, scales = "free_x") +
    theme_minimal() +
    theme(axis.text = element_text(colour="black", size = 12),
          axis.text.x = element_text(angle = 15, hjust = 1))
}

profitabe_range_scatter <- function(data, x, y,
                                    profit_var, threshold,
                                    profit_descr, no_profit_descr) {
  xvar <- enquo(x)
  yvar <- enquo(y)
  profit_var <- enquo(profit_var)
  
  cities <- data %>%
    group_by(city) %>%
    summarise(
      median_density = median(slum_density),
    )
  
  data_plot <- data %>%
    inner_join(cities, by = "city") %>% 
    mutate(
      profitability = if_else(infeasible, "Infeasible",
                              if_else(!!profit_var > threshold, 
                                      profit_descr, no_profit_descr)),
      city = fct_reorder(city, -median_density),
      x = !!xvar,
      y = !!yvar
    )
  
  p1 <- data_plot %>% filter(city_size == "Large") %>% plot_points(xvar, yvar)
  p2 <- data_plot %>% filter(city_size == "Small") %>% plot_points(xvar, yvar)
  grid.arrange(p1, p2, ncol = 1, heights = c(1, 2))
} 

profitabe_range_scatter_sale <- function(data, x, y) {
  x <- enquo(x)
  y <- enquo(y)

  profitabe_range_scatter(data, !!x, !!y, irr_sale, 0.35, "IRR > 35%", "IRR <= 35%")
} 

profitabe_range_scatter_rent <- function(data, x, y) {
  x <- enquo(x)
  y <- enquo(y)
  
  profitabe_range_scatter(data, !!x, !!y, npv_rent, 0, "NPV > 0", "NPV <= 0")
} 

plot_heat_tree <- function(data) {
  heat_tree(data,
            target_lab = "Redevelopment Outcome",
            terminal_vars = list(size = 0),
            target_legend = TRUE,
            print_eval = TRUE,
            metrics = yardstick::metric_set(yardstick::accuracy),
            panel_space = 0.02,
            target_space = 0.3,
            tree_space_bottom = 0.1,
            heat_rel_height = 0.25,
            lev_fac = 1,
            par_node_vars = list(
              label.size = 0.3,
              line_list = list(aes(label = splitvar)),
              line_gpar = list(list(size = 12)),
              id = 'inner'),
            edge_text_vars = list(size = 4,
                                  mapping = aes(label = paste(substr(breaks_label,
                                                                     start = 1,
                                                                     stop = 15))),
                                  alpha = 0.8))
}
