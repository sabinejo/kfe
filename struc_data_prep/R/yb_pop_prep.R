setwd('ORIG_DATA_new')
# Large set, will take 20-30 seconds to read
data <- read_excel("YOUTHBULGE_BOTH_ORIG.xls", sheet = 1, col_names = TRUE, col_types = NULL,skip = 16)
# remove regions at top of set and superfluous columns (younger ages and needless text)
data <- data[925:nrow(data),]
data <- cbind(data[,3],data[,5:108])
#
data[,1] <- as.character(data[,1])
colnames(data)[1:3] <- c("COUNTRY", "CCODE", "YEAR")
# Merge and shrink set
load("../R/id_mat.Rdata")
data <- merge(id_mat, data, by.x=c("UN","YEAR"),by.y=c("CCODE","YEAR"), all.x = T)

data[,80:ncol(data)] <- apply(data[,80:ncol(data)],2, function (x) as.numeric(as.character(x)) )

write.csv(data, "../R/temp_ybb.csv")
rm(data)
setwd('..')
