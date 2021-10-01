
smote_single_class <- function(data, class_var, class_value, samples = 500) {
  class_var <- enquo(class_var)
  
  class_data <- data %>% 
    filter(!!class_var == class_value)
  
  ## Keep enough samples of the "other" class for SMOTE to generate data separable from those
  not_class_data <- data %>% 
    filter(!!class_var != class_value) %>% 
    mutate(!!class_var := "Other") %>% 
    sample_n(samples)
  
  combined_data <- rbind(class_data, not_class_data) 
  
  if(nrow(class_data) >= samples) {
    class_data
  } else {
    ## Neighbourhood size arrived at by trial and error
    generated <- smotefamily::SMOTE(combined_data %>% select(-c(!!class_var)),
                                    target = combined_data %>% select(!!class_var),
                                    K = 10)$syn_data
    generated %>% 
      rename(!!class_var := class)
  }
}

upsample_small_cities <- function(data) {
  ## Do upsampling only for the cities with relatively tiny sample size
  small_sample_cities <- data %>% 
    count(city) %>% 
    mutate(n = n / sum(n)) %>% 
    filter(n < 0.1) %>% 
    pull(city)
  
  data <- data %>%
    select(city, slum_size, slum_area, slum_land_shape)
  
  processed_data <- data %>% 
    filter(!(city %in% small_sample_cities))
  
  for(city_name in small_sample_cities) {
    upsampled <- smote_single_class(data, city, city_name)
    processed_data <- rbind(processed_data, upsampled)
  }
  
  processed_data %>% 
    mutate(
      city_size = "Small",
      slum_density = slum_size / slum_area
    )
}
