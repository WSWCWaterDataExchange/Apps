#server.R

shinyServer(
  function(input,output,session){
    source("CustomMap.R",local=TRUE)$value
    
    source("CountyMap.R",local=TRUE)$value
    
    source("HUCMap.R",local=TRUE)$value
  }
)