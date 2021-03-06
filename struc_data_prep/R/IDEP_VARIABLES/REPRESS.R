setwd(data_wd)
## REPRESS ##
# Data
load("REPRESS_ORIG.Rdata")

# Subset relevant years - Remove Serbia and Montenegro due to ID conflict
PTS_2016 <- subset(PTS_2016, Year>=1989)
PTS_2016 <- subset(PTS_2016, !Country=="Serbia and Montenegro")

# ## Extract score for Palestine before merging as the COWN system is mismatched
# # Palestine - Max of Israeli and Palestinian scores for the occupied territories
# # cbind the scores for the two together and rowmax
# palestine <- rowMaxs(
#   as.matrix(
#     cbind(
#       PTS_2016[which(PTS_2016$COWnum==666.002),6:8],
#       rbind(
#         PTS_2016[which(PTS_2016$COWnum==666.003),6:8],
#         c(NA,NA,NA) # add extra line as data only goes to 2013
#       )
#     ) # cbind
#   ) # as.matrix
#   , na.rm = T # rowMaxs
# )
# # Replace infinite with last known value
# palestine[1:5] <- palestine[6]
# 
# #Remove extra Israels and Palestine from data before merging to avoid confusion
# PTS_2016 <- subset(PTS_2016,!COWnum == 666.000)
# PTS_2016 <- subset(PTS_2016,!COWnum == 666.002)
# PTS_2016 <- subset(PTS_2016,!COWnum == 666.003)
# 
# #Israel - Just for pre-1967 territories - rename this one
# PTS_2016$COWnum[which(PTS_2016$COWnum==666.001)] <- 666

# Merge into id_mat  
mdata <-
  merge(
    id_mat, PTS_2016,
    by.x = c("COWN",  "YEAR"),
    by.y = c("COW_Code_N","Year"),
    all.x = T
  )

# Calculate max over the three sources
mdata$REPRESS_MAX  <- rowMaxs(as.matrix(mdata[,17:19]),na.rm = T)

# Replace infinite max values with NA
mdata$REPRESS_MAX[which(!is.finite(mdata$REPRESS_MAX))]  <- NA

# #Replace palestine and israel with previously calculated scores
# mdata$REPRESS_MAX[mdata$ISO3C == "PSE"] <- palestine

# Replace missing values with closest known values
mdata <- flp.impute(mdata,3,20)

data <- subset(mdata, select = c(REPRESS_MAX, ISO3C,YEAR))
colnames(data)[1] <- "REPRESS"

rm(palestine,PTS_2016,mdata)

data$REPRESS <- scale010(data$REPRESS,0)

save.image("../PROCESSED/REPRESS.Rdata")
