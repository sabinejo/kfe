setwd(data_wd)
#### Var construction - EMPOWER ####
# Data
data <- read_excel("EMPOWER_ORIG.xlsx", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0,na="..")
data <- subset(data, select=c(NEW_EMPINX, YEAR, COW, CTRY))

# Remove countries that mess up merge (conflicting ID numbers)
data <- subset(data, !CTRY=="Soviet Union")
data <- subset(data, !CTRY=="Yugoslavia")
data <- subset(data, !CTRY=="Serbia")

# merge
mdata <- merge(id_mat, data, by.x=c("COWN","YEAR"),by.y=c("COW","YEAR"),all.x=T)

# Impute missing using last known values
mdata <- flp.impute(mdata,1,11)

# Palestine gets 0. Israeli occupation determines level of civil rights
mdata$NEW_EMPINX[which(mdata$COUNTRY=="Palestine, State of")] <- 0
# Serbia and Montenegro get the last score of FR Yugoslavia, 10
mdata$NEW_EMPINX[which(mdata$COUNTRY=="Montenegro")] <- 10
mdata$NEW_EMPINX[which(mdata$COUNTRY=="Serbia")] <- 10

# Rescale
mdata$EMPOWER <- scale010(mdata$NEW_EMPINX,1)

data <- subset(mdata, select=c(EMPOWER, YEAR, ISO3C))
rm(mdata)

save.image("../PROCESSED/EMPOWER.Rdata")
