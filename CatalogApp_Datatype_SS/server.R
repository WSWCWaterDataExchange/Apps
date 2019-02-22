#server.R

shinyServer(function(input,output,session){
  
  #Reference files with leaflet maps for site specific (SS) and aggregated (Agg) data
  source("SSMap_Allocation.R",local=TRUE)$value
  
  source("SSMap_CUse.R",local=TRUE)$value
  
  source("SSMap_Diversion.R",local=TRUE)$value
  
  source("SSMap_RF.R",local=TRUE)$value
  }
)