setwd(data_wd)
## Variable construction GOV_EFF ##
# Read data
data <- read_excel("GOV_EFF_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0,na="..")

colnames(data)[5:ncol(data)] <- colsplit(colnames(data)[5:ncol(data)], split=" ", c("YEAR","TRASH"))[,1]

tdata <- gather(data,YEAR,GOV_EFF, `1996`:ncol(data))
data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$`Country Name`
data$ISO <- tdata$`Country Code`
data$YEAR <- as.numeric(as.character(tdata$YEAR))
data$GOV_EFF <- tdata$GOV_EFF

rm(tdata)
#### bind to id_mat ####

#Rename ISO of West Bank and Gaza to PSE
data$ISO[which(data$ISO=="WBG")] <- "PSE"
#Rename ISO of DRC to COD
data$ISO[which(data$ISO=="ZAR")] <- "COD"

mdata <- merge(id_mat, data, by.x = c("ISO3C","YEAR"), by.y = c("ISO","YEAR"), all.x=T)
mdata$COUNTRY.y<-NULL

# Impute first and last values if any are missing by repeating the first or last available data point
mdata <- flp.impute(mdata,1,11)

# Timor-Leste is completely missing use Indonesia's values.
mdata$GOV_EFF[which(mdata$COUNTRY.x=="Timor-Leste")] <- mdata$GOV_EFF[which(mdata$COUNTRY.x=="Indonesia" & mdata$YEAR>=2002)]

data <- subset(mdata, select = c(ISO3C, YEAR, GOV_EFF))
rm(mdata)

data$GOV_EFF <- scale010(data$GOV_EFF,1)

save.image("../PROCESSED/GOV_EFF.Rdata")
