setwd(data_wd)
#### Read data ####
data <- read_excel("CORRUPT_ORIG.xlsX", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0,na="..")
data <- data[1:(nrow(data)-2),]

# Fix names - Splits the names and extracts only the numeric year
colnames(data)[5:ncol(data)] <- colsplit(colnames(data)[5:ncol(data)], split=" ", c("YEAR","TRASH"))[,1]

# Gather to country-year units
tdata <- gather(data,YEAR,CORRUPT, `1996`:ncol(data))

data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO <- tdata$`Country Code`
data2$YEAR <- as.character(tdata$YEAR)
data2$CORRUPT <- tdata$CORRUPT

CORRUPT <- data2
rm(data,data2,tdata)
#### Bind to id_mat ####

# Merging by ISO, so rename those that don't match

CORRUPT$ISO[which(CORRUPT$ISO=="ZAR")] <- "COD"
CORRUPT$ISO[which(CORRUPT$ISO=="WBG")] <- "PSE"
CORRUPT$ISO[which(CORRUPT$ISO=="TMP")] <- "TLS"

# Merge
mdata <- merge(id_mat, CORRUPT, by.x = c("ISO3C","YEAR"), by.y = c("ISO","YEAR"), all.x=T)

#### Missing values ####
# Impute using previous known values
mdata <- flp.impute(mdata, 1, 12)

# Enforce a maximum level of corruption control (AUS CAN CHE NOR NZL SGP are forced to a lower level)
mdata$CORRUPT[which(mdata$CORRUPT> sqrt((min(mdata$CORRUPT))^2) )] <- sqrt((min(mdata$CORRUPT))^2)

# Rescale from 0 to 10 where a higher corrupt score = a lower normalized score
mdata$CORRUPT <- scale010(mdata$CORRUPT,1)

data <- subset(mdata,select = c("CORRUPT","YEAR","ISO3C"))

rm(mdata, CORRUPT)
save.image("../PROCESSED/CORRUPT.Rdata")


