#server.R

shinyServer(function(input,output,session){
  
  #Reference files with leaflet maps for aggregated (Agg) data
  
  #source("AggMap_Availability.R",local=TRUE)$value
  
  source("AggMap_Regulatory.R",local=TRUE)$value
  
  source("AggMap_Supply.R",local=TRUE)$value
  
  source("AggMap_Use.R",local=TRUE)$value


  }
)