setwd(data_wd)
#### Var construction - ECON_ISO ####
# Merges three indicators into index

#### Data ####
# First component
data <- read_excel("ISOLATION_FOREIGN_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3)

tdata <- gather(data,YEAR,FOREIGN, `1960`:ncol(data))
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$FOREIGN <- tdata$FOREIGN
data2<-subset(data2,YEAR>=1989)

FOREIGN <- data2
rm(data,data2,tdata)

# Second component
data <- read_excel("ISOLATION_FOREIGN2_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3)

tdata <- gather(data,YEAR,FOREIGN, `1960`:`2015`)
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$FOREIGN2 <- tdata$FOREIGN
data2<-subset(data2,YEAR>=1989)

FOREIGN2 <- data2
rm(data,data2,tdata)

# Third component
data <- read_excel("ISOLATION_EXPORT_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 3)

tdata <- gather(data,YEAR,EXPORT, `1960`:`2015`)
data2 <- data.frame(row.names = c(1:nrow(tdata)))
data2$COUNTRY <- tdata$`Country Name`
data2$ISO <- tdata$`Country Code`
data2$YEAR <- as.numeric(as.character(tdata$YEAR))
data2$EXPORT <- tdata$EXPORT
data2<-subset(data2,YEAR>=1989)

EXPORT <- data2
rm(data,data2,tdata)

# Merge the three
merge <- merge(FOREIGN, FOREIGN2, by=c("ISO","YEAR"))
merge2 <- merge(merge, EXPORT, by=c("ISO","YEAR"), all.y=T)
merge <- subset(merge2, select = c(ISO,COUNTRY,YEAR,FOREIGN,FOREIGN2,EXPORT))
rm(merge2,FOREIGN,FOREIGN2,EXPORT)

# Merge with ID mat
ISOLATION <- merge(id_mat,merge,  by.x=c("ISO3C", "YEAR"), by.y=c("ISO", "YEAR"), all.x=T)

# Impute missing with previous or first known value
ISOLATION <- flp.impute(ISOLATION,1,12)
ISOLATION <- flp.impute(ISOLATION,1,13)
ISOLATION <- flp.impute(ISOLATION,1,14)

#### Reshape each component ####

## Component 1 ##
# Enforce a max value, forcing outliers down to this value.
ISOLATION$FOREIGN[which(ISOLATION$FOREIGN> quantile(ISOLATION$FOREIGN, 0.95, na.rm=T))]   <- quantile(ISOLATION$FOREIGN, 0.95, na.rm=T)
# Enforce a min value of 1$, forcing outliers up to this value.
ISOLATION$FOREIGN[which(ISOLATION$FOREIGN<1)] <- 1
# Log transform
ISOLATION$FOREIGN <- log(ISOLATION$FOREIGN)

## Component 2 ##
# Enforce a max value, forcing outliers down to this value (Chose to use an absolute max value based on histo of variable)
ISOLATION$FOREIGN2[which(ISOLATION$FOREIGN2>15)] <- 15
# Anything below 1 is set to 1
ISOLATION$FOREIGN2[which(ISOLATION$FOREIGN2< 1)] <- 1
# Log transform
ISOLATION$FOREIGN2 <- log(ISOLATION$FOREIGN2)

## Component 3 ##
# Enforce a max value, forcing outliers down to this value (Chose to use an absolute max value based on histo of variable)
ISOLATION$EXPORT[which(ISOLATION$EXPORT>125)] <- 125
# Set anything under 2 to 2 to log transform
ISOLATION$EXPORT[which(ISOLATION$EXPORT<3)] <- 3
ISOLATION$EXPORT <- log(ISOLATION$EXPORT)

ISOLATION$FOR1 <- scale010(ISOLATION$FOREIGN,1)
ISOLATION$FOR2 <- scale010(ISOLATION$FOREIGN2,1)
ISOLATION$FOR3 <- scale010(ISOLATION$EXPORT,1)

# # South Sudan only has numbers for exports. Use the score from there.
# ISOLATION$FOR1[ISOLATION$COUNTRY.x=="South Sudan"] <- ISOLATION$FOR3[ISOLATION$COUNTRY.x=="South Sudan"]
# ISOLATION$FOR2[ISOLATION$COUNTRY.x=="South Sudan"] <- ISOLATION$FOR3[ISOLATION$COUNTRY.x=="South Sudan"]
# 
# # Cuba only has numbers for exports. Use the score from there.
# ISOLATION$FOR1[ISOLATION$COUNTRY.x=="Cuba"] <- ISOLATION$FOR3[ISOLATION$COUNTRY.x=="Cuba"]
# ISOLATION$FOR2[ISOLATION$COUNTRY.x=="Cuba"] <- ISOLATION$FOR3[ISOLATION$COUNTRY.x=="Cuba"]
# 
# # DPRK only has numbers for net foreign investments. Force score to 10 because North Korea is Best Korea.
# ISOLATION$FOR2[ISOLATION$COUNTRY.x=="Korea, Democratic People's Republic of"] <- 10
# ISOLATION$FOR3[ISOLATION$COUNTRY.x=="Korea, Democratic People's Republic of"] <- 10
 
# Construct index using the three components
ISOLATION$FMEAN <- NA
# Average the two direct investment components
ISOLATION$FMEAN <-  apply(as.data.frame(subset(ISOLATION, select=c(FOR1, FOR2))),1, function(x) mean(x))
# Average this average with the trade component
ISOLATION$ECON_ISO <-  apply(as.data.frame(subset(ISOLATION, select=c(FMEAN, FOR3))),1, function(x) mean(x))

data <- subset(ISOLATION,select=c("ECON_ISO","YEAR","ISO3C"))
rm(ISOLATION,merge)

save.image("../PROCESSED/ECON_ISO.Rdata")













