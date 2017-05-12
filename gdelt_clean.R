library(dplyr)
library(readxl)
library(data.table)
library(lubridate)

# country_codes
namo_country_codes = c('KU','BA','MU','QA','SA','AE','YM','IS','JO','LE','SY','EG','IR','TU','IZ')

# gdelt data
gdelt <- fread("Data/gdelt_20151201_20151231.csv", header = T,sep=",")
gdelt <- as.data.frame(gdelt)
  

# gdelt data 2005
gdelt2005 <- fread("2005/2005.csv", header = T, sep="\t")


# aggregate daily events
gdelt_max_globaleventid <- 
  gdelt %>%
  # only events in leading paragraphs, proxy of importance
  filter(IsRootEvent==1) %>%
group_by(SOURCEURL) %>% 
  summarise(max_id = max(GLOBALEVENTID,1,0)) 


gdelt_events <- 
  gdelt %>% 
  filter(GLOBALEVENTID%in%gdelt_max_globaleventid$max_id) %>% # remove duplicates
  # convert to date format, protest events, material conflict events
  # EventRootCode = 14 (protest); Quadclass = 4; material conflict
  mutate(
    event_date = as.Date(as.character(SQLDATE), "%Y%m%d"),
    protest = ifelse(EventRootCode == 14,1,0),
    material_conflict = ifelse(QuadClass == 4,1,0),
    rebellion = ifelse(Actor1Type1Code%in%c("REB","SEP","INS"),1,0),
    radicalism = ifelse(Actor1Type1Code== "RAD"| Actor1Type2Code=="RAD"| Actor1Type3Code=="RAD",1,0),
    negative_gs = ifelse(GoldsteinScale <= -3,1,0)) %>% 
  # removing misclassification of dates
  #filter(event_date > as.Date("20160101","%Y%m%d")) %>% 
  # group by date, country
  group_by(MonthYear,ActionGeo_CountryCode) %>%
  # get daily aggregates of features and predictors
  summarise(
    total_events = n(),
    protest_events = sum(protest),
    conflict_events = sum(material_conflict),
    rebellion_events = sum(rebellion),
    radicalism_events = sum(radicalism),
    min_gs = min(GoldsteinScale),
    max_gs = max(GoldsteinScale),
    prop_neg_gs = sum(negative_gs)/n()
  )


# empty dataset
xwalk <- matrix(NA,nrow = length(event_full_date)* length(namo_country_codes),ncol = 2)
xwalk <- as.data.frame(xwalk)
names(xwalk) <- c("event_date","country_code")

# all dates in analysis
event_full_date <- seq.Date(from = as.Date("20160101", "%Y%m%d"), to = as.Date("20160131", "%Y%m%d"),by = 1)
xwalk$event_date <- rep(event_full_date,length(namo_country_codes))
xwalk$country_code <- rep(namo_country_codes, each = length(event_full_date))

# merge xwalk of all dates to gdelt
gdelt_events_complete <- 
  xwalk %>% 
  left_join(gdelt_events, by = c("event_date" = "event_date", "country_code" = "ActionGeo_CountryCode")) %>%
  mutate_each(funs(na = ifelse(is.na(.),0,.)), -country_code,-event_date)


# material_conflict = gdelt %>% filter(QuadClass==4)
# 
# protest = gdelt %>% filter(EventRootCode==14)
# 
# rebellion = gdelt %>% filter(Actor1Type1Code%in%c("REB","SEP","INS"))
# 
# radicalism = gdelt %>% filter(Actor1Type1Code== "RAD"| Actor1Type2Code=="RAD"| Actor1Type3Code=="RAD")
# 
# radicalism = gdelt %>% filter(Actor1Type1Code== "RAD"| Actor1Type2Code=="RAD"| Actor1Type3Code=="RAD")

# material conflict als Abh‰ngige Variable
# protest als Abh‰ngige Variable
# rebellion inkl. rebels, seperatists, insurgents  als Abh‰ngige Variable (RAD und Protest ausschlieﬂen von Type2 und Type3)
# radicalism als Abh‰ngige Variable

# monatlich aggregation

# ground truth : systemic peach + HIIK

# prozentual oder detrending

