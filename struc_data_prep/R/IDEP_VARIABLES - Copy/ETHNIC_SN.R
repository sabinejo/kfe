setwd(data_wd)
## Variable construction for ETHNIC_SN ##
# Load data
data <- read_excel("ETHNIC_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0)

####  Recode SN according to GCRI codebook rules ####
data$eth <- NA
data$eth[data$status=="STATE COLLAPSE"] <- 10
data$eth[data$status=="SELF-EXCLUSION"] <- 9
data$eth[data$reg_aut==1] <- 7
data$eth[data$status=="DISCRIMINATED"] <- 5
data$eth[data$status=="JUNIOR PARTNER"] <- 5
data$eth[data$status=="SENIOR PARTNER"] <- 5
data$eth[data$status=="DOMINANT"] <- 1
data$eth[data$status=="MONOPOLY"] <- 1
data$eth[data$status=="POWERLESS"] <- 1
data$eth[data$status=="IRRELEVANT"] <- 1

# Subset, rename, clean, reorder
ETHNIC_SN <- subset(data, select = c(gwid, statename, from, to, eth))
colnames(ETHNIC_SN)<- c("GWNO","COUNTRY","from","to","ETHNIC_SN")
rm(data)
ETHNIC_SN <- ETHNIC_SN[order(ETHNIC_SN$COUNTRY,ETHNIC_SN$to),]

#### Aggregate worst scores for each country-year ####
ETHNIC_SN <- aggregate(ETHNIC_SN,by = list(ETHNIC_SN$COUNTRY,ETHNIC_SN$to),FUN = max)
ETHNIC_SN <- ETHNIC_SN[order(ETHNIC_SN$COUNTRY,ETHNIC_SN$to),]
ETHNIC_SN$YEAR <- ETHNIC_SN$from

# Merge with long ID to impute from historic data when no change has occured recently
load("../R/id_mat_long.Rdata")
ETHNIC_SN <- merge(id_mat_long, ETHNIC_SN, by=c("GWNO","YEAR"), all.x=T) # merge the sets 
# impute by repeating previous known value using the "from"-variable, meaning each value is repeated until new is available
ETHNIC_SN <- flp.impute(ETHNIC_SN, 4, 16) 
rm(id_mat_long)

#### Merge ####
ETHNIC_SN <- merge(id_mat, ETHNIC_SN, by=c("GWNO","YEAR"), all.x=T)
#### Paste remaining SN missing ####
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Palestine, State of"] <- 9 # Israeli settlements
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Comoros"]  <- 9 # Separatists
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Solomon Islands"] <- 7 # Armed groups fighting for regional autonomy
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Suriname"] <- 5 # Discrimination
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Equatorial Guinea"] <- 5 # Discrimination
ETHNIC_SN$ETHNIC_SN[ETHNIC_SN$COUNTRY=="Qatar"] <- 5 # Discrimination

data <- subset(ETHNIC_SN, select = c(ETHNIC_SN, ISO3C.x, YEAR))
colnames(data)[2] <- "ISO3C"
rm(ETHNIC_SN)

save.image("../PROCESSED/ETHNIC_SN.Rdata")






