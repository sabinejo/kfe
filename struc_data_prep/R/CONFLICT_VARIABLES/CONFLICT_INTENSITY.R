## This script reads conflict data from three UCDP/PRIO datasets and calculates
# the GCRI intensity for each country-year and each dimension.

cat("## START OF INTENSITIES CALCULATION ##")
setwd('../../ORIG_DATA_new')
load("CONFLICT_BRD_ORIG.Rdata")

brd <- ucdp.brd

brd$NationalPower <- 0
brd$NationalPower[which(brd$Incompatibility==2 & brd$TypeOfConflict==3)] <- 1
brd$NationalPower[which(brd$Incompatibility==2 & brd$TypeOfConflict==4)] <- 1

brd$SubNational <- 0
brd$SubNational[which(brd$TypeOfConflict==1)] <- 1
brd$SubNational[which(brd$TypeOfConflict==3 & brd$Incompatibility==1)] <- 1
brd$SubNational[which(brd$TypeOfConflict==4 & brd$Incompatibility==1)] <- 1
# Subset: Keep only units with either NP or SN brd
brd <- brd[which(brd$NationalPower==1 | brd$SubNational==1),]

sn <- brd[which(brd$SubNational==1),]
np <- brd[which(brd$NationalPower==1),]

sn$intensity <- 1
sn$intensity[which(sn$BdHigh>=500)] <- 2
sn$intensity[which(sn$BdHigh>=1000)] <- 3

np$intensity <- 1
np$intensity[which(np$BdHigh>=500)] <- 2
np$intensity[which(np$BdHigh>=1000)] <- 3


brd <- list()
brd[["sn"]] <- sn
brd[["np"]] <- np
rm(np,sn,ucdp.brd)
########################################
load("CONFLICT_ONESIDED_ORIG.Rdata")
ucdpOneSided <- ucdp.os
names(ucdpOneSided) <- tolower(names(ucdpOneSided))
rm(ucdp.os)
# Remove non-state actors
ucdpOneSided <- subset(ucdpOneSided, isgovernmentactor==1)

ucdpOneSided$gwno <- as.character(ucdpOneSided$gwno)
colnames(ucdpOneSided)[4] <- "actor"

# Designate conflicts as happening in the country whose government was involved
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Cameroon")] <- "471"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Central African Republic")] <- "482"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Chad")] <- "483"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of DR Congo (Zaire) ")] <- "490"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Ethiopia")] <- "530"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Iraq")] <- "645"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Israel" & ucdpOneSided$loc=="Israel, Lebanon")] <- NA # Israel vs Hezbollah not covered by GCRI
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Israel" & ucdpOneSided$loc=="Israel")] <- NA # Israel vs Palestina coded as internal conflict in Palestine
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Mauritania")] <- "435"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Myanmar (Burma)")] <- "775"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Nigeria")] <- "475"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Rwanda")] <- "517"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of South Africa")] <- "560"
ucdpOneSided$gwno[which(ucdpOneSided$actor=="Government of Sudan")] <- "625"

ucdpOneSided$SN <- 1
ucdpOneSided$SN[which(ucdpOneSided$highfatalityestimate>=500)] <- 2
ucdpOneSided$SN[which(ucdpOneSided$highfatalityestimate>=1000)] <- 3



###############
load("CONFLICT_NONSTATE_ORIG.Rdata")
ucdpNonState <- ucdp.ns
names(ucdpNonState) <- tolower(names(ucdpNonState))
ucdp <- subset(ucdpNonState, year>=1989, select = c(sidea, sideb,year,location,gwnolocation, highfatalityestimate))
rm(ucdpNonState, ucdp.ns)

ucdp$gwnolocation <- as.character(ucdp$gwnolocation)

# Assign conflicts with more than one location to a single country-year
# Should have been done using actors rather than locations

ucdp$gwnolocation[which(ucdp$sidea=="Lou Nuer" & ucdp$sideb=="Murle")] <- 626
ucdp$gwnolocation[which(ucdp$location=="Kenya, Ethiopia")] <- 501
ucdp$gwnolocation[which(ucdp$location=="Lebanon, Syria")] <- 660
ucdp$gwnolocation[which(ucdp$location=="Mexico, Honduras")] <- 70
ucdp$gwnolocation[which(ucdp$location=="Mexico, Guatemala")] <- 70
ucdp$gwnolocation[which(ucdp$location=="Kenya, Somalia")] <- 520
ucdp$gwnolocation[which(ucdp$location=="Kenya, Sudan")] <- 501
ucdp$gwnolocation[which(ucdp$location=="Kenya, Uganda")] <- 501
ucdp$gwnolocation[which(ucdp$location=="Mexico, Canada")] <- 20
ucdp$gwnolocation[which(ucdp$location=="Ethiopia, Kenya")] <- 530
ucdp$gwnolocation[which(ucdp$location=="Iraq, Turkey")] <- 645
ucdp$gwnolocation[which(ucdp$location=="Liberia, Ivory Coast")] <- 450
ucdp$gwnolocation[which(ucdp$location=="Sierra Leone, Liberia")] <- 450
ucdp$gwnolocation[which(ucdp$location=="Liberia, Sierra Leone")] <- 450
ucdp$gwnolocation[which(ucdp$location=="Mali, Niger")] <- 432
ucdp$gwnolocation[which(ucdp$location=="Myanmar (Burma), Thailand")] <- 775
ucdp$gwnolocation[which(ucdp$location=="Somalia, Djibouti")] <- 520
ucdp$gwnolocation[which(ucdp$location=="Sudan, South Sudan")] <- 626
ucdp$gwnolocation[which(ucdp$location=="Sudan, Chad")] <- 625
# Senegal/Mauritania occurred on both sides, duplicate and give one to each
ucdp[which(ucdp$location=="Senegal, Mauritania"),][5] <- 433
x <- ucdp[which(ucdp$location=="Senegal, Mauritania"),]
x[5] <- 435
ucdp <- rbind(ucdp,x)
rm(x)
#
ucdp$gwnolocation[which(ucdp$location=="Tanzania, Burundi")] <- 516

ucdp$gwnolocation[which(ucdp$location=="Kenya, Somalia")] <- 520
ucdp$gwnolocation[which(ucdp$location=="Kenya, Somalia")] <- 520
ucdp$gwnolocation[which(ucdp$location=="Kenya, Somalia")] <- 520

ucdp$SN <- 1
ucdp$SN[which(ucdp$highfatalityestimate>=500)] <- 2
ucdp$SN[which(ucdp$highfatalityestimate>=1000)] <- 3


ucdp <- subset(ucdp, select = c(gwnolocation, year, SN))

# prep for aggregation
non <- ucdp
osv <- subset(ucdpOneSided, select = c(gwnolocation, year, SN))
brd_sn <- subset(brd[["sn"]], select=c(GWNoLoc, Year, intensity))
colnames(brd_sn) <- colnames(osv)
# bind together and aggregate highest intensity and number of conflicts per country-year
sn <- rbind(non, osv, brd_sn)
sn$count <- 1
intensity <- aggregate(sn$SN, by=list(sn$gwnolocation, sn$year), FUN=max)
names(intensity) <- c("gwno","year","int")
count     <- aggregate(sn$count, by=list(sn$gwnolocation, sn$year), FUN=sum)
names(count) <- c("gwno","year","count")

sn <- merge(intensity, count, by=c("gwno","year"))
sn$gcri <- 5
sn$gcri[which(sn$int==1 & sn$count==2)] <- 6
sn$gcri[which(sn$int==1 & sn$count>2)]  <- 7
sn$gcri[which(sn$int==2 & sn$count==1)] <- 8
sn$gcri[which(sn$int==2 & sn$count==2)] <- 8.5
sn$gcri[which(sn$int==2 & sn$count>2)]  <- 9
sn$gcri[which(sn$int==3)]  <- 10


np <- subset(brd[["np"]], select=c(GWNoLoc, Year, intensity))
np$gcri <- 5
np$gcri[which(np$intensity==2)] <- 8
np$gcri[which(np$intensity==3)]  <- 10

sn <- merge(id_mat, sn, by.x=c("GWNO", "YEAR"), by.y=c("gwno","year"), all.x=T)
np <- merge(id_mat, np, by.x=c("GWNO", "YEAR"), by.y=c("GWNoLoc","Year"), all.x=T)

sn <- subset(sn, select = c(GWNO, YEAR, gcri))
colnames(sn)[3] <- "SN_INTENSITY"
np <- subset(np, select = c(GWNO, YEAR, gcri))
colnames(np)[3] <- "NP_INTENSITY"

# Fill in missing as 0
sn$SN_INTENSITY[which(is.na(sn$SN_INTENSITY))] <- 0
np$NP_INTENSITY[which(is.na(np$NP_INTENSITY))] <- 0

# Hardcode US as 0 as the recorded conflicts are not covered by the GCRI conflict definitions
sn$SN_INTENSITY[which(sn$GWNO==2)] <- 0
np$NP_INTENSITY[which(np$GWNO==2)] <- 0

conflict <- merge(np, sn, by=c("GWNO", "YEAR"))

rm(brd_sn, count, intensity, non, np, osv, sn, ucdp, ucdpOneSided, brd)

conflict$CON_INT <- rowMaxs(cbind(conflict$NP_INTENSITY,conflict$SN_INTENSITY))

setwd('../R/CONFLICT_VARIABLES')
cat("## END OF INTENSITIES CALCULATION ##
    ")

## END

