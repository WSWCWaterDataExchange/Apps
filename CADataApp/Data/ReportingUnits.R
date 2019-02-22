#Script for updating DAU Reporting Unit Names and ID's
library(RCurl)
library(XML)
library(wadeR)
library(plyr)

ru_url <- 'http://wade.sdsc.edu/WADE/v0.2/GetCatalog/GetCatalog_GetAll.php'
RU_df <- get_reporting_units(ru_url)
RU_df <-  RU_df[!duplicated(RU_df[,c('ReportingUnit','ReportingUnitName')]),]
#Limit to DAU
RU_df <- RU_df[(substr(RU_df$ReportingUnit,1,3)=="DAU"),]
RU_df$DAUNumber <- substr(RU_df$ReportingUnit,4,6)
RU_df$CoNumber <- substr(RU_df$ReportingUnit,7,8)
#Read in lookup tables
DAUNumberFile <- read.csv("data/DAUNames.csv",stringsAsFactors = FALSE)
DAUNumberFile$DAUNumber <- sprintf("%03d", DAUNumberFile$DAUNumber)
CoNumberFile <- read.csv("data/CountyNames.csv",stringsAsFactors = FALSE)
CoNumberFile$CoNumber <- sprintf("%02d", CoNumberFile$CoNumber)
RU_df <- join(RU_df,DAUNumberFile,by="DAUNumber")
RU_df <- join(RU_df,CoNumberFile,by="CoNumber")
RU_df$Name_ID <-  paste(RU_df$ReportingUnit,":",RU_df$DAUName,"-",RU_df$CoName)

save(RU_df,file="data/ReportingUnits.Rdata")
write.csv(RU_df,file="data/ReportingUnits.csv")
