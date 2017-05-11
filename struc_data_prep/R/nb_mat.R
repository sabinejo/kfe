# Creates the dataset containing neighbourhood information used in CON_NB.
# Running this takes approx 5 min per year.

library(cshapes)
library(tidyr)
library(reshape)

datelist <- c("2015-6-1","2014-6-1","2013-6-1","2012-6-1","2011-6-1","2010-6-1","2009-6-1",
              "2008-6-1","2007-6-1","2006-6-1","2005-6-1","2004-6-1","2003-6-1",
              "2002-6-1","2001-6-1","2000-6-1","1999-6-1","1998-6-1","1997-6-1",
              "1996-6-1","1995-6-1","1994-6-1","1993-6-1","1992-6-1","1991-6-1",
              "1990-6-1","1989-6-1")

setlist <- list()
for (date in datelist){
  
dmat.simple <- distmatrix(as.Date(paste(date)), type="mindist")
dmat.simple <- as.data.frame(dmat.simple)
dmat.simpler <- as.data.frame(cbind(rownames(dmat.simple), dmat.simple))
colnames(dmat.simpler)[1] <- "GWNOA"
tdata <- gather(dmat.simpler,GWNOB,MINDIST, 2:ncol(dmat.simpler))
tdata$YEAR <- date

setlist[[date]] <- tdata
}

#Collapse list into single frame
combined <- do.call(rbind, setlist)

# Removing neighbourhoods not in GCRI data
load("../id_mat.Rdata")
gwnolist <- unique(id_mat$GWNO)
# Removing the superfluous countries themselves
combined <- subset(combined, GWNOA %in% gwnolist)
# Removing them as neighbours of countries in the set
combined <- subset(combined, GWNOB %in% gwnolist)

# Subset only neighbours with shared borders. Leave room for small errors in 
# distance calculations by allowing a distance of 1 km
combined <- subset(combined, MINDIST<=1)
date <- combined$YEAR
combined$YEAR <- colsplit(date, split="-", c("YEAR","MONTH","DAY"))[,1]
combined$X <- NULL
combined$MINDIST <- NULL

write.csv(combined, "R/GCRI_NB.csv")

