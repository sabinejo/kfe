## Variable construction - CON_NB ##
# This script reads in a list of neighbourhoods
# and copies the values of all neighbours on the
# CON_INT variable and then takes the max of all
# neighbours as the value for CON_NB

cat("## START OF CON_NB CALCULATION ##")

nblist <- read_csv("../GCRI_NB.csv")
nblist <- subset(nblist, YEAR>=1989 & YEAR<=2014)
nblist <- subset(nblist, select = c(YEAR, GWNOA, GWNOB))
nblist <- nblist[which(nblist$GWNOA!=nblist$GWNOB),]
# Soviet Union is removed (Reinserted later)
nblist <- subset(nblist, !(YEAR<=1990 & GWNOB==365))
# Serbia/Yugo is removed (Reinserted later)
nblist <- subset(nblist, !(GWNOA==345 | GWNOB==345))
# One Yemeni year removed
nblist <- subset(nblist, !(GWNOA==678 | GWNOB==678))

#### Create neighbourhoods for missing ####
extras <- rbind(
cbind(# Israel as a neighbour of Palestine
  seq(1989,2014,1),
  rep(667, 26),
  rep(666, 26)
)
,
cbind( # Egypt as a neighbour of Palestine
  seq(1989,2014,1),
  rep(667, 26),
  rep(651, 26)
)
,
cbind( # Palestine as a neighbour of Egypt
  seq(1989,2014,1),
  rep(651, 26),
  rep(667, 26)
)
,
cbind( # Palestine as a neighbour of Israel
  seq(1989,2014,1),
  rep(666, 26),
  rep(667, 26)
)
,
cbind( # Palestine as a neighbour of Jordan
  seq(1989,2014,1),
  rep(663, 26),
  rep(667, 26)
)
,
cbind( # Jordan as a neighbour of Palestine
  seq(1989,2014,1),
  rep(667, 26),
  rep(663, 26)
)
,
cbind( # Sudan as a neighbour of SSudan
  2011,
  626,
  625
)
,
cbind( # SSudan as a neighbour of Sudan
  2011,
  625,
  626
)
,
cbind( # CAR as a neighbour of SSudan
  2011,
  626,
  482
)
,
cbind( # SSudan as a neighbour of CAR
  2011,
  482,
  626
)
,
cbind( # DRC as a neighbour of SSudan
  2011,
  626,
  490
)
,
cbind( # SSudan as a neighbour of DRC
  2011,
  490,
  626
)
,
cbind( # UGA as a neighbour of SSudan
  2011,
  626,
  500
)
,
cbind( # SSudan as a neighbour of UGA
  2011,
  500,
  626
)
,
cbind( # KEN as a neighbour of SSudan
  2011,
  626,
  501
)
,
cbind( # SSudan as a neighbour of KEN
  2011,
  501,
  626
)
,
cbind( # ETH as a neighbour of SSudan
  2011,
  626,
  530
)
,
cbind( # SSudan as a neighbour of ETH
  2011,
  530,
  626
)
,
cbind( # MDA as a neighbour of UKR
  1991,
  369,
  359
)
,
cbind( # UKR as a neighbour of MDA
  1991,
  359,
  369
)
,
cbind( # BLR as a neighbour of UKR
  1991,
  369,
  370
)
,
cbind( # UKR as a neighbour of BLR
  1991,
  370,
  369
)
,
cbind( # RUS as a neighbour of UKR
  1991,
  369,
  365
)
,
cbind( # UKR as a neighbour of RUS
  1991,
  365,
  369
)
,
cbind( # RUS as a neighbour of BLR
  1991,
  370,
  365
)
,
cbind( # BLR as a neighbour of RUS
  1991,
  365,
  370
)
)
colnames(extras)<- colnames(nblist)
nblist <- rbind(nblist, extras)
rm(extras)
#### Run neighbour check-loop ####
# Merge
lagframe <- merge(nblist, conflict, by.x = c("GWNOA","YEAR"), by.y = c("GWNO","YEAR"), all.y = T)

# RM missing
lagframe <- subset(lagframe, !is.na(GWNOB))

# Create empty lagvariable
lagframe$CON_NB <- NA

# Run loop that checks each country-year-neighbor and applies the value of the neighbor to each country's lagvar
for (i in 1:length(lagframe[,1])){
  
  lagframe$CON_NB[i] <- unique(lagframe$CON_INT[which(lagframe$GWNOA==lagframe$GWNOB[i] & lagframe$YEAR==lagframe$YEAR[i])])
  
}

# Aggregate each country-year's max value 
df <- aggregate(lagframe$CON_NB, by=list(lagframe$GWNOA, lagframe$YEAR), FUN=max)
colnames(df)<- c("GWNO","YEAR","CON_NB")

# Merge into the conflict set
conflict <- merge(conflict, df, by=c("GWNO","YEAR"), all.x=T)

# Manually code countries with no neighbours as 0
conflict$CON_NB[which(conflict$ISO3C=="CUB")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="JAM")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="TTO")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="MDG")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="COM")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="MUS")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="BHR")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="QAT")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="KOR")] <- 0 # DPRK only neighbor
conflict$CON_NB[which(conflict$ISO3C=="JPN")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="LKA")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="AUS")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="NZL")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="SLB")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="FJI")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="PHL")] <- 0 # Islands
conflict$CON_NB[which(conflict$ISO3C=="CHE")] <- 0 # Has only EU-neighbours

# Neighbours of Yugoslavia (currently not in data, but including known conflicts for neighbours)
conflict$CON_NB[which(conflict$ISO3C=="ALB" & conflict$YEAR<=1990)] <- 0 # Only non-EU neighbour is Yugo, so 0 when peace there
conflict$CON_NB[which(conflict$ISO3C=="ALB" & conflict$YEAR==1991)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="ALB" & conflict$YEAR==1998)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="ALB" & conflict$YEAR==1999)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="BIH" & conflict$YEAR<=2006)]  <- 0  # Only non-EU is Yugo until 2006
conflict$CON_NB[which(conflict$ISO3C=="BIH" & conflict$YEAR==1998)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="BIH" & conflict$YEAR==1999)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="MKD" & conflict$YEAR==1991)] <- 0
conflict$CON_NB[which(conflict$ISO3C=="MKD" & conflict$YEAR==1998)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="MKD" & conflict$YEAR==1999)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="MKD" & conflict$YEAR==1991)] <- 10 # Yugo conflict
conflict$CON_NB[which(conflict$ISO3C=="MNE" & conflict$YEAR==2006)] <- 0  # missing, no conf
conflict$CON_NB[which(conflict$ISO3C=="SRB")] <- 0 # Serbia has no neighbouring conflicts after 2006

# Neighbours of Soviet Union - Two minors in 1990, one 500+ in 1991 
# (other countries also affected, but these have higher scores from other
# neighbours and are therefore left as they are)
conflict$CON_NB[which(conflict$ISO3C=="NOR" & conflict$YEAR==1989)] <- 0 # Only neighbour is Soviet
conflict$CON_NB[which(conflict$ISO3C=="NOR" & conflict$YEAR==1990)] <- 6
conflict$CON_NB[which(conflict$ISO3C=="NOR" & conflict$YEAR==1991)] <- 8
conflict$CON_NB[which(conflict$ISO3C=="TUR" & conflict$YEAR==1990)] <- 6
#conflict$CON_NB[which(conflict$ISO3C=="TUR" & conflict$YEAR==1991)] <- 8
#conflict$CON_NB[which(conflict$ISO3C=="IRN" & conflict$YEAR==1990)] <- 6
#conflict$CON_NB[which(conflict$ISO3C=="IRN" & conflict$YEAR==1991)] <- 8
#conflict$CON_NB[which(conflict$ISO3C=="AFG" & conflict$YEAR==1990)] <- 6
#conflict$CON_NB[which(conflict$ISO3C=="AFG" & conflict$YEAR==1991)] <- 8
#conflict$CON_NB[which(conflict$ISO3C=="CHN" & conflict$YEAR==1990)] <- 6
#conflict$CON_NB[which(conflict$ISO3C=="CHN" & conflict$YEAR==1991)] <- 8
conflict$CON_NB[which(conflict$ISO3C=="MNG" & conflict$YEAR==1990)] <- 6
#conflict$CON_NB[which(conflict$ISO3C=="MNG" & conflict$YEAR==1991)] <- 8
conflict$CON_NB[which(conflict$ISO3C=="PRK" & conflict$YEAR==1990)] <- 6
conflict$CON_NB[which(conflict$ISO3C=="PRK" & conflict$YEAR==1991)] <- 8

# SGP
conflict$CON_NB[which(conflict$ISO3C=="SGP")] <- 0 # Only neigbour is MYS
conflict$CON_NB[which(conflict$ISO3C=="SGP" & conflict$YEAR==2013)] <- 5 # MYS conflict

# YEM
conflict$CON_NB[which(conflict$ISO3C=="YEM")] <- 0 # Only neigbours are Oman and Saudi, which have no conflicts in the period

# Neighbours of Afghanistan
conflict$CON_NB[which(conflict$ISO3C=="TKM" & conflict$YEAR==1991)] <- 10
conflict$CON_NB[which(conflict$ISO3C=="TJK" & conflict$YEAR==1991)] <- 10
conflict$CON_NB[which(conflict$ISO3C=="UZB" & conflict$YEAR==1991)] <- 10

# Kaz, Georgia, Aze, given 8 for bordering Russia
conflict$CON_NB[which(conflict$ISO3C=="KAZ" & conflict$YEAR==1991)] <- 8
conflict$CON_NB[which(conflict$ISO3C=="GEO" & conflict$YEAR==1991)] <- 8
conflict$CON_NB[which(conflict$ISO3C=="AZE" & conflict$YEAR==1991)] <- 8

# Arm given 5 for Turkey/Iran
conflict$CON_NB[which(conflict$ISO3C=="ARM" & conflict$YEAR==1991)] <- 5

# Kyrgyzstan has no neighbouring conflict in '91
conflict$CON_NB[which(conflict$ISO3C=="KGZ" & conflict$YEAR==1991)] <- 0


# Clean
rm(lagframe, nblist,df,i)
cat("## END OF CON_NB CALCULATION ##
    ")
## END 


