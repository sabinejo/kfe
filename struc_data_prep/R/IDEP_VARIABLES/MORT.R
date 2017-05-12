setwd(data_wd)
## Variable construction MORT ##
# Read data
data <- read_excel("MORT_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3,na="..")

tdata <- gather(data,YEAR,MORT, `1960`:ncol(data))
data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$`Country Name`
data$ISO <- tdata$`Country Code`
data$YEAR <- as.numeric(as.character(tdata$YEAR))
data$MORT <- tdata$MORT

####  bind to id_mat ####

data <- merge(id_mat, data, by.x = c("ISO3C","YEAR"), by.y = c("ISO","YEAR"), all.x=T)
rm(tdata)

data <- flp.impute(data,1,12)

data$MORT <- log(data$MORT)

data$MORT <- scale010(data$MORT,0)

data <- subset(data, select = c(MORT,ISO3C, YEAR))

save.image("../PROCESSED/MORT.Rdata")








