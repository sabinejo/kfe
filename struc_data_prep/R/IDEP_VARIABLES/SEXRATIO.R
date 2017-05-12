setwd(data_wd)

# Large set, will take 20-30 seconds to read
data <- read_excel("SEXRATIO_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,skip = 16)

data <- cbind(data[,3],data[,5:18])

# Fix names - Splits the names and extracts only the numeric year
colnames(data)[3:ncol(data)] <- colsplit(colnames(data)[3:ncol(data)], split="-", c("TRASH","YEAR"))[,2]

# transpose
tdata <- gather(data,YEAR,SEXRATIO, `1985`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata[,1]
data2$ISO3N <- tdata$`Country code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$SEXRATIO <- tdata$SEXRATIO

data <- data2
data <- unique(data)
rm(data2,tdata)

data <- merge(id_mat, data, by=c("ISO3N", "YEAR"), all.x=T)
data<-flp.impute(data,1,12)

# rescale
data$SEXRATIO <- scale010(data$SEXRATIO,0)

data <- subset(data, select = c(SEXRATIO, ISO3C, YEAR))

save.image("../PROCESSED/SEXRATIO.Rdata")
