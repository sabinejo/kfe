## Variable construction - Years since last conflict ##
# Loads PRIO/UCDP ACD from 1979 and up to create a variable
# that counts up to ten years of peace prior to the current
# country-year.

cat("## START OF YRS_HVC CALCULATION ##")
#### Load conflicts from the UCDP/PRIO ACD ####
setwd('../../ORIG_DATA')
load("CONFLICT_ORIG.Rdata")

ucdp.prio <- subset(ucdp.prio, select = c(ConflictId, Year,GWNoLoc, Location, Incompatibility, TypeOfConflict,IntensityLevel))
ucdp.prio <- subset(ucdp.prio, Year>=1979)
ucdp.prio <- subset(ucdp.prio, IntensityLevel==2)

ucdp.prio$NationalPower <- 0
ucdp.prio$NationalPower[which(ucdp.prio$Incompatibility==2 & ucdp.prio$TypeOfConflict==3)] <- 1
ucdp.prio$NationalPower[which(ucdp.prio$Incompatibility==2 & ucdp.prio$TypeOfConflict==4)] <- 1

ucdp.prio$SubNational <- 0
ucdp.prio$SubNational[which(ucdp.prio$TypeOfConflict==1)] <- 1
ucdp.prio$SubNational[which(ucdp.prio$TypeOfConflict==3 & ucdp.prio$Incompatibility==1)] <- 1
ucdp.prio$SubNational[which(ucdp.prio$TypeOfConflict==4 & ucdp.prio$Incompatibility==1)] <- 1
# Subset: Keep only units with either NP or SN conflict
ucdp.prio <- ucdp.prio[which(ucdp.prio$NationalPower==1 | ucdp.prio$SubNational==1),]

# Hezbollah and Israel fighting in Southern Lebanon is not covered by conflict definition.
# Palestinians and Israel fighting is designated as a Palestinian, not an Israeli, conflict. (reinsert 2014 in palestine later)
ucdp.prio <- subset(ucdp.prio, !Location=="Israel")
# Merge North Yemens history into one Yemen
ucdp.prio$GWNoLoc[which(ucdp.prio$GWNoLoc==680)] <- 678
# Remove double country-years
ucdp.prio$unicode <- paste(ucdp.prio$GWNoLoc, ucdp.prio$Year, sep = "")
ucdp.prio <- ucdp.prio[which(!duplicated(ucdp.prio$unicode)),]
ucdp.prio$HVC <- 1
# Merge to full country-year set
load("../R/id_mat_long.Rdata")
id_mat_long <- subset(id_mat_long, YEAR>=1979)
ucdp.prio <- merge(id_mat_long, ucdp.prio, by.x=c("GWNO", "YEAR"), by.y=c("GWNoLoc", "Year"), all.x=T)
# Code Palestine 2014 as major
ucdp.prio$HVC[which(ucdp.prio$GWNO==667 & ucdp.prio$YEAR==2014)] <- 1
# Code remaining as 0
ucdp.prio$HVC[which(is.na(ucdp.prio$HVC))] <- 0
# Apply function that calculates years since last conflict
ucdp.prio <- years.since(ucdp.prio, 1, which(colnames(ucdp.prio)=="HVC"))
colnames(ucdp.prio)[which(colnames(ucdp.prio)=="ys.HVC")] <- "YRS_HVC"

# Cut superfluous years
id_mat_c <- subset(id_mat, select=c(GWNO, YEAR))

ucdp.prio <- merge(id_mat_c, ucdp.prio, by=c("GWNO","YEAR"), all.x=T)
ucdp.prio$YRS_HVC[which(ucdp.prio$YRS_HVC>10)] <- 10
ucdp.prio <- subset(ucdp.prio, select = c("GWNO","ISO3C", "YEAR", "YRS_HVC"))

ucdp.prio$YRS_HVC <- scale010(ucdp.prio$YRS_HVC,1)

conflict <- merge(conflict, ucdp.prio, by=c("GWNO","YEAR"))

rm(id_mat_c, id_mat_long, ucdp.prio)
setwd('../R/CONFLICT_VARIABLES')
cat("## END OF YRS_HVC CALCULATION ##
    ")