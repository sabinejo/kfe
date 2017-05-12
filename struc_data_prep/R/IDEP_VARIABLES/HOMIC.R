setwd(data_wd)
## HOMIC construction ##
# Read data
data <- read_excel("HOMIC_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3,na="..")

tdata <- gather(data,YEAR,HOMIC, `1960`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO <- tdata$`Country Code`
data2$YEAR <- as.character(tdata$YEAR)
data2$HOMIC <- tdata$HOMIC

rm(tdata)
#### Load and bind to id_mat ####
data <- merge(id_mat, data2, by.x = c("ISO3C","YEAR"), by.y = c("ISO","YEAR"), all.x=T)

# Impute first and last values if any are missing by repeating the first or last available data point
data <- flp.impute(data,1,12)

#Subset
data <- subset(data, select = c(HOMIC, ISO3C, YEAR))
rm(data2)

#write.xlsx(data, "../unscaled_data.xlsx", sheetName="HOMIC", 
#           col.names=TRUE, row.names=F, append=F, showNA=TRUE)

#Limit
data$HOMIC[which(data$HOMIC>50)] <- 50
# Set 0 to 1 to facilitate logging
data$HOMIC[which(data$HOMIC<1)] <- 1
# Log
data$HOMIC <- log(data$HOMIC)

#Rescale
data$HOMIC <- scale010(data$HOMIC,0)

save.image("../PROCESSED/HOMIC.Rdata")
