setwd(data_wd)
## Variable construction MORT ##
# Read data
data <- read_excel("MILEX_ORIG.xlsx", sheet = 5, col_names = TRUE, col_types = NULL,skip = 5,na="..")

tdata <- gather(data,YEAR,MILEX, `1949`:ncol(data))
data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$Country
data$YEAR <- as.numeric(as.character(tdata$YEAR))
data$MILEX <- as.numeric(tdata$MILEX)

####  bind to id_mat ####
data$COUNTRY[which(data$COUNTRY=="Iran")]   <- "Iran (Islamic Republic of)"
data$COUNTRY[which(data$COUNTRY=="Syria")]   <- "Syrian Arab Republic"


data <- merge(id_mat, data, by.x = c("COUNTRY","YEAR"), by.y = c("COUNTRY","YEAR"), all.x=T)
rm(tdata)

data <- flp.impute(data,1,11)

data$MILEX <- log(data$MILEX)

data$MILEX <- scale010(data$MILEX,0)

data <- subset(data, select = c(MILEX,ISO3C, YEAR))

save.image("../PROCESSED/MILEX.Rdata")








