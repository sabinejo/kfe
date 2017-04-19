library(dplyr)
library(readxl)


# inputs
countries = read_excel("Input/Country_codes_NAMO.xlsx", sheet = 1)
# country_codes
namo_country_codes = c(countries$Country_2)

# gdelt data
gdelt <- read.table("Data/gdelt_20170419.csv", header = T,sep=",")

# aggregate daily events
gdelt_events <- 
  gdelt %>%
  # only events in leading paragraphs, proxy of importance
  filter(IsRootEvent==1) %>%  
  # convert to date format, protest events, material conflict events
  # EventRootCode = 14 (protest); Quadclass = 4; conflict
  mutate(
    event_date = as.Date(as.character(SQLDATE), "%Y%m%d"),
    protest = ifelse(EventRootCode == 14,1,0),
    material_conflict = ifelse(QuadClass == 4,1,0))%>% 
  # removing misclassification of dates
  filter(event_date > as.Date("20150101","%Y%m%d")) %>% 
  # group by date, country
  group_by(event_date,ActionGeo_CountryCode) %>%
  # get daily aggregates of features and predictors
  summarise(
    total_events = n(),
    protest_events = sum(protest),
    conflict_events = sum(material_conflict)
  )




