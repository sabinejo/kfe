setwd(data_wd)
## INEQ_SWIID ##
# Data
data <- read.dta("INEQ_SWIID_ORIG.dta")

# Means of the 100 GINI net imputations
means <- as.data.frame(rowMeans(data[4:103], na.rm = FALSE, dims = 1))

data <- cbind (data[,1:2],means)
colnames(data) <- c("COUNTRY","YEAR","INEQ_SWIID")
rm(means)

data$COUNTRY[which(data$COUNTRY=="Congo, Democratic Republic of")] <- "Congo, the Democratic Republic of the"
data$COUNTRY[which(data$COUNTRY=="Congo, Republic of")] <- "Congo"
data$COUNTRY[which(data$COUNTRY=="Iran")] <- "Iran, Islamic Republic of"
data$COUNTRY[which(data$COUNTRY=="Bolivia")] <- "Bolivia, Plurinational State of"
data$COUNTRY[which(data$COUNTRY=="Kyrgyz Republic")] <- "Kyrgyzstan"
data$COUNTRY[which(data$COUNTRY=="Lao")] <- "Lao People's Democratic Republic"
data$COUNTRY[which(data$COUNTRY=="Macedonia, FYR")] <- "Macedonia, the former Yugoslav Republic of"
data$COUNTRY[which(data$COUNTRY=="Moldova")] <- "Moldova, Republic of"
data$COUNTRY[which(data$COUNTRY=="Syria")] <- "Syrian Arab Republic"
data$COUNTRY[which(data$COUNTRY=="Tanzania")] <- "Tanzania, United Republic of"
data$COUNTRY[which(data$COUNTRY=="Venezuela")] <- "Venezuela, Bolivarian Republic of"
data$COUNTRY[which(data$COUNTRY=="Yemen, Republic of")] <- "Yemen"

data <- merge(id_mat,data, by=c("COUNTRY","YEAR"), all.x = T)

data <- flp.impute(data,1,11)

# Cuba is given regional average
data$INEQ_SWIID[which(data$COUNTRY=="Cuba")] <- rowMeans(cbind(
  data$INEQ_SWIID[which(data$COUNTRY=="Venezuela")],
  data$INEQ_SWIID[which(data$COUNTRY=="Bolivia, Plurinational State Of")],
  data$INEQ_SWIID[which(data$COUNTRY=="Brazil")],
  data$INEQ_SWIID[which(data$COUNTRY=="Mexico")],
  data$INEQ_SWIID[which(data$COUNTRY=="Chile")],
  data$INEQ_SWIID[which(data$COUNTRY=="Argentina")],
  data$INEQ_SWIID[which(data$COUNTRY=="Nicaragua")],
  data$INEQ_SWIID[which(data$COUNTRY=="Colombia")]
))

# Equatorial Guinea is given regional average
data$INEQ_SWIID[which(data$COUNTRY=="Equatorial Guinea")] <- rowMeans(cbind(
    data$INEQ_SWIID[which(data$COUNTRY=="Gabon")],
    data$INEQ_SWIID[which(data$COUNTRY=="Congo")],
    data$INEQ_SWIID[which(data$COUNTRY=="Nigeria")],
    data$INEQ_SWIID[which(data$COUNTRY=="Cameroon")],
    data$INEQ_SWIID[which(data$COUNTRY=="Central African Republic")]
))  

# Eritrea is given regional average
data$INEQ_SWIID[which(data$COUNTRY=="Eritrea")] <- rowMeans(cbind(
  data$INEQ_SWIID[which(data$COUNTRY=="Ethiopia")],
  data$INEQ_SWIID[which(data$COUNTRY=="Djibouti")],
  data$INEQ_SWIID[which(data$COUNTRY=="Sudan")]
))[5:26]

# Iraq and Libya are copied from Egypt
data$INEQ_SWIID[which(data$COUNTRY=="Iraq")]  <- data$INEQ_SWIID[which(data$COUNTRY=="Egypt")]
data$INEQ_SWIID[which(data$COUNTRY=="Libya")] <- data$INEQ_SWIID[which(data$COUNTRY=="Egypt")]
# More country copies
data$INEQ_SWIID[which(data$COUNTRY=="Palestine, State of")] <- data$INEQ_SWIID[which(data$COUNTRY=="Jordan")]
data$INEQ_SWIID[which(data$COUNTRY=="Myanmar")]             <- data$INEQ_SWIID[which(data$COUNTRY=="Cambodia")]
data$INEQ_SWIID[which(data$COUNTRY=="South Sudan")]         <- data$INEQ_SWIID[which(data$COUNTRY=="Sudan")][23:26]
data$INEQ_SWIID[which(data$COUNTRY=="Solomon Islands")]     <- data$INEQ_SWIID[which(data$COUNTRY=="Papua New Guinea")]
data$INEQ_SWIID[which(data$COUNTRY=="Korea, Democratic People's Republic of")] <- data$INEQ_SWIID[which(data$COUNTRY=="Cuba")]

# 
data$INEQ_SWIID[which(data$COUNTRY=="Bahrain")]              <- 41.1
data$INEQ_SWIID[which(data$COUNTRY=="Kuwait")]               <- 41.1
data$INEQ_SWIID[which(data$COUNTRY=="Oman")]                 <- 41.1
data$INEQ_SWIID[which(data$COUNTRY=="Qatar")]                <- 41.1
data$INEQ_SWIID[which(data$COUNTRY=="Saudi Arabia")]         <- 41.1
data$INEQ_SWIID[which(data$COUNTRY=="United Arab Emirates")] <- 41.1

# Rescale
data$INEQ_SWIID <- scale010(data$INEQ_SWIID,0)

data <- subset(data, select = c(INEQ_SWIID, ISO3C, YEAR))

save.image("../PROCESSED/INEQ_SWIID.Rdata")
