setwd(data_wd)

data <- read.csv("../R/temp_ybb.csv")

#
data$POP <- rowSums(as.matrix(data[,13:114]),na.rm=T)
#
data <- subset(data, select = c(POP, ISO3C, YEAR))
data <- data[order(data$ISO3C, data$YEAR),]
#write.xlsx(data, "../unscaled_data.xlsx", sheetName="POP", 
#           col.names=TRUE, row.names=F, append=T, showNA=TRUE)


data$POP <- log(data$POP)

data$POP <- scale010(data$POP,0)

#data <- subset(data, select = c(POP, ISO3C, YEAR))
save.image("../PROCESSED/POP.Rdata")
