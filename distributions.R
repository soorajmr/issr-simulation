## Distributions

# Fraction of additional househoulds to be accommodated
additional_hh = list(
  min = 0,
  max = 0.15
)

## Households per hectare
allowable_density_cap = 1000

# Building area / plot area
floor_area_ratio = list(
  min = 1.5,
  max = 3
)

## metres
building_height_cap = 15

# Sq. metre
redev_house_size = list(
  min = 42,
  max = 45
)

# Rs. per sq. metre
constr_cost_redev = data.frame(
  bin_low = c(10000, 15000, 20000, 25000),
  bin_high = c(15000, 20000, 25000, 30000),
  density = c(.11, .22, .56, .11)
)

# Rs. per sq. metre
constr_cost_prem_housing = data.frame(
  bin_low = c(20000, 30000, 45000, 60000, 75000),
  bin_high = c(30000, 45000, 60000, 75000, 90000),
  density = c(0.10, 0.24, 0.24, 0.37, 0.05)
)

# Rs. per sq. metre
constr_cost_commercial = data.frame(
  bin_low = c(20000, 30000, 60000, 90000, 120000),
  bin_high = c(30000, 60000, 90000, 120000, 150000),
  density = c(0.02, 0.58, 0.14, 0.18, 0.08)
)

# Sale price - premium housing Rs. per sq. metre
sale_price_building = list(
  small = data.frame(bin_low = c(22000, 30000, 50000),
                     bin_high = c(30000, 50000, 100000),
                     density = c(0.04, 0.79, 0.17)),
  large = data.frame(bin_low = c(25000, 30000, 50000, 100000, 200000),
                     bin_high = c(30000, 50000, 100000, 200000, 450000),
                     density = c(0.03, 0.31, 0.28, 0.21, 0.17))
)

# Rs. per sq. metre
sale_price_rights = list(
  small = data.frame(bin_low = c(0, 5000, 15000, 25000),
                     bin_high = c(5000, 15000, 25000, 55000),
                     density = c(0.7, 0.2, 0.06, 0.04)),
  large = data.frame(bin_low = c(0, 5000, 15000, 25000),
                     bin_high = c(5000, 15000, 25000, 55000),
                     density = c(0.2, 0.4, 0.3, 0.1))
)

# Per household
cost_transit_accommodation = list(
  small = data.frame(bin_low = c(48000, 72000, 96000),
                     bin_high = c(72000, 96000, 120000),
                     density = c(0.6, 0.3, 0.1)),
  large = data.frame(bin_low = c(72000, 96000, 120000, 144000, 180000),
                     bin_high = c(96000, 120000, 144000, 180000, 280000),
                     density = c(0.1, 0.3, 0.4, 0.18, 0.02))
)

# Per household
subsidy_pmay_current = 100000

# Additional miscellaneous cost items on top of construction cost
cost_inflation_factor = data.frame(
  bin_low = c(0.15, 0.20, 0.25),
  bin_high = c(0.2, 0.25, 0.30),
  density = c(0.3, 0.6, 0.1)
)

# Average commercial rent (INR/sqm./month): small and large cities.
# Using Knight Frank July-Dec 2018
commercial_rent <- list(
  small = data.frame(bin_low = c(50, 100, 150, 200, 250, 500, 1000),
                     bin_high = c(100, 150, 200, 250, 500, 1000, 2000),
                     density = c(0.06, 0.13, 0.1, 0.15, 0.41, 0.14, 0.01)),
  large = data.frame(bin_low = c(250, 500, 1000, 2000),
                     bin_high = c(500, 1000, 2000, 4000),
                     density = c(0.24, 0.47, 0.19, 0.1))
)
