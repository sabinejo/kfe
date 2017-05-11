setwd(data_wd)
## Variable construction for FOOD ##
# Four components to be read from individual sheets, converted to correct format and combined.

#####  READ AND REFORMAT DATA  ####
## Dietary requirements
data <- read_excel("FOOD_ORIG.xlsx", sheet = "V_1.1", col_names = TRUE, col_types = NULL,skip = 2)

# Rename badly named columns - Takes the first year of the column name
colnames(data)[3:ncol(data)] <- colsplit(colnames(data)[3:ncol(data)], split="-", c("YEAR","TRASH"))[,1]

tdata <- gather(data,YEAR,DIET, `1990`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Regions/Subregions/Countries`
data2$CCODE <- tdata$`FAOST_CODE`
data2$YEAR <- as.character(tdata$YEAR)
data2$DIET <- tdata$DIET

DIET <- data2
rm(data,data2,tdata)

## Price level  

data <- read_excel("FOOD_ORIG.xlsx", sheet = "V_2.5", col_names = TRUE, col_types = NULL,skip = 2)

tdata <- gather(data,YEAR,PRICELEVEL, `1990`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Regions/Subregions/Countries`
data2$CCODE <- tdata$`FAOST_CODE`
data2$YEAR <- as.character(tdata$YEAR)
data2$PRICELEVEL <- tdata$PRICELEVEL

PL <- data2
rm(data,data2,tdata)

## Nourishment

data <- read_excel("FOOD_ORIG.xlsx", sheet = "V_2.6", col_names = TRUE, col_types = NULL,skip = 2)

# Rename badly named columns - Takes the first year of the column name
colnames(data)[3:ncol(data)] <- colsplit(colnames(data)[3:ncol(data)], split="-", c("YEAR","TRASH"))[,1]

tdata <- gather(data,YEAR,NOURISH, `1990`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Regions/Subregions/Countries`
data2$CCODE <- tdata$`FAOST_CODE`
data2$YEAR <- as.character(tdata$YEAR)
data2$NOURISH <- tdata$NOURISH

NOURISH <- data2
rm(data,data2,tdata)

## Food price volatility

data <- read_excel("FOOD_ORIG.xlsx", sheet = "V_3.5", col_names = TRUE, col_types = NULL,skip = 2)

tdata <- gather(data,YEAR,VOLATILITY, `1990`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Regions/Subregions/Countries`
data2$CCODE <- tdata$`FAOST_CODE`
data2$YEAR <- as.character(tdata$YEAR)
data2$VOLATILITY <- tdata$VOLATILITY

VOLATILITY <- data2
rm(data,data2,tdata)


#### ISSUE FIX - Nourish is in character ####
# Fix some impurities - Values coded as "Under 5" are set to 4
NOURISH$NOURISH <- ifelse(NOURISH$NOURISH == '<5.0', 4, NOURISH$NOURISH)
NOURISH$NOURISH <- as.numeric(NOURISH$NOURISH)

#### TRANFORMATION ####
## NOURISH
# Set a max value at the 99th percentile - The top 1% are forced down to the max of the bottom 99%
NOURISH$NOURISH[NOURISH$NOURISH>quantile(NOURISH$NOURISH, 0.99,na.rm=T)] <- quantile(NOURISH$NOURISH, 0.99,na.rm=T)
# Assume that effect of nourishment drops off at a certain point. Log transform:
NOURISH$NOURISH_LOG <- log(NOURISH$NOURISH)

## VOLATILITY
# Assign a max value and force outliers down to it
VOLATILITY$VOLATILITY[VOLATILITY$VOLATILITY>quantile(VOLATILITY$VOLATILITY, 0.98,na.rm=T)] <- quantile(VOLATILITY$VOLATILITY, 0.98,na.rm=T)
# Assign a min value and force outliers up to it
VOLATILITY$VOLATILITY[VOLATILITY$VOLATILITY<quantile(VOLATILITY$VOLATILITY, 0.01,na.rm=T)] <- quantile(VOLATILITY$VOLATILITY, 0.01,na.rm=T)

VOLATILITY$VOLATILITY <- log(VOLATILITY$VOLATILITY)
#### Fill in missing values - Nourish ####
NOURISH <- NOURISH[order(NOURISH$COUNTRY, NOURISH$YEAR),]

NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Sudan"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Sudan (former)"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="South Sudan"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Sudan (former)"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Somalia"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Ethiopia"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Bahrain"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Saudi Arabia"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Qatar"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Saudi Arabia"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Burundi"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Rwanda"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Bhutan"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Southern Asia"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Dominica"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Caribbean"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Eritrea"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Djibouti"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Micronesia (Federated States of)"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Equatorial Guinea"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Cameroon"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Grenada"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Caribbean"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Saint Kitts and Nevis"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Caribbean"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Marshall Islands"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Nauru"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Palau"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Papua New Guinea"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="West Bank and Gaza Strip"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Jordan"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Singapore"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Malaysia"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Seychelles"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Mauritius"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Syrian Arab Republic"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Lebanon"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Tuvalu"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Oceania"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Democratic Republic of the Congo"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Congo"]
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Comoros"] <- NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Sub-Saharan Africa"]

#Libya - Mean of North African arabs - Bind the countries together and average
NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Libya"] <- rowMeans(
  cbind(
    NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Morocco"],
    NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Algeria"],
    NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Tunisia"],
    NOURISH$NOURISH_LOG[NOURISH$COUNTRY=="Egypt"]
  )
)

# Developed countries have 0.
developed <- c("Albania", "Australia", "Belarus", "Bosnia and Herzegovina", "Canada", "Iceland", "Israel","Japan","Montenegro",
"New Zealand","Norway","Republic of Moldova","Russian Federation","Serbia","Serbia and Montenegro","Switzerland",
"The former Yugoslav Republic of Macedonia","Ukraine","United States of America")
# Loop through all and replace NA's with 0's
for (country in developed){
NOURISH$NOURISH_LOG[NOURISH$COUNTRY==country] <- 0
}
rm(country,developed)

# Merge with ID mat
NT <- merge(id_mat, NOURISH, by.x=c("FAO","YEAR"), by.y=c("CCODE","YEAR"), all.x = T)
NT <- NT[order(NT$COUNTRY.x, NT$YEAR),]

# Impute missing. Use closest known value.
NT <- flp.impute(NT,1,13)

# South Sudan missing. Use Sudan
slength <- length(NT$NOURISH_LOG[NT$COUNTRY.x=="Sudan"])
slength2 <- slength - 3
NT$NOURISH_LOG[NT$COUNTRY.x=="South Sudan"] <- NT$NOURISH_LOG[NT$COUNTRY.x=="Sudan"][slength2:slength]
rm(slength, slength2)


#### Fill in missing values - Diet ####
DIET <- DIET[order(DIET$COUNTRY, DIET$YEAR),]
# Subset countries of interest
DT <- merge(id_mat, DIET, by.x=c("FAO","YEAR"), by.y=c("CCODE","YEAR"), all.x = T)
DT <- DT[order(DT$COUNTRY.x, DT$YEAR),]

# Country copies from full set. Add missing year in front as data starts in 1990 and we are filling in from 1989
DT$DIET[DT$COUNTRY.x=="Sudan"]                <- c(NA,DIET$DIET[DIET$COUNTRY=="Sudan (former)"][1:25])
DT$DIET[DT$COUNTRY.x=="South Sudan"]          <- 107 # Last know value for Sudan
DT$DIET[DT$COUNTRY.x=="Somalia"]              <- c(NA,DIET$DIET[DIET$COUNTRY=="Ethiopia"][1:25])
DT$DIET[DT$COUNTRY.x=="Bahrain"]              <- c(NA,DIET$DIET[DIET$COUNTRY=="Saudi Arabia"][1:25])
DT$DIET[DT$COUNTRY.x=="Qatar"]                <- c(NA,DIET$DIET[DIET$COUNTRY=="Saudi Arabia"][1:25])
DT$DIET[DT$COUNTRY.x=="Burundi"]              <- c(NA,DIET$DIET[DIET$COUNTRY=="Rwanda"][1:25])
DT$DIET[DT$COUNTRY.x=="Bhutan"]               <- c(NA,DIET$DIET[DIET$COUNTRY=="Southern Asia"][1:25])
DT$DIET[DT$COUNTRY.x=="Comoros"]              <- c(NA,DIET$DIET[DIET$COUNTRY=="Sub-Saharan Africa"][1:25])
DT$DIET[DT$COUNTRY.x=="Eritrea"]              <- DIET$DIET[DIET$COUNTRY=="Djibouti"][4:25]
DT$DIET[DT$COUNTRY.x=="Equatorial Guinea"]    <- c(NA,DIET$DIET[DIET$COUNTRY=="Cameroon"][1:25])
DT$DIET[DT$COUNTRY.x=="Oman"]                 <- c(NA,DIET$DIET[DIET$COUNTRY=="United Arab Emirates"][1:25])
DT$DIET[DT$COUNTRY.x=="Papua New Guinea"]     <- c(NA,DIET$DIET[DIET$COUNTRY=="Oceania"][1:25])
DT$DIET[DT$COUNTRY.x=="Palestine, State of"]  <- c(NA,DIET$DIET[DIET$COUNTRY=="Jordan"][1:25])
DT$DIET[DT$COUNTRY.x=="Singapore"]            <- c(NA,DIET$DIET[DIET$COUNTRY=="Malaysia"][1:25])
DT$DIET[DT$COUNTRY.x=="Syrian Arab Republic"] <- c(NA,DIET$DIET[DIET$COUNTRY=="Lebanon"][1:25])
DT$DIET[DT$COUNTRY.x=="Congo, the Democratic Republic of the"] <- c(NA,DIET$DIET[DIET$COUNTRY=="Congo"][1:25])

# Libya
DT$DIET[DT$COUNTRY.x=="Libya"] <- rowMeans(
  cbind(
    DT$DIET[DT$COUNTRY.x=="Morocco"],
    DT$DIET[DT$COUNTRY.x=="Algeria"],
    DT$DIET[DT$COUNTRY.x=="Tunisia"]
  )
)

# Impute remaining missing using last known value
DT<-flp.impute(DT,1,12)


#### Fill in missing values - Volatility ####
VOLATILITY <- VOLATILITY[order(VOLATILITY$COUNTRY, VOLATILITY$YEAR),]
# Subset countries of interest
VT <- merge(id_mat, VOLATILITY, by.x=c("FAO","YEAR"), by.y=c("CCODE","YEAR"), all.x = T)
VT <- VT[order(VT$COUNTRY.x, VT$YEAR),]

# Impute remaining missing using last known value
VT <- flp.impute(VT,1,12)


#### Fill in missing values - Price Level ####
PL <- PL[order(PL$COUNTRY, PL$YEAR),]
# Subset countries of interest
PL <- merge(id_mat, PL, by.x=c("FAO","YEAR"), by.y=c("CCODE","YEAR"), all.x = T)
PL <- PL[order(PL$COUNTRY.x, PL$YEAR),]

# Impute remaining missing using last known value
PL <- flp.impute(PL,1,12)

rm(NOURISH,DIET,VOLATILITY)


#### Create index ####
# Reorder sets
DT <- DT[order(DT$ISO3C, DT$YEAR),]
NT <- NT[order(NT$ISO3C, NT$YEAR),]
VT <- VT[order(VT$ISO3C, VT$YEAR),]
PL <- PL[order(PL$ISO3C, PL$YEAR),]

# Bind individual variables into one set
FOOD <- as.data.frame(
  cbind(
    DT$YEAR,
    as.character(DT$ISO3C), 
    as.character(DT$COUNTRY.x),
    DT$DIET,
    NT$NOURISH_LOG, 
    VT$VOLATILITY,
    PL$PRICELEVEL
  )
)

rm(NT,VT,DT,PL)

# Rename and correct class
colnames(FOOD) <- c("YEAR","ISO3C","COUNTRY","D","N","V","P")
FOOD$D <- as.numeric(as.character(FOOD$D))
FOOD$N <- as.numeric(as.character(FOOD$N))
FOOD$V <- as.numeric(as.character(FOOD$V))
FOOD$P <- as.numeric(as.character(FOOD$P))

# Set missing on price variables to the mean of the variable
FOOD$V[is.na(FOOD$V)] <- mean(FOOD$V,na.rm=T)
FOOD$P[is.na(FOOD$P)] <- mean(FOOD$P,na.rm=T)

# Rescale all
FOOD$D <- scale010(FOOD$D,1)
FOOD$N <- scale010(FOOD$N,0)
FOOD$V <- scale010(FOOD$V,0)
FOOD$P <- scale010(FOOD$P,0)

# Calculate food index
FOOD$PV <-((0.8*FOOD$P)+(.2*FOOD$V))
FOOD$FOOD <- rowMeans(subset(FOOD, select = c(D,N,PV)))

#Rescale again so that variable is 0-10 like the other variables
FOOD$FOOD <- scale010(FOOD$FOOD, 0)

data <- subset(FOOD, select = c(FOOD, ISO3C, YEAR))
rm(FOOD)

save.image("../PROCESSED/FOOD.Rdata")








