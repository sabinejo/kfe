startwd <- getwd()
setwd('R')

# List of 15 nations of interest (NAMO)
isolist <- c("BHR","EGY","IRN", "IRQ","ISR","JOR","KWT","LBN","OMN","PSE","QAT","SAU","SYR","TUR","ARE","YEM")

# Extract ID codes from countrycode package
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

# Extract GWNO from cshapes package
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

#### Convert to proper classes ####
id_mat <- as.data.frame(id_mat)
id_mat$ISO3C <- as.character(id_mat$ISO3C)
id_mat$COUNTRY <- as.character(id_mat$COUNTRY)
id_mat$ISO3N <- as.numeric(as.character(id_mat$ISO3N))
id_mat$ISO2C <- as.character(id_mat$ISO2C)
id_mat$FAO <- as.numeric(as.character(id_mat$FAO))
id_mat$COWN <- as.numeric(as.character(id_mat$COWN))
id_mat$UN <- as.numeric(as.character(id_mat$UN))
id_mat$WB <- as.character(id_mat$WB)

#### Fill in some missing codes ####

#PALESTINE missing FAO code - 299 taken from FOOD_ORIG for West Bank and Gaza
id_mat$FAO[which(id_mat$ISO3C=="PSE")] <- 299
# Also missing COWN and GWNO - 667 used.
id_mat$COWN[which(id_mat$ISO3C=="PSE")] <- 667
id_mat$GWNO[which(id_mat$ISO3C=="PSE")] <- 667
# SERBIA missing cow and gwno - 345 used (note that this may have caused issues)
id_mat$COWN[which(id_mat$ISO3C=="SRB")] <- 345
id_mat$GWNO[which(id_mat$ISO3C=="SRB")] <- 345

#### Add years ####
# Stretch set
id_mat$count <- 51
id_mat <- rep(id_mat, times=id_mat$count)
id_mat$count <- NULL
# Add years
id_mat$YEAR <- rep(1980:2030)
# Subset relevant years
id_mat <- subset(id_mat, YEAR>=1989)
id_mat <- subset(id_mat, YEAR<=2015) # If the dataset is to be expanded to include newer data, this is where you do it. 
# Change 2014 to whichever year you wish to have.

#### Remove superfluous years for certain countries that are not independent states
# for the whole period.

# The many different variables are not always consistent in when they start regarding
# countries as independent states. Some improvement can be made here in getting some 
# extra years into the set.

# Yugos
id_mat <- subset(id_mat, !(YEAR<1992 & COUNTRY=="Bosnia and Herzegovina"))
id_mat <- subset(id_mat, !(YEAR<2006 & COUNTRY=="Montenegro"))
id_mat <- subset(id_mat, !(YEAR<2006 & COUNTRY=="Serbia"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Macedonia, the former Yugoslav Republic of"))

#Soviets
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Belarus"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Georgia"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Armenia"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Azerbaijan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Tajikistan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Kyrgyzstan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Kazakhstan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Turkmenistan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Uzbekistan"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Ukraine"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Russian Federation"))
id_mat <- subset(id_mat, !(YEAR<1991 & COUNTRY=="Moldova, Republic of"))

# Others
id_mat <- subset(id_mat, !(YEAR<1990 & COUNTRY=="Namibia"))
id_mat <- subset(id_mat, !(YEAR<1990 & COUNTRY=="Yemen"))
id_mat <- subset(id_mat, !(YEAR<1993 & COUNTRY=="Eritrea"))
id_mat <- subset(id_mat, !(YEAR<2002 & COUNTRY=="Timor-Leste"))
id_mat <- subset(id_mat, !(YEAR<2011 & COUNTRY=="South Sudan"))

id_mat$COUNTRY <- as.character(id_mat$COUNTRY)

save.image("id_mat.Rdata")
setwd(startwd)
rm(startwd, id_mat)
