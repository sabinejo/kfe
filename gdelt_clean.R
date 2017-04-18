library(dplyr)
library(readxl)


# inputs
countries = read_excel("Input/Country_codes_NAMO.xlsx", sheet = 1)
# country_codes
namo_country_codes = c(countries$Country_2)
keep_namo <- function(cc_var) {
  if(cc%in%namo_country_codes){
    cc
  } else {
    NA
  }
}

# gdelt data
gdelt <- read.table("Data/gdelt_20170418.csv", header = T,sep=",")


# country variable 
country_code_vars <- 
  gdelt %>% 
  head() %>% 
  select(Actor1Geo_ADM1Code,Actor2Geo_ADM1Code,ActionGeo_ADM1Code) %>% # keep the country vars
  mutate_each(funs(cc = substr(.,1,2))) %>% # keep only first two characters
  select(-Actor1Geo_ADM1Code,-Actor2Geo_ADM1Code,-ActionGeo_ADM1Code) %>% # remove extra vars
  rowwise() %>% # rowwise comparison
  mutate_each(funs(namo = keep_namo(.))) %>% # keep only namo countries
  select(-Actor1Geo_ADM1Code_cc,-Actor2Geo_ADM1Code_cc,-ActionGeo_ADM1Code_cc) %>%  # remove extra vars
  rowwise() %>% 
  do(i = unique(.$Actor1Geo_ADM1Code_cc_namo,.$Actor2Geo_ADM1Code_cc_namo,.$ActionGeo_ADM1Code_cc_namo)).Last.value 



gdelt %>% 
  group_by()
