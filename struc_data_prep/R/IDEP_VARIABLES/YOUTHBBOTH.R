setwd(data_wd)

data <- read.csv("../R/temp_ybb.csv")

# Sum up age groups
data$pop15_100 <- rowSums(data[,28:ncol(data)],na.rm=T)
data$pop15_24 <- rowSums(data[,28:37],na.rm=T)
# Convert to ratio
data$YOUTHBBOTH <- data$pop15_24/data$pop15_100

data <- subset(data, select = c(YOUTHBBOTH, ISO3C, YEAR))

# Force outliers, lowest and highest percentile, in
data$YOUTHBBOTH[which(data$YOUTHBBOTH<quantile(data$YOUTHBBOTH, .01))] <- quantile(data$YOUTHBBOTH, .01)
data$YOUTHBBOTH[which(data$YOUTHBBOTH>quantile(data$YOUTHBBOTH, .99))] <- quantile(data$YOUTHBBOTH, .99)

data <- flp.impute(data,2,1) # unnecessary

# Rescale
data$YOUTHBBOTH <- scale010(data$YOUTHBBOTH,0)

save.image("../PROCESSED/POP_YOUTHBBOTH.Rdata")
