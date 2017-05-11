setwd(data_wd)
# Data
data <- read.dta("PublicDataSet_ReligiousRestrictions_2007to2014.dta")

# Government Restrictions Index 0: low level of government restrictions and 10 very high
# Social Hostilities Index 0: low impediments to religious beliefs and practices 10 very high

tdata <-
  data %>% 
  select(Ctry_EditorialName,Question_Year,GRI,SHI)

data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$Ctry_EditorialName
data$YEAR <- tdata$Question_Year
data$GRI <- tdata$GRI
data$SHI <- tdata$SHI

data$COUNTRY[which(data$COUNTRY=="Iran")]   <- "Iran (Islamic Republic of)"
data$COUNTRY[which(data$COUNTRY=="Syria")]   <- "Syrian Arab Republic"


# merge 
bdata <- merge(id_mat, data, by.x = c("COUNTRY","YEAR"), by.y = c("COUNTRY","YEAR"), all.x=T)
rm(tdata)

# impute
bdata <- flp.impute(bdata,1,11)
bdata <- flp.impute(bdata,1,12)

data <- subset(bdata, select = c(GRI,ISO3C, YEAR))

save.image("../PROCESSED/GRI.Rdata")

