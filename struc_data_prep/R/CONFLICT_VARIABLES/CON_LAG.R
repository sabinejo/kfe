## Variable construction - Conflict last year ##
# CON_INT is simply the max intensity of the previous year. 
cat("## START OF Y4 CALCULATION ##")

conflict <- conflict[order(conflict$GWNO, conflict$YEAR),]

# Lead intensities for each dimension for 4 years and use the max to create Intensity_Y4
# NP
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$NP_INTENSITY,1))
conflict$NP_1LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$NP_INTENSITY,2))
conflict$NP_2LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$NP_INTENSITY,3))
conflict$NP_3LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$NP_INTENSITY,4))
conflict$NP_4LEAD <- unlist(lags)

conflict$Intensity_Y4_NP <- 
rowMaxs(cbind(
  conflict$NP_1LEAD,
  conflict$NP_2LEAD,
  conflict$NP_3LEAD,
  conflict$NP_4LEAD
  ))

# SN

lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$SN_INTENSITY,1))
conflict$SN_1LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$SN_INTENSITY,2))
conflict$SN_2LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$SN_INTENSITY,3))
conflict$SN_3LEAD <- unlist(lags)
lags <- by(conflict, as.factor(conflict$GWNO), function(x) lead(x$SN_INTENSITY,4))
conflict$SN_4LEAD <- unlist(lags)

conflict$Intensity_Y4_SN <- 
  rowMaxs(cbind(
    conflict$SN_1LEAD,
    conflict$SN_2LEAD,
    conflict$SN_3LEAD,
    conflict$SN_4LEAD
  ))



rm(lags)
cat("## END OF Y4 CALCULATION ##")
## END ##