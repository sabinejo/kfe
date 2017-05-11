# Same as id_mat.R, but with some extra years prior to the period included
# in the main dataset. See id_mat.R for more comments in the code.

startwd <- getwd()
setwd('R')

# List of 138 nations of interest (Non-EU and pop>500k)
isolist <- c("BHR","EGY", "IRN", "IRQ","ISR","JOR","KWT","LBN","OMN","PSE","QAT","SAU","SYR","TUR","ARE","YEM")

id_mat <- cbind(
  isolist,
  countrycode(isolist, "iso3c","country.name"),
  countrycode(isolist, "iso3c","iso3n"),
  countrycode(isolist, "iso3c","iso2c"),
  countrycode(isolist, "iso3c","cown"),
  countrycode(isolist, "iso3c","fao"),
  countrycode(isolist, "iso3c","un"),
  countrycode(isolist, "iso3c","wb")
)
colnames(id_mat) <- c("ISO3C", "COUNTRY", "ISO3N", "ISO2C", "COWN", "FAO","UN","WB")
rm(isolist)

cshp.data <- cshp()
gwno_mat <- as.data.frame(cbind(
  cshp.data$COWCODE,
  cshp.data$GWCODE
))
colnames(gwno_mat)<- c("COW","GWNO")
gwno_mat <- subset(gwno_mat,GWNO>1)
gwno_mat <- subset(gwno_mat,COW>1)
gwno_mat$dup <- duplicated(gwno_mat$COW)
gwno_mat<-subset(gwno_mat, dup==F)
gwno_mat$dup<-NULL

id_mat <- merge(id_mat, gwno_mat, by.x="COWN",by.y="COW", all.x=T)
rm(gwno_mat, cshp.data)

id_mat <- as.data.frame(id_mat)
id_mat$ISO3C <- as.character(id_mat$ISO3C)
id_mat$COUNTRY <- as.character(id_mat$COUNTRY)
id_mat$ISO3N <- as.numeric(as.character(id_mat$ISO3N))
id_mat$ISO2C <- as.character(id_mat$ISO2C)
id_mat$FAO <- as.numeric(as.character(id_mat$FAO))
id_mat$COWN <- as.numeric(as.character(id_mat$COWN))
id_mat$UN <- as.numeric(as.character(id_mat$UN))
id_mat$WB <- as.character(id_mat$WB)

#PALESTINE missing FAO code - 299 taken from FOOD_ORIG for West Bank and Gaza
id_mat$FAO[which(id_mat$ISO3C=="PSE")] <- 299
id_mat$COWN[which(id_mat$ISO3C=="PSE")] <- 667
id_mat$GWNO[which(id_mat$ISO3C=="PSE")] <- 667
# SERBIA missing cow and gwno - 345
id_mat$COWN[which(id_mat$ISO3C=="SRB")] <- 345
id_mat$GWNO[which(id_mat$ISO3C=="SRB")] <- 345

# Add years
id_mat$count <- 166
id_mat <- rep(id_mat, times=id_mat$count)
id_mat$count <- NULL
id_mat$YEAR <- rep(1855:2020)

id_mat <- subset(id_mat, YEAR<=2016) # This is where you have to change to 2015/2016 to include newer data
id_mat_long <-id_mat
rm(id_mat)

save.image("id_mat_long.Rdata")
setwd(startwd)
rm(startwd,id_mat_long)
