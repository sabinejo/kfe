setwd(data_wd)
## UNEMP ##
# Data
data <-
  read_excel(
    "UNEMP_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3
  )

tdata <- gather(data,YEAR,UNEMP, `1989`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO3C <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$UNEMP <- tdata$UNEMP

data <- data2
rm(data2,tdata)

data <- merge(id_mat, data, by=c("ISO3C", "YEAR"), all.x=T)
data<-flp.impute(data,1,12)

data$UNEMP[which(data$COUNTRY.x == "South Sudan")] <-
  data$UNEMP[which(data$COUNTRY.x == "Sudan")][23:26]
data$UNEMP[which(data$COUNTRY.x == "Djibouti")] <- rowMeans(cbind(
  data$UNEMP[which(data$COUNTRY.x == "Ethiopia")],
  data$UNEMP[which(data$COUNTRY.x == "Sudan")],
  data$UNEMP[which(data$COUNTRY.x == "Somalia")],
  c(NA,NA,NA,NA,data$UNEMP[which(data$COUNTRY.x == "Eritrea")])
),na.rm = T)

# Enforce minimum value (because no one has 0.2% unemployment, and also to facilitate logging)
data$UNEMP[which(data$UNEMP<1)] <- 1
data$UNEMP <- log(data$UNEMP)

data$UNEMP <- scale010(data$UNEMP,0)

data <- subset(data, select = c(UNEMP, ISO3C, YEAR))

save.image("../PROCESSED/UNEMP.Rdata")
