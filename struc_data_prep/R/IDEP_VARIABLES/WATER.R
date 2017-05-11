setwd(data_wd)
## WATER ##
# Large set, will take 20-30 seconds to read
data <- read_excel("WATER_ORIG.xlsX", sheet = "country_raw", col_names = TRUE, col_types = NULL,skip = 0)

data <- subset(data, select = c(tdefm, ADMIN))
colnames(data) <- c("WATER", "COUNTRY")

data$COUNTRY[which(data$COUNTRY=="Bolivia")]                     <-	"Bolivia, Plurinational State of"
data$COUNTRY[which(data$COUNTRY=="Ivory Coast")]                 <-	"Cote d'Ivoire"
data$COUNTRY[which(data$COUNTRY=="Republic of the Congo")]       <-	"Congo"
data$COUNTRY[which(data$COUNTRY=="Iran")]                        <-	"Iran, Islamic Republic of"
data$COUNTRY[which(data$COUNTRY=="Laos")]                        <-	"Lao People's Democratic Republic"
data$COUNTRY[which(data$COUNTRY=="Macedonia")]                   <-	"Macedonia, the former Yugoslav Republic of"
data$COUNTRY[which(data$COUNTRY=="Moldova")]                     <-	"Moldova, Republic of"
data$COUNTRY[which(data$COUNTRY=="North Korea")]                 <-	"Korea, Democratic People's Republic of"
data$COUNTRY[which(data$COUNTRY=="South Korea")]                 <-	"Korea, Republic of"
data$COUNTRY[which(data$COUNTRY=="Russia")]                      <-	"Russian Federation"
data$COUNTRY[which(data$COUNTRY=="Syria")]                       <-	"Syrian Arab Republic"
data$COUNTRY[which(data$COUNTRY=="United Republic of Tanzania")] <-	"Tanzania, United Republic of"
data$COUNTRY[which(data$COUNTRY=="Palestine")]                   <-	"Palestine, State of"
data$COUNTRY[which(data$COUNTRY=="Republic of Serbia")]          <-	"Serbia"
data$COUNTRY[which(data$COUNTRY=="Venezuela")]                   <-	"Venezuela, Bolivarian Republic of"
data$COUNTRY[which(data$COUNTRY=="East Timor")]                  <-	"Timor-Leste"
data$COUNTRY[which(data$COUNTRY=="United States of America")]    <-	"United States"
data$COUNTRY[which(data$COUNTRY=="Vietnam")]                     <-	"Viet Nam"
data$COUNTRY[which(data$COUNTRY=="Guinea Bissau")]               <-	"Guinea-Bissau"
data$COUNTRY[which(data$COUNTRY=="Democratic Republic of the Congo")] <-	"Congo, the Democratic Republic of the"
data$COUNTRY <- as.character(data$COUNTRY)
      
data <- merge(id_mat, data, by = "COUNTRY", all.x = T)

data <- flp.impute(data,3,11)

# Three countries are missing (Coded -32767) ) - Islands. Assigned Jamaica.
data$WATER[which(data$COUNTRY=="Mauritius")]       <- data$WATER[which(data$COUNTRY=="Jamaica")]
data$WATER[which(data$COUNTRY=="Solomon Islands")] <- data$WATER[which(data$COUNTRY=="Jamaica")]
data$WATER[which(data$COUNTRY=="Fiji")]            <- data$WATER[which(data$COUNTRY=="Jamaica")]

data <- subset(data, select = c(WATER, ISO3C, YEAR))
data$WATER <- scale010(data$WATER,0)

save.image("../PROCESSED/WATER.Rdata")
