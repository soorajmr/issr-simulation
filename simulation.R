library(tidyverse)
library(FinCal)

## Change only this count if you want to change how many data points are generated.
SIMULATION_COUNT <- 5000

rent_yearly_increase <- 0.05
average_occupancy <- 0.75
npv_discount_rate <- 0.15

gen_data_from_bins <- function(distrib_data, 
                               samples = SIMULATION_COUNT,
                               density_var = density) {
  ## Construct a smooth density function and then sample from it
  ## 'adjust' parameter arrived at by trial and error
  dens <- density((distrib_data$bin_low + distrib_data$bin_high) / 2,
                  weights = distrib_data$density, adjust = 0.8,
                  from = min(distrib_data$bin_low),
                  to = max(distrib_data$bin_high))
  
  sample(dens$x, samples, replace = TRUE, prob = dens$y)
}

gen_data_from_range_uniform <- function(r, n = SIMULATION_COUNT) {
  runif(n, r$min, r$max)
}

gen_data_constant <- function(val, n = SIMULATION_COUNT) {
  rep(val, n)
}

generate_data <- function(initial_data, city_type, n = SIMULATION_COUNT) {
  data <- initial_data[[city_type]]
  
  data %>%
    group_by(city) %>% 
    sample_n(n, replace = TRUE) %>% 
    mutate(
      additional_hh = gen_data_from_range_uniform(additional_hh, n),
      allowable_density_cap = gen_data_constant(150, n),
      floor_area_ratio = gen_data_from_range_uniform(floor_area_ratio, n),
      building_height_cap = gen_data_constant(15, n),
      redev_house_size = gen_data_from_range_uniform(redev_house_size, n),
      constr_cost_redev = gen_data_from_bins(constr_cost_redev, n),
      constr_cost_prem_housing = gen_data_from_bins(constr_cost_prem_housing, n),
      constr_cost_commercial = gen_data_from_bins(constr_cost_commercial, n),
      sale_price_building = gen_data_from_bins(sale_price_building[[city_type]], n),
      sale_price_rights = gen_data_from_bins(sale_price_rights[[city_type]], n),
      cost_transit_accommodation = gen_data_from_bins(cost_transit_accommodation[[city_type]], n),
      subsidy_pmay = gen_data_constant(subsidy_pmay_current, n),
      cost_inflation_factor = gen_data_from_bins(cost_inflation_factor, n),
      commercial_rent = gen_data_from_bins(commercial_rent[[city_type]], n)
    ) %>% 
    ungroup()
}

calc_yearly_cashflow <- function(commercial_rent, area, years) {
  growth_matrix <- 0:(years - 1) %>% 
    purrr::map(function(n) {(1 + rent_yearly_increase) ^ n}) %>% unlist()
  
  psqft_yearly_rent <- commercial_rent %*% t(growth_matrix) * 12
  
  # In crores of Rs.
  area * psqft_yearly_rent * average_occupancy / 10^7
}

calc_npv <- function(commercial_rent, area, initial_investment, years = 30) {
  yearly_cashflow <- calc_yearly_cashflow(commercial_rent, area, years)
  apply(cbind(initial_investment, yearly_cashflow), 1,
        function(x){FinCal::npv(npv_discount_rate, x)})
}

calc_irr <- function(commercial_rent, area, initial_investment, years = 30) {
  yearly_cashflow <- calc_yearly_cashflow(commercial_rent, area, years)
  apply(cbind(initial_investment, yearly_cashflow), 1,
        function(x){ifelse(x[2] == 0, 0, FinCal::irr(x))})
}


emi <- function(p, r, n) {
  p * r * (1 + r)^n / ((1 + r)^n - 1 )
}

calc_irr_sale <- function(revenue, cost) {
  loan_interest <- 0.16
  loan_tenure_months <- 36
  
  cost_yearly <- cost %*% t(c(0.10, 0.25, 0.30, 0.25, 0.10, 0))
  promoters_equity_yearly <- cost %*% t(c(0.10, 0.05, 0.01, 0.01, 0, 0))
  revenue_yearly <- revenue %*% t(c(0, 0.05, 0.25, 0.50, 0.15, 0.05)) + promoters_equity_yearly
  surplus_yearly <- revenue_yearly - cost_yearly
  total_deficit <- apply(surplus_yearly, 1, function(x){sum(if_else(x < 0, -1 * x, 0))})
  loan_amt <- total_deficit * 1.2
  loan_repay_amt <- emi(loan_amt, loan_interest / 12, loan_tenure_months) * loan_tenure_months
  loan_inflow <- loan_amt %*% t(c(0, 0.70, 0.30, 0, 0, 0))
  loan_outflow <- loan_repay_amt %*% t(c(0, 0.05, 0.25, 0.60, 0.10, 0))
  yearly_cashflow <- revenue_yearly - cost_yearly + loan_inflow - loan_outflow - promoters_equity_yearly
  
  apply(yearly_cashflow, 1,
        function(x){
          i <- NA  
          i <- try(jrvFinance::irr(x))
          if(is.na(i)){ 
            # No solution for IRR. Set to - 100%
            i <- -1
          }
          i
        })
}

calculate_profit <-  function(data, city_type) {
  data %>% 
    mutate(
      slum_redev_housing_area = round(slum_size * (1 + additional_hh), 0) * redev_house_size,
      penalty_for_shape = ifelse(slum_land_shape <= 0.03, 1, 35 * slum_land_shape),
      total_buildable_area = slum_area / penalty_for_shape * floor_area_ratio * 10000,
      commercial_construction_area = if_else(total_buildable_area > slum_redev_housing_area,
                                             total_buildable_area - slum_redev_housing_area, 0),
      infeasible = ifelse(total_buildable_area < slum_size * redev_house_size, TRUE, FALSE),
      slum_redev_housing_area = ifelse(total_buildable_area < slum_redev_housing_area,
                                       total_buildable_area, slum_redev_housing_area),
      tdr_generated = slum_redev_housing_area,
      redev_housing_constr_cost_total = slum_redev_housing_area * constr_cost_redev / 10^7,
      transit_accom_cost_total = slum_size * cost_transit_accommodation / 10^7,
      revenue_sales = sale_price_building * commercial_construction_area / 10^7,
      revenue_tdr = sale_price_rights * tdr_generated / 10^7,
      pmay_subsidy_total = round(slum_size * (1 + additional_hh), 0) * subsidy_pmay / 10^7,
      
      ## Revenue and profit assuming sales of premium housing
      prem_housing_constr_cost_total = commercial_construction_area * 
        constr_cost_prem_housing / 10^7,
      total_revenue = revenue_sales + revenue_tdr + pmay_subsidy_total,
      total_cost_sales = redev_housing_constr_cost_total +
        prem_housing_constr_cost_total + transit_accom_cost_total,
      total_cost_sales = total_cost_sales * (1 + cost_inflation_factor),
      profit_sale = (total_revenue - total_cost_sales) / total_cost_sales * 100, # Simplistic profit calculation
      irr_sale = calc_irr_sale(total_revenue, total_cost_sales), ## Considering cash flow
      
      ## NPV and IRR assuming rent inflow (Assuming rental from commercial buildings)
      commercial_constr_cost_total = commercial_construction_area * constr_cost_commercial / 10^7,
      total_cost_rental = redev_housing_constr_cost_total + 
        commercial_constr_cost_total + transit_accom_cost_total,
      total_cost_rental = total_cost_rental * (1 + cost_inflation_factor),
      
      initial_investment = revenue_tdr + pmay_subsidy_total - total_cost_rental,
      npv_rent = calc_npv(commercial_rent, commercial_construction_area, initial_investment),
      irr_rent = 0#calc_irr(commercial_rent, commercial_construction_area, initial_investment)
    )
}
