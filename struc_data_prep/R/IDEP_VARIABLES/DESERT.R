setwd(data_wd)
# Data
data <- read.dta("RUGGED_ORIG.dta")

data2 <- data.frame(row.names = c(1:nrow(data)))
data2$COUNTRY <- data$country
data2$ISO3C <- data$isocode
data2$DESERT <- data$desert

data <- data2

rm(data2)

# merge 
data <- merge(id_mat, data, by.x = c("ISO3C"), by.y = c("ISO3C"), all.x=T)

# impute

ddata <- flp.impute(data,1,12)

data <- subset(ddata, select = c(DESERT,ISO3C, YEAR))

save.image("../PROCESSED/DESERT.Rdata")

