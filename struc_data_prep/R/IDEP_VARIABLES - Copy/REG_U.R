#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# REG_U is created by combined two parts of 
# the PolityIV set. Different combinations
# of scores are designated into groups,
# based on Goldstein 2010.
# These are then scored after a U-curve,
# where fully democratic or autocratic
# countries are given a low score,
# partially democratic or autocratic
# a medium score, and anocracies 10.

setwd(data_wd)
## Variable construction REG_U ##
# Read data
data <- read_excel("REG_P2_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 0,na="..")
data <- subset(data, year>=1989)
data <- data[order(data$ccode, data$year),]

# Country code issues to be fixed before merge
data$ccode[which(data$country=="Serbia")]   <- 345
data$ccode[which(data$country=="Vietnam")]  <- 816
data$ccode[which(data$country=="Ethiopia")] <- 530

# Merge
mdata <- merge(id_mat, data, by.x=c("COWN","YEAR"),by.y=c("ccode","year"),all.x=T)

## Classify
# Create a unique code for each combination of scores on the two variables
mdata$class <- (mdata$exrec*100)+mdata$parcomp

mdata$type <- as.vector(rep(NA, length(class)), mode="numeric")

mdata$type[which(mdata$class>=100 & mdata$class<=101)] <- 0
mdata$type[which(mdata$class>=200 & mdata$class<=201)] <- 0
mdata$type[which(mdata$class>=300 & mdata$class<=301)] <- 0
mdata$type[which(mdata$class>=400 & mdata$class<=401)] <- 0
mdata$type[which(mdata$class>=500 & mdata$class<=501)] <- 0

mdata$type[which(mdata$class>=600 & mdata$class<=601)] <- 1
mdata$type[which(mdata$class>=700 & mdata$class<=701)] <- 1
mdata$type[which(mdata$class>=800 & mdata$class<=801)] <- 1

mdata$type[which(mdata$class>=102 & mdata$class<=105)] <- 1
mdata$type[which(mdata$class>=202 & mdata$class<=205)] <- 1
mdata$type[which(mdata$class>=302 & mdata$class<=305)] <- 1
mdata$type[which(mdata$class>=402 & mdata$class<=405)] <- 1
mdata$type[which(mdata$class>=502 & mdata$class<=505)] <- 1

mdata$type[which(mdata$class==602)] <- 2
mdata$type[which(mdata$class==702)] <- 2
mdata$type[which(mdata$class==802)] <- 2

mdata$type[which(mdata$class>=604 & mdata$class<=605)] <- 2
mdata$type[which(mdata$class>=704 & mdata$class<=705)] <- 2
mdata$type[which(mdata$class>=804)] <- 2

mdata$type[which(mdata$class==603)] <- 3
mdata$type[which(mdata$class==703)] <- 3
mdata$type[which(mdata$class==803)] <- 3

mdata$type[which(mdata$class==805)] <- 4

mdata$type[which(mdata$class==-6666)] <- 6 # Foreign interventions
mdata$type[which(mdata$class==-7777)] <- 7 # Foreign interventions
mdata$type[which(mdata$class==-8888)] <- 8 # Transitions

# Score the different types
mdata$score <- NA
mdata$score[which(mdata$type==0)] <- 1.07 # Classify full autocracies
mdata$score[which(mdata$type==1)] <- 3.98 # Partial ano
mdata$score[which(mdata$type==2)] <- 3.91 # Partial demo
mdata$score[which(mdata$type==3)] <- 10 # 
mdata$score[which(mdata$type==4)] <- 1 # Classify full democracies

mdata$score[which(mdata$type==6)] <- 10 # Foreign interventions
mdata$score[which(mdata$type==7)] <- 10 # Foreign interventions
mdata$score[which(mdata$type==8)] <- 4.49 # Transitions

#### The following are left with missing ####
# Palestine - No data available. Classify as partial autocracy
mdata$score[which(mdata$COUNTRY=="Palestine, State of")] <- 3.98
# Russia for 1991 missing. Soviet classed as partial democracy for same year, use this.
mdata$score[which(mdata$COUNTRY=="Russian Federation")][1] <- 3.91

# Remaining missing are imputed by taking closest available value
data <- flp.impute(mdata,2,ncol(mdata))

data <- subset(data, select = c(score, ISO3C, YEAR))
colnames(data)[1] <- "REG_U"
rm(mdata)

save.image("../PROCESSED/REG.Rdata")
