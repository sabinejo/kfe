setwd(data_wd)
## Variable construction for GDP ##
# Load data
data <- read_excel("GDP_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3,na = "n/a")

tdata <- gather(data,YEAR,GDP, `1960`:ncol(data))
data <- data.frame(row.names = c(1:nrow(tdata)))
data$COUNTRY <- tdata$`Country Name`
data$ISO <- tdata$`Country Code`
data$YEAR <- as.numeric(as.character(tdata$YEAR))
data$GDP <- tdata$GDP

rm(tdata)

GDP <- merge(id_mat,data, by.x=c("ISO3C","YEAR"), by.y=c("ISO","YEAR"),all.x=T)
GDP <- flp.impute(GDP,1,12)

GDP$GDP[which(GDP$COUNTRY.x=="Argentina")] <- rowMeans(cbind(GDP$GDP[which(GDP$COUNTRY.x=="Chile")],GDP$GDP[which(GDP$COUNTRY.x=="Brazil")]))
GDP$GDP[which(GDP$COUNTRY.x=="Myanmar")]   <- GDP$GDP[which(GDP$COUNTRY.x=="Bangladesh")]
GDP$GDP[which(GDP$COUNTRY.x=="Syrian Arab Republic")]   <- GDP$GDP[which(GDP$COUNTRY.x=="Egypt")]
GDP$GDP[which(GDP$COUNTRY.x=="Somalia")]   <- 1800 # Last known estimate from CIA world factbook
GDP$GDP[which(GDP$COUNTRY.x=="Korea, Democratic People's Republic of")]   <- 600 # Last known estimate from CIA world factbook

GDP$GDP <- log(GDP$GDP)
GDP$GDP <- scale010(GDP$GDP,1)

data <- subset(GDP, select = c(GDP, ISO3C, YEAR))
colnames(data)[1] <- "GDP_CAP"
rm(GDP)
save.image("../PROCESSED/GDP.Rdata")