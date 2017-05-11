setwd(data_wd)
## Variable construction - ETHNIC_NP ##

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# This variable requires moderate levels of work
# converting the original variables into the wanted 
# indicator. 
#
# The data consists of ethnic groups' statuses in
# a given country in a given year. This is to be 
# converted into changes in status. Where no groups
# undergo changes, countries are coded as 0.
#
# Where transitions occur, the status before and 
# after are compared and coded according a scheme.
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Load data
data <- read_excel("ETHNIC_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0)

# Changes prior to 1988 are irrelevant - remove units whose period ends before this.
data <- subset(data, to>1988)

# Order by gwgroupid (group in country) and date
tdata <- data[order(data$gwgroupid,data$from),]

# Lag status variable
tdata$status_lag <-  c(NA,tdata$status[1:nrow(tdata)-1])

tdata$uni <- duplicated(tdata$gwgroupid)
# Erase status lag for first year of each group 
# (To avoid coding based on the status of other groups above in the set.
#  This could be coded prettier with a "by" or two)
tdata$status_lag[tdata$uni==F] <- "FIRST"

# Create dummy for included/Excluded
tdata$incexc <- NA
tdata$incexc[tdata$status=="DOMINANT"  | tdata$status=="MONOPOLY" | tdata$status=="SENIOR PARTNER" | tdata$status=="JUNIOR PARTNER"] <- "INC"
tdata$incexc[tdata$status=="POWERLESS" | tdata$status=="SELF-EXCLUSION" | tdata$status=="DISCRIMINATED"] <- "EXC" 
tdata$incexc[tdata$status=="IRRELEVANT"] <- "IRR" 
tdata$incexc[tdata$status=="STATE COLLAPSE"] <- "COL"
# Create lag for incexc
tdata$incexc_lag <-  c(NA,tdata$incexc[1:nrow(tdata)-1])
tdata$incexc_lag[tdata$uni==F] <- "FIRST"
# Create lag for reg_aut
tdata$reg_aut_lag <-  as.numeric(c(NA,tdata$reg_aut[1:nrow(tdata)-1]))
# First values of each group coded 0
tdata$reg_aut_lag[tdata$uni==F] <- 0
# Find transitions to reg_aut
tdata$reg_aut_trans <- tdata$reg_aut - tdata$reg_aut_lag
tdata$reg_aut_trans[tdata$uni==F] <- 0

# Create variable representing the transition from previous year
tdata$transition <- NA

# Going from included to included is 0 (unless otherwise coded below)
tdata$transition[tdata$incexc=="INC" & tdata$incexc_lag=="INC"] <- 0
# Going from excluded to excluded is 0 (unless otherwise coded below)
tdata$transition[tdata$incexc=="EXC" & tdata$incexc_lag=="EXC"] <- 0
# Any group remaining in the same state is 0
tdata$transition[tdata$status==tdata$status_lag] <- 0
# Any irrelevant group is 0
tdata$transition[tdata$status=="IRRELEVANT"] <-0

#### Transitions from irr, pow or dis to separatism - 6 ####
tdata$transition[tdata$status_lag=="IRRELEVANT" & tdata$status=="SELF-EXCLUSION"] <- 6
tdata$transition[tdata$status_lag=="POWERLESS" & tdata$status=="SELF-EXCLUSION"] <- 6
tdata$transition[tdata$status_lag=="DISCRIMINATED" & tdata$status=="SELF-EXCLUSION"] <- 6

#### Transitions from irr, pow or dis to regional aut - 6 ####
tdata$transition[tdata$status_lag=="IRRELEVANT" & tdata$reg_aut_trans==1] <- 6
tdata$transition[tdata$status_lag=="POWERLESS" & tdata$reg_aut_trans==1] <- 6
tdata$transition[tdata$status_lag=="DISCRIMINATED" & tdata$reg_aut_trans==1] <- 6

#### Transitions to exclusion ####
# From dominant to excluded
tdata$transition[tdata$incexc=="EXC" & tdata$status_lag=="DOMINANT"] <- 9
# From monopoly to excluded
tdata$transition[tdata$incexc=="EXC" & tdata$status_lag=="MONOPOLY"] <- 9
# From irrelevant to excluded
tdata$transition[tdata$incexc=="EXC" & tdata$status_lag=="IRRELEVANT"] <- 1

# From irrelevant to included
tdata$transition[tdata$incexc=="INC" & tdata$status_lag=="IRRELEVANT"] <- 0
# From regional autonomy to included
tdata$transition[tdata$incexc=="INC" & tdata$reg_aut==1] <- 1
# senior or junior to excluded
tdata$transition[tdata$incexc=="EXC" & tdata$status_lag=="SENIOR PARTNER" | tdata$incexc=="EXC" & tdata$status_lag=="JUNIOR PARTNER"] <- 7
# From discrimintated to included
tdata$transition[tdata$incexc=="INC" & tdata$status_lag=="DISCRIMINATED"] <- 3
# From self exclusion or powerless to included
tdata$transition[tdata$incexc=="INC" & tdata$status_lag=="SELF-EXCLUSION" | tdata$incexc=="INC" & tdata$status_lag=="POWERLESS"] <- 1
# Any group going from powerless, irrelevant or discriminated to self exclusion is a 6
tdata$transition[tdata$status=="SELF-EXCLUSION" & tdata$status_lag=="POWERLESS" | tdata$status=="SELF-EXCLUSION" & tdata$status_lag=="IRRELEVANT" | 
                   tdata$status=="SELF-EXCLUSION" & tdata$status_lag=="DISCRIMINATED"] <- 6
# Separatists going to powerless, irrelevant or discriminated are 0
tdata$transition[tdata$status_lag=="SELF-EXCLUSION" & tdata$status=="POWERLESS" | tdata$status_lag=="SELF-EXCLUSION" & tdata$status=="SELF-EXCLUSION" |
                   tdata$status_lag=="SELF-EXCLUSION" & tdata$status=="DISCRIMINATED"] <- 0


# From state collapse is 0
tdata$transition[tdata$status_lag=="STATE COLLAPSE"] <- 0
# State collapse is 10
tdata$transition[tdata$status=="STATE COLLAPSE"] <- 10

# First observation is always 0 as any prior transitions is irrelevant (transitions from 1988 to 1989 are included)
tdata$transition[tdata$status_lag=="FIRST"] <- 0

# Subset relevant vars
ETHNIC_NP <- subset(tdata, select = c(gwid, statename,from,transition))
colnames(ETHNIC_NP)<- c("GWNO","COUNTRY","YEAR","ETHNIC_NP")
rm(data, tdata)

#Reorder and aggregate, taking the max score for each country-year
ETHNIC_NP <- ETHNIC_NP[order(ETHNIC_NP$COUNTRY,ETHNIC_NP$YEAR),]
ETHNIC_NP <- aggregate(ETHNIC_NP,by = list(ETHNIC_NP$COUNTRY,ETHNIC_NP$YEAR),FUN = max)
ETHNIC_NP <- ETHNIC_NP[order(ETHNIC_NP$COUNTRY,ETHNIC_NP$YEAR),]

#### Merge to id_mat ####
ETHNIC_NP <- merge(id_mat, ETHNIC_NP, by=c("GWNO","YEAR"), all.x=T)
# Replace missing in NP with 0 under the assumption that nothing happened where no data is present.
ETHNIC_NP$ETHNIC_NP[which(is.na(ETHNIC_NP$ETHNIC_NP))] <- 0
data<-subset(ETHNIC_NP, select = c(ETHNIC_NP,ISO3C,YEAR))
rm(ETHNIC_NP)

save.image("../PROCESSED/ETHNIC_NP.Rdata")
