setwd(data_wd)
## Var construction REG_P2 ##
# Read data
data <- read_excel("REG_P2_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0,na="..")
data <- subset(data, year>=1989)
data <- data[order(data$ccode, data$year),]

# Country code issues to be fixed before merge
data$ccode[which(data$country=="Serbia")]   <- 345
data$ccode[which(data$country=="Vietnam")]  <- 816
data$ccode[which(data$country=="Ethiopia")] <- 530

# Merge
mdata <- merge(id_mat, data, by.x=c("COWN","YEAR"),by.y=c("ccode","year"),all.x=T)

# Missing data
# Palestine - No data available.
mdata$polity2[which(mdata$COUNTRY=="Palestine, State of")] <- -2
# Russia 1991 - Code with Soviet Union's value
mdata$polity2[which(mdata$COUNTRY=="Russian Federation" & mdata$YEAR==1991)] <- 0
# Lebanon - Missing midrange. Replace with 4
mdata$polity2[which(mdata$COUNTRY=="Lebanon")][2:16] <- 4

data <- subset(mdata, select = c(polity2,ISO3C,YEAR))
colnames(data)[1] <- c("REG_P2")

# Impute remaining by using closest available data
data <- flp.impute(data,2,1)

rm(mdata)

data$REG_P2 <- scale010(data$REG_P2,1)

save.image("../PROCESSED/REG.Rdata")
