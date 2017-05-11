setwd(data_wd)
## Variable constructions FUEL_EXP ##
# Data
data <- read_excel("FUEL_EXP_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3)

data$`Country Name`  <- as.factor(data$`Country Name`)
tdata <- gather(data,YEAR,FUEL_EXP, `1961`:ncol(data))

data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$`Country Name`
data$ISO <- tdata$`Country Code`
data$YEAR <- tdata$YEAR
data$FUEL_EXP <- tdata$FUEL_EXP
data$COUNTRY <- as.character(data$COUNTRY)
data$YEAR <- as.numeric(as.character(data$YEAR))

rm(tdata)

# Merge
data <- merge(id_mat, data, by.x = c("ISO3C","YEAR"), by.y = c("ISO", "YEAR"), all.x=T)

data <- flp.impute(data,1,12)

# Remaining missing filled with latest data from http://atlas.media.mit.edu/en/
data$FUEL_EXP[which(data$COUNTRY.x=="Afghanistan")] <- 6.8 
data$FUEL_EXP[which(data$COUNTRY.x=="Chad")] <- 96 
data$FUEL_EXP[which(data$COUNTRY.x=="Congo, the Democratic Republic of the")] <- 12
data$FUEL_EXP[which(data$COUNTRY.x=="Equatorial Guinea")] <- 92
data$FUEL_EXP[which(data$COUNTRY.x=="Lao People's Democratic Republic")] <- 4.7
data$FUEL_EXP[which(data$COUNTRY.x=="Liberia")] <- 2.9 
data$FUEL_EXP[which(data$COUNTRY.x=="Montenegro")] <- 2.8
data$FUEL_EXP[which(data$COUNTRY.x=="Sierra Leone")] <- 0
data$FUEL_EXP[which(data$COUNTRY.x=="Somalia")] <- 0 # 
data$FUEL_EXP[which(data$COUNTRY.x=="South Sudan")] <- 99.7 # 
data$FUEL_EXP[which(data$COUNTRY.x=="Uzbekistan")] <- 19.7 # 
data$FUEL_EXP[which(data$COUNTRY.x=="Palestine, State of")] <- 0 # 
data$FUEL_EXP[which(data$COUNTRY.x=="Korea, Democratic People's Republic of")] <- 49.9 # 

# Force 0 to 1 to facilitate logging
data$FUEL_EXP[which(data$FUEL_EXP<1)] <- 1

# Log
data$FUEL_EXP <- log(data$FUEL_EXP)

# rescale
data$FUEL_EXP <- scale010(data$FUEL_EXP,0)

# clean
data<- subset(data, select = c(FUEL_EXP, ISO3C, YEAR))

save.image("../PROCESSED/FUEL_EXP.Rdata")
