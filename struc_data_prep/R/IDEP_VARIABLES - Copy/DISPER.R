setwd(data_wd)
#### Var construction - DISPER ####
# Data
data <- read.csv('DISPER_ORIG.csv')
data<-subset(data,select = c(ccode,country,year,GC10))
data$country <- as.character(data$country)

# Retrieve set containing only max score for each country year
data <- aggregate(data,by = list(data$ccode,data$country,data$year),FUN = max)

# Load ID matrix and merge to subset wanted info
mdata <- merge(id_mat, data, by.x = c("COWN","YEAR"), by.y = c("ccode","year"), all.x=T)

# Impute first and last values if any are missing by repeating the first or last available data point
mdata <- flp.impute(mdata,4,15)

# Any countries still left missing are scored 0
for (i in (unique(mdata$COUNTRY[which(is.na(mdata$GC10))]))){
  mdata$GC10[mdata$COUNTRY==i] <- 0
}

data <- subset(mdata, select = c("GC10","YEAR","ISO3C"))
rm(i,mdata)
colnames(data)[1]<- "DISPER"

# Rescale
data$DISPER <- scale010(data$DISPER,0)

save.image("../PROCESSED/DISPER.Rdata")
