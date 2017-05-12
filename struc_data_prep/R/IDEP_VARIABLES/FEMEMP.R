setwd(data_wd)
## FEMEMP ##
# Data
data <-
  read_excel(
    "FEMEMP_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3
  )

tdata <- gather(data,YEAR,FEMEMP, `1989`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO3C <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$FEMEMP <- tdata$FEMEMP

data <- data2
rm(data2,tdata)

data <- merge(id_mat, data, by=c("ISO3C", "YEAR"), all.x=T)
data<-flp.impute(data,1,12)

# log
data$FEMEMP <- log(data$FEMEMP)

data$FEMEMP <- scale010(data$FEMEMP,1)

data <- subset(data, select = c(FEMEMP, ISO3C, YEAR))

save.image("../PROCESSED/FEMEMP.Rdata")
