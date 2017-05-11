setwd(data_wd)
## Terrorism ##
# Read data
data <- read_excel("TERROR_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,na="..")

namo_country = c("Bahrain", "Egypt","Iraq","Israel","Jordan","Kuwait","Lebanon",
                 "Oman","Qatar","Saudi Arabia","Syrian Arab Republic","Turkey","United Arab Emirates","Yemen","Iran (Islamic Republic of)")

detach(package:dplyr) 
library(dplyr)

data_years <- 
  data %>%
  filter(iyear > 1988) %>% 
  filter(iday > 0) %>%
  filter(country_txt%in%namo_country) %>%
  select(iyear,country_txt,nkill, nwound) %>% 
  # mutate(imonth_n = ifelse(nchar(as.character(imonth))==1,paste0("0",imonth),imonth),
  #        date_var = as.Date(paste0(iyear,imonth_n,iday),"%Y%m%d")
  # )%>%
  group_by(iyear,country_txt) %>%
  summarise(
    nkill_sum = sum(nkill, na.rm = T),
    nwound_sum = sum(nkill,na.rm = T)
  )



# 
data2 <- data.frame(row.names = c(1:nrow(data_years)))
data2$COUNTRY <- data_years$country_txt
data2$YEAR <- data_years$iyear
data2$TERROR_KILL <- data_years$nkill_sum
data2$TERROR_WOUND <- data_years$nwound_sum


# merge 
bdata <- merge(id_mat, data2, by.x = c("COUNTRY","YEAR"), by.y = c("COUNTRY","YEAR"), all.x=T)

rm(data2)

# impute
bdata <- flp.impute(bdata,1,11)
bdata <- flp.impute(bdata,1,12)


# scale
bdata$TERROR_KILL <- scale010(bdata$TERROR_KILL,0)
bdata$TERROR_WOUND <- scale010(bdata$TERROR_WOUND,0)

data <- subset(bdata, select = c(TERROR_KILL, ISO3C, YEAR))


save.image("../PROCESSED/TERROR_KILL.Rdata")
