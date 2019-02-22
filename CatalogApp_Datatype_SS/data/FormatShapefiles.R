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
cc_ss_allocation_co <- subset(cc, DATATYPE=="ALLOCATION"& SYM_TOGGLE_CO==1)
cc_ss_diversion_co <- subset(cc, DATATYPE=="DIVERSION"& SYM_TOGGLE_CO==1)
cc_ss_cuse_co <- subset(cc, DATACATEGORY=="DETAIL" & DATATYPE=="USE"& SYM_TOGGLE_CO==1)
cc_ss_rf_co <- subset(cc, DATATYPE=="RETURN"& SYM_TOGGLE_CO==1)

#HUC
cc_ss_allocation_huc <- subset(cc, DATATYPE=="ALLOCATION"& SYM_TOGGLE_HUC==1)
cc_ss_diversion_huc <- subset(cc, DATATYPE=="DIVERSION"& SYM_TOGGLE_HUC==1)
cc_ss_cuse_huc <- subset(cc, DATACATEGORY=="DETAIL" & DATATYPE=="USE"& SYM_TOGGLE_HUC==1)
cc_ss_rf_huc <- subset(cc, DATATYPE=="RETURN"& SYM_TOGGLE_HUC==1)

#Custom
cc_ss_allocation_custom <- subset(cc, DATATYPE=="ALLOCATION"& SYM_TOGGLE_RU==1)
cc_ss_diversion_custom <- subset(cc, DATATYPE=="DIVERSION"& SYM_TOGGLE_RU==1)
cc_ss_cuse_custom <- subset(cc, DATACATEGORY=="DETAIL" & DATATYPE=="USE"& SYM_TOGGLE_RU==1)
cc_ss_rf_custom <- subset(cc, DATATYPE=="RETURN"& SYM_TOGGLE_RU==1)

###############################################################################
#Format layer of all Western States (outline) 
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
subset_spatial_data("County",cc_ss_allocation_co,"DET_ALL_CO","County/ss_allocation_CO")
subset_spatial_data("County",cc_ss_cuse_co,"DET_CUSE_CO","County/ss_cuse_CO")
subset_spatial_data("County",cc_ss_diversion_co,"DET_DIV_CO","County/ss_diversion_CO")
subset_spatial_data("County",cc_ss_rf_co,"DET_RF_CO","County/ss_rf_CO")

#HUCs
subset_spatial_data("HUC",cc_ss_allocation_huc,"DET_ALL_HUC","HUC/ss_allocation_HUC")
subset_spatial_data("HUC",cc_ss_cuse_huc,"DET_CUSE_HUC","HUC/ss_cuse_HUC")
subset_spatial_data("HUC",cc_ss_diversion_huc,"DET_DIV_HUC","HUC/ss_diversion_HUC")
subset_spatial_data("HUC",cc_ss_rf_huc,"DET_RF_HUC","HUC/ss_rf_HUC")

#CustomUnits
RU <- CustomRU
subset_spatial_data("RU",cc_ss_allocation_custom,"DET_ALL_RU","CustomRU/ss_allocation_custom")
subset_spatial_data("RU",cc_ss_cuse_custom,"DET_CUSE_RU","CustomRU/ss_cuse_custom")
subset_spatial_data("RU",cc_ss_diversion_custom,"DET_DIV_RU","CustomRU/ss_diversion_custom")
subset_spatial_data("RU",cc_ss_rf_custom,"DET_RF_RU","CustomRU/ss_rf_custom")

