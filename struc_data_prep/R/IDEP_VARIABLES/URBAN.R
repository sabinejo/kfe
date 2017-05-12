setwd(data_wd)
## URBAN ##
# Data
data <-
  read_excel(
    "URBAN_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3
  )

tdata <- gather(data,YEAR,URBAN, `1989`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO3C <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$URBAN <- tdata$URBAN

data <- data2
rm(data2,tdata)

data <- merge(id_mat, data, by=c("ISO3C", "YEAR"), all.x=T)
data<-flp.impute(data,1,12)

# scale
data$URBAN <- scale010(data$URBAN,0)

data <- subset(data, select = c(URBAN, ISO3C, YEAR))

save.image("../PROCESSED/URBAN.Rdata")
