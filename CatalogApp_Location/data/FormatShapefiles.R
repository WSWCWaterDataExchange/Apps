############Format shapefile data#########################
##########################################################
#Load necessary packages
library(rgdal)
library(RPostgreSQL)
library(rmapshaper)

##If the layer needs to be simplified, use ms_simplify from the rmapshaper package:
#var <- ms_simplify(var)


#--------------------------------------------------------
#Load Data from Central Catalog
#Connect to Database
con <- dbConnect(PostgreSQL(),
                 user="NameHere",
                 password="PassHere",
                 host="HostHere",
                 port="PortHere",
                 dbname="dbNameEnter")

#Query central catalog table
cc <- dbGetQuery(con,"select * from \"WADE\".\"CATALOG_SUMMARY_MV\"")

#-----------------------------------------------------------------
#Format layer of all Western States
allstates <- readOGR(dsn="data/ESRIShapefiles",layer="AllWesternStates_PlusAK")
save(allstates,file="data/allstates.RData")

#Format layer of custom reporting units---------------------------
#Read in shapefile
CustomRU <- readOGR(dsn="data/ESRIShapefiles", layer="Custom",stringsAsFactors = F)
#Create link for the report catalog
CustomRU$CATALOGLINK <- paste0("<a href = http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=REPORTUNIT&loctxt=",CustomRU$RU_ID,"&orgid=ALL&state=",CustomRU$StateNum," target=\"_blank\"> Catalog Link </a>")
#Subset the records from the central catalog (only custom reporting units)
Custom_records <- subset(cc,SYM_TOGGLE_RU=="1")
#Select the spatial data that match the subsetted records
CustomRU_available <- subset(CustomRU,State_RU %in% unique(Custom_records$JOIN_FIELD_RU))
#Remove duplicated spatial data
CustomRU_available <- subset(CustomRU_available, !duplicated(CATALOGLINK))
#Save formatted data as .RData file
save(CustomRU_available,file=paste("data","CustomRU_available.RData",sep="/"))

#Format all three levels of custom reporting units for California---
#Read in shapefile for outline of CA
CA <- readOGR(dsn="data/ESRIShapefiles", layer="CA_State")
#Save formatted data as .RData file
save(CA,file=paste("data","CA.RData",sep="/"))

#CA Hydrologic Regions
#Read in shapefile for Hydrologic Regions
HR <- readOGR(dsn="data/ESRIShapefiles",layer="HR")
#Create link for the report catalog
HR$CATALOGLINK <- paste0("<a href =  http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=REPORTUNIT&loctxt=",HR$RU_ID,"&orgid=ALL&state=49 target=\"_blank\"> Catalog Link </a>")
#Save formatted data as .RData file
save(HR,file=paste("data","HR.RData",sep="/"))

#CA Planning Areas
#Read in shapefile for Planning Areas
PA <- readOGR(dsn="data/ESRIShapefiles",layer="PA")
#Create link for the report catalog
PA$RU_ID <- as.character(PA$RU_ID)
PA[(substr(PA$RU_ID,1,1)=="0"),"RU_ID"] <- substr(PA[(substr(PA$RU_ID,1,1)=="0"),]$RU_ID,2,4)
PA$CATALOGLINK <- paste0("<a href =  http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=REPORTUNIT&loctxt=",PA$RU_ID,"&orgid=ALL&state=49 target=\"_blank\"> Catalog Link </a>")
#Save formatted data as .RData file
save(PA,file=paste("data","PA.RData",sep="/"))

#CA Detailed Analysis Units
#Read in shapefile for Detailed Analysis Units
DAU <- readOGR(dsn="data/ESRIShapefiles",layer="DAU")
#Create link for the report catalog
DAU$CATALOGLINK <- paste0("<a href =  http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=REPORTUNIT&loctxt=",DAU$RU_ID,"&orgid=ALL&state=49 target=\"_blank\"> Get Catalog </a>")
#Save formatted data as .RData file
save(DAU,file=paste("data","DAU.RData",sep="/"))

#HUC----------------------------------------------------------------
#Read in shapefile for HUCs
HUC <- readOGR(dsn="data/ESRIShapefiles", layer="HUCs_PlusAK")
#Create link for the report catalog
HUC$CATALOGLINK <- paste0("<a href = http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=HUC&loctxt=",HUC$HUC_8,"&orgid=ALL&state=",HUC$StateNum," target=\"_blank\"> Catalog Link </a>")
#Subset the records from the central catalog (only HUCs)
HUC_records <- subset(cc,SYM_TOGGLE_HUC==1)
#Select the spatial data that match the subsetted records
HUC_available <- subset(HUC,State_RU %in% unique(HUC_records$JOIN_FIELD_HUC))
#Remove duplicated spatial data
HUC_available <- subset(HUC_available, !duplicated(CATALOGLINK))
#Save formatted data as .RData file
save(HUC_available,file=paste("data","HUC_available.RData",sep="/"))

#County------------------------------------------------------------
#Read in shapefile for counties
County <- readOGR(dsn="data/ESRIShapefiles", layer="County")
#Create link for the report catalog
County$CATALOGLINK <- paste0("<a href = http://www.westernstateswater.org/CentralCatalog/WADE/v0.2/GetCatalog/GetCatalog.php?loctype=COUNTY&loctxt=",County$GEOID,"&orgid=ALL&state=",County$StateNum," target=\"_blank\"> Catalog Link </a>")
#Subset the records from the central catalog (only counties)
CO_records <- subset(cc,SYM_TOGGLE_CO==1)
#Select the spatial data that match the subsetted records
CO_available <- subset(County,GEOID %in% unique(CO_records$COUNTY_FIPS))
#Remove duplicated spatial data
CO_available <- subset(CO_available, !duplicated(CATALOGLINK))
#Save formatted data as .RData file
save(CO_available,file=paste("data","CO_available.RData",sep="/"))
