setwd("C:/Users/sunanda.garg/OneDrive - Accenture/Fun Projects/kfe/GCRI/data/ORIG_DATA_new/")
library(readxl)
library(dplyr)
## Variable construction MORT ##
# Read data
data <- read_excel("TERROR_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,na="..")

namo_country = c("Bahrain", "Egypt","Iran","Iraq","Israel","Jordan","Kuwait","Lebanon",
                 "Oman","Qatar","Saudi Arabia","Syria","Turkey","United Arab Emirates","Yemen")

data_daily <- 
  data %>%
  filter(iyear > 1988) %>% 
  filter(iday > 0) %>%
  filter(country_txt%in%namo_country) %>% 
  mutate(imonth_n = ifelse(nchar(as.character(imonth))==1,paste0("0",imonth),imonth),
         date_var = as.Date(paste0(iyear,imonth_n,iday),"%Y%m%d")
         )%>%
  group_by(date_var,country_txt) %>% 
  summarise(
    n_events = n(),
    nkill = sum(nkill),
    nwound = sum(nwound)
  )


data_years <- 
  data %>%
  filter(iyear > 1988) %>% 
  filter(iday > 0) %>%
  filter(country_txt%in%namo_country) %>% 
  mutate(imonth_n = ifelse(nchar(as.character(imonth))==1,paste0("0",imonth),imonth),
         date_var = as.Date(paste0(iyear,imonth_n,iday),"%Y%m%d")
  )%>%
  group_by(iyear,country_txt) %>% 
  summarise(
    n_events = n(),
    nkill = sum(nkill),
    nwound = sum(nwound)
  )
           
