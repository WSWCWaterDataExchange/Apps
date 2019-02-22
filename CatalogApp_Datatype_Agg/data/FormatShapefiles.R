############Format shapefile data#########################
##########################################################
#Load necessary packages
library(rgdal) #Reading shapefiles
library(RPostgreSQL) #Connecting to the PG (Central Catalog) Database
library(rmapshaper) #Simplifying spatial data

#Load Central Catalog data
#Connect to Postgres Database
con <- dbConnect(PostgreSQL(),
                 user="user",
                 password="password",
                 host="host",
                 port="11111",
                 dbname="dbname")

#Query central catalog table
cc <- dbGetQuery(con,"select * from \"WADE\".\"CATALOG_SUMMARY_MV\"")

#Subset Central Catalog Data based on datatype and reporting unit
#County
cc_agg_supply_co <- subset(cc, DATATYPE=="SUPPLY" & SYM_TOGGLE_CO==1)
cc_agg_availability_co <- subset(cc, DATATYPE=="AVAILABILITY"& SYM_TOGGLE_CO==1)
cc_agg_use_co <- subset(cc, DATACATEGORY=="SUMMARY" & DATATYPE=="USE"& SYM_TOGGLE_CO==1)
cc_agg_regulatory_co <- subset(cc, DATATYPE=="REGULATORY"& SYM_TOGGLE_CO==1)

#HUC
cc_agg_supply_huc <- subset(cc, DATATYPE=="SUPPLY" & SYM_TOGGLE_HUC==1)
cc_agg_availability_huc <- subset(cc, DATATYPE=="AVAILABILITY"& SYM_TOGGLE_HUC==1)
cc_agg_use_huc <- subset(cc, DATACATEGORY=="SUMMARY" & DATATYPE=="USE"& SYM_TOGGLE_HUC==1)
cc_agg_regulatory_huc <- subset(cc, DATATYPE=="REGULATORY"& SYM_TOGGLE_HUC==1)

#Custom
cc_agg_supply_custom <- subset(cc, DATATYPE=="SUPPLY" & SYM_TOGGLE_RU==1)
cc_agg_availability_custom <- subset(cc, DATATYPE=="AVAILABILITY"& SYM_TOGGLE_RU==1)
cc_agg_use_custom <- subset(cc, DATACATEGORY=="SUMMARY" & DATATYPE=="USE"& SYM_TOGGLE_RU==1)
cc_agg_regulatory_custom <- subset(cc, DATATYPE=="REGULATORY"& SYM_TOGGLE_RU==1)

############################################################
#Format layer of all Western States
allstates <- readOGR(dsn="data/ESRIShapefiles",layer="AllWesternStates_PlusAK")
save(allstates,file="data/allstates.RData")

#HUC-------------------------------------------------------------
HUC <- readOGR(dsn="data/ESRIShapefiles", layer="HUC")
#County------------------------------------------------------------
County <- readOGR(dsn="data/ESRIShapefiles", layer="County")
#Custom Reporting Units-----------------------------------------------------
CustomRU <- readOGR(dsn="data/ESRIShapefiles", layer="Custom") #This shapefile includes CA DAU (not the other types of custom reporting units)

#Subsets the spatial data to the reporting units with available reports and creates popup link
subset_spatial_data <- function(ru_type,ccdata,urlcolname,filename){
  if(ru_type=="County"){
    ru_type <- "CO"
    spatial_data <- County}
  if(ru_type=="RU"){
    spatial_data <- RU
  }
  if(ru_type=="HUC"){
    spatial_data <- HUC
  }
  #Limit spatial data to those RUs that have reports in the central catalog
  #For HUCs limit to HUC8
  if(ru_type=="HUC"){
    spatial_sub <- subset(spatial_data,State_RU %in% unique(substr(ccdata[,paste0("JOIN_FIELD_",ru_type)],1,11)))
  }else{
    spatial_sub <- subset(spatial_data,State_RU %in% unique(ccdata[,paste0("JOIN_FIELD_",ru_type)]))
  }
  #Check if there are any reports for that specific datatype
  if(length(spatial_sub)>0){
    #Merge spatial data and central catalog data
    #For HUCs limit display to HUC8
    if(ru_type=="HUC"){
      ccdata$JOIN_FIELD_HUC <- substr(ccdata$JOIN_FIELD_HUC,1,11)
      spatial_sub_merge <- sp::merge(spatial_sub,ccdata, by.x = 'State_RU',by.y=paste0("JOIN_FIELD_",ru_type), duplicateGeoms = TRUE)
    }else{
      spatial_sub_merge <- sp::merge(spatial_sub,ccdata, by.x = 'State_RU',by.y=paste0("JOIN_FIELD_",ru_type), duplicateGeoms = TRUE)
    }
    #Create a spatial data file with for display (i.e. eliminate redundant RUs with more than one report)
    spatial_sub_map_unique <- subset(spatial_sub_merge, !duplicated(State_RU))
    #Get all urls for each reporting unit
    for(i in unique(as.character(spatial_sub_map_unique$State_RU))){
      #Subset data for an individual reporting unit
      spatial_sub_map2 <- subset(spatial_sub_merge,State_RU==i)
      #For each organization, create a string of url links (these will show in the popup for the reporting unit)
      reporturllinkstring <- ""
      for(j in unique(spatial_sub_map2$ORGANIZATION_ID)){
        #Subset spatial data for an individual organization 
        spatial_sub_map3 <- spatial_sub_map2[(spatial_sub_map2$ORGANIZATION_ID==j),]
        #Get list of unique reports for the datatype, reporting unit, and organization
        reports <- data.frame(REPORT_ID=(spatial_sub_map3$REPORT_ID))
        urls <- data.frame(spatial_sub_map3[,urlcolname])
        if(ru_type=="CO"){
          ruids <- data.frame(spatial_sub_map3$COUNTY_FIPS)
        }else if(ru_type=="HUC"){
          ruids <- data.frame(spatial_sub_map3$HUC)
        }else if(ru_type=="RU"){
          ruids <- data.frame(spatial_sub_map3$REPORT_UNIT_ID)
        }
        reporturls <- cbind(reports,urls,ruids)
        colnames(reporturls) <- c("ReportID","URL","RUID")
        reporturls <- reporturls[!duplicated(reporturls),]
        #Create the link for each report (formatted to display as "ReportID - ReportingUnitID")
        reporturls$link <- paste("<a href = ",reporturls$URL," target=\"_blank\">",reporturls$ReportID,"-",reporturls$RUID,"</a>")
        reporturls <- reporturls[order(reporturls$ReportID),]
        #Combine all the links into a single string (so that it will display in the popup)
        linkstring <- paste(reporturls$link,collapse=',')
        reporturllinkstring <- paste(reporturllinkstring,linkstring)
      }
      #Limit to unique reporting units (so each reporting unit is listed only once)
      spatial_sub_map_unique[(spatial_sub_map_unique$State_RU==i),"REPORTLINK"] <- reporturllinkstring
    }
  }else{
    #If there are no records in the central catalog, an empty spatial layer is created (it needs to exist, or there will be an error when loading the map)
    spatial_sub_map_unique <- SpatialPolygonsDataFrame(SpatialPolygons(list()), data=data.frame())
  }
  saveRDS(spatial_sub_map_unique,file=paste0("data/",filename,".rds"))
}

#Apply function to all reporting unit and datatypes

#Counties
subset_spatial_data("County",cc_agg_availability_co,"SUM_AVAIL_CO","County/agg_availability_CO")
subset_spatial_data("County",cc_agg_regulatory_co,"SUM_REG_CO","County/agg_regulatory_CO")
subset_spatial_data("County",cc_agg_supply_co,"SUM_SUPPLY_CO","County/agg_supply_CO")
subset_spatial_data("County",cc_agg_use_co,"SUM_USE_CO","County/agg_use_CO")

#HUCs
subset_spatial_data("HUC",cc_agg_availability_huc,"SUM_AVAIL_HUC","HUC/agg_availability_HUC")
subset_spatial_data("HUC",cc_agg_regulatory_huc,"SUM_REG_HUC","HUC/agg_regulatory_HUC")
subset_spatial_data("HUC",cc_agg_supply_huc,"SUM_SUPPLY_HUC","HUC/agg_supply_HUC")
subset_spatial_data("HUC",cc_agg_use_huc,"SUM_USE_HUC","HUC/agg_use_HUC")

#CustomUnits
RU <- CustomRU
subset_spatial_data("RU",cc_agg_availability_custom,"SUM_AVAIL_RU","CustomRU/agg_availability_custom")
subset_spatial_data("RU",cc_agg_regulatory_custom,"SUM_REG_RU","CustomRU/agg_regulatory_custom")
subset_spatial_data("RU",cc_agg_supply_custom,"SUM_SUPPLY_RU","CustomRU/agg_supply_custom")
subset_spatial_data("RU",cc_agg_use_custom,"SUM_USE_RU","CustomRU/agg_use_custom")

