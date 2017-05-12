setwd(data_wd)
## STRUCT variable contruction ##
# Dataset contrains data for 5 years in separate sheets.
# Dataset contains data from 2003 as well, but not specifically for the variable of interest.

data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
D2016 <- as.data.frame(data)
colnames(D2016) <- c("COUNTRY","STRUCT")
D2016$YEAR <- rep(2016,nrow(D2016))

data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 2, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
D2014 <- as.data.frame(data)
colnames(D2014) <- c("COUNTRY","STRUCT")
D2014$YEAR <- rep(2014,nrow(D2014))

data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 3, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
# 2 missing rows on the end for unknown reason. Trim:
D2012 <- as.data.frame(data[1:128,])
colnames(D2012) <- c("COUNTRY","STRUCT")
D2012$YEAR <- rep(2012,nrow(D2012))

data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 4, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
D2010 <- as.data.frame(data)
colnames(D2010) <- c("COUNTRY","STRUCT")
D2010$YEAR <- rep(2010,nrow(D2010))

data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 5, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
D2008 <- as.data.frame(data)
colnames(D2008) <- c("COUNTRY","STRUCT")
D2008$YEAR <- rep(2008,nrow(D2008))


data <-
  read_excel(
    "STRUCT_ORIG.xls", sheet = 6, col_names = TRUE, col_types = NULL, na = "", skip = 0
  )
data <- cbind(data[,1],data[,54])
D2006 <- as.data.frame(data)
colnames(D2006) <- c("COUNTRY","STRUCT")
D2006$YEAR <- rep(2006,nrow(D2006))

data <- rbind(D2016,D2014,D2012,D2010,D2008,D2006)
rm(D2016,D2014,D2012,D2010,D2008,D2006)


# Rename countries to allow merge
data$COUNTRY[which(data$COUNTRY=="Bolivia")]       <-	"Bolivia, Plurinational State of"
data$COUNTRY[which(data$COUNTRY=="Congo, DR")]     <-	"Congo, the Democratic Republic of the"
data$COUNTRY[which(data$COUNTRY=="Côte d'Ivoire")] <-	"Cote d'Ivoire"
data$COUNTRY[which(data$COUNTRY=="Congo, Rep.")]   <-	"Congo"
data$COUNTRY[which(data$COUNTRY=="Iran")]          <-	"Iran, Islamic Republic of"
data$COUNTRY[which(data$COUNTRY=="Laos")]          <-	"Lao People's Democratic Republic"
data$COUNTRY[which(data$COUNTRY=="Macedonia")]     <-	"Macedonia, the former Yugoslav Republic of"
data$COUNTRY[which(data$COUNTRY=="Moldova")]       <-	"Moldova, Republic of"
data$COUNTRY[which(data$COUNTRY=="North Korea")]   <-	"Korea, Democratic People's Republic of"
data$COUNTRY[which(data$COUNTRY=="South Korea")]   <-	"Korea, Republic of"
data$COUNTRY[which(data$COUNTRY=="Russia")]        <-	"Russian Federation"
data$COUNTRY[which(data$COUNTRY=="Syria")]         <-	"Syrian Arab Republic"
data$COUNTRY[which(data$COUNTRY=="Tanzania")]      <-	"Tanzania, United Republic of"
data$COUNTRY[which(data$COUNTRY=="Venezuela")]     <-	"Venezuela, Bolivarian Republic of"

# Merge
data <- merge(id_mat, data, by=c("COUNTRY","YEAR"), all.x=T)

# Impute missing from closest available data
data <- flp.impute(data,1,11)

# Completely missing countries are replaced with the mean of a similar country
data$STRUCT[which(data$COUNTRY=="Comoros")]             <- mean(data$STRUCT[which(data$COUNTRY=="Mauritius")])
data$STRUCT[which(data$COUNTRY=="Djibouti")]            <- mean(data$STRUCT[which(data$COUNTRY=="Eritrea")])
data$STRUCT[which(data$COUNTRY=="Equatorial Guinea")]   <- mean(data$STRUCT[which(data$COUNTRY=="Congo")])
data$STRUCT[which(data$COUNTRY=="Fiji")]                <- mean(data$STRUCT[which(data$COUNTRY=="Jamaica")])
data$STRUCT[which(data$COUNTRY=="Gabon")]               <- mean(data$STRUCT[which(data$COUNTRY=="Congo")])
data$STRUCT[which(data$COUNTRY=="Gambia")]              <- mean(data$STRUCT[which(data$COUNTRY=="Senegal")])
data$STRUCT[which(data$COUNTRY=="Guinea-Bissau")]       <- mean(data$STRUCT[which(data$COUNTRY=="Senegal")])
data$STRUCT[which(data$COUNTRY=="Guyana")]              <- mean(data$STRUCT[which(data$COUNTRY=="Venezuela, Bolivarian Republic of")])
data$STRUCT[which(data$COUNTRY=="Palestine, State of")] <- mean(data$STRUCT[which(data$COUNTRY=="Lebanon")])
data$STRUCT[which(data$COUNTRY=="Solomon Islands")]     <- mean(data$STRUCT[which(data$COUNTRY=="Papua New Guinea")])
data$STRUCT[which(data$COUNTRY=="Suriname")]            <- mean(data$STRUCT[which(data$COUNTRY=="Venezuela, Bolivarian Republic of")])
data$STRUCT[which(data$COUNTRY=="Swaziland")]           <- mean(data$STRUCT[which(data$COUNTRY=="Lesotho")])
data$STRUCT[which(data$COUNTRY=="Timor-Leste")]         <- mean(data$STRUCT[which(data$COUNTRY=="Indonesia")])
data$STRUCT[which(data$COUNTRY=="Trinidad and Tobago")] <- mean(data$STRUCT[which(data$COUNTRY=="Jamaica")])
data$STRUCT[which(data$COUNTRY=="Viet Nam")]            <- mean(data$STRUCT[which(data$COUNTRY=="Cambodia")])

# Minimum score given to developed countries
data$STRUCT[which(data$COUNTRY=="Australia")] <- 1
data$STRUCT[which(data$COUNTRY=="Canada")] <- 1
data$STRUCT[which(data$COUNTRY=="Israel")] <- 1
data$STRUCT[which(data$COUNTRY=="Japan")] <- 1
data$STRUCT[which(data$COUNTRY=="New Zealand")] <- 1
data$STRUCT[which(data$COUNTRY=="Norway")] <- 1
data$STRUCT[which(data$COUNTRY=="Switzerland")] <- 1
data$STRUCT[which(data$COUNTRY=="United States")] <- 1

# Subset relevant
data <- subset(data, select = c(STRUCT,ISO3C, YEAR))

save.image("../PROCESSED/STRUCT.Rdata")
