get_wade_data <- function(wade_url) {
  
  if(file.exists(wade_url)) {
    content <- wade_url
  } else if(grepl("http", wade_url)) {
    try(content <- getURLContent(wade_url))
  } else {
    stop("Does not appear to be a URL and matching file not found.")
  }
  
  out_df <- data.frame(Sector = "", SourceType = "", Amount = "", stringsAsFactors = F)
  
  try({
    xml_root <- xmlRoot(xmlParse(content,
                                 useInternalNodes = TRUE))
    
    xml_reportsummary <- xml_root[["Organization"]][["Report"]][["ReportingUnit"]][["WaterUseSummary"]]
    
    xml_reportsupply <- xml_root[["Organization"]][["Report"]][["ReportingUnit"]][["DerivedWaterSupplySummary"]]
    
    if(!is.null(xml_reportsummary)) {
      waterusetype <- xmlSApply(xml_reportsummary,
                                function(x) xmlSApply(x[["WaterUseTypeName"]], xmlValue))
      
      out_df <- data.frame(Sector = waterusetype,
                           row.names = NULL,
                           stringsAsFactors = FALSE)
      
      for (i in 1:nrow(out_df)) { # probably a better way to do this?
        xml_use_summary <- xmlSApply(xml_reportsummary[[i]], xmlValue)
        
        amountsummary <- xmlSApply(xml_reportsummary[[i]][["WaterUseAmountSummary"]], xmlValue)
        
        out_df[i,"SourceType"] <- amountsummary[["SourceTypeName"]]
        
        if(is.null(xml_reportsummary[[i]][["WaterUseAmountSummary"]][["WaterUseAmount"]][["AmountNumber"]])) {
          out_df[i,"Amount"] <- as.numeric(NA)
        } else {
          out_df[i,"Amount"] <- as.numeric(xmlSApply(xml_reportsummary[[i]][["WaterUseAmountSummary"]]
                                                     [["WaterUseAmount"]][["AmountNumber"]], 
                                                     xmlValue))
        }
      }
    } else if(!is.null(xml_reportsupply)) {
      wateruse_supply_type <- xmlSApply(xml_reportsupply,
                                        function(x) xmlSApply(x[["WaterSupplyTypeName"]], 
                                                              xmlValue))
      
      out_df <- data.frame(Type = wateruse_supply_type, 
                           row.names = NULL, stringsAsFactors = FALSE)
      
      #Get values for the use amount
      for (i in 1:nrow(out_df)) {
        if(is.null(xml_reportsupply[[i]][[3]][["AmountNumber"]])){
          amount <- as.character(rep(NA, 4))
        } else {
          amount <- xmlSApply(xml_reportsupply[[i]][["SupplyAmountSummary"]][["AmountNumber"]],
                              xmlValue)
        }
        out_df[i,"Amount"] <- as.numeric(amount[1])
      }
    }
  })
  return(out_df)
}




get_wade_method <- function(wade_method_url) {
  
  xml.urlCUMethod <- getURLContent(wade_method_url)
  
  CUmethodroot <- xmlRoot(xmlParse(xml.urlCUMethod))
  
  CUmethodsummary <- CUmethodroot[["Organization"]][["Method"]]
  
  CUmethodinfo <- xmlSApply(CUmethodsummary,function(x) xmlSApply(x,xmlValue))
  
  CUmethod_df <- data.frame(t(CUmethodinfo),row.names=NULL,stringsAsFactors = FALSE)
  
  return(CUmethod_df)
}



get_reporting_units <- function(ru_url) {
  
  if(file.exists(ru_url)) {
    content <- ru_url
  } else if(grepl("http", ru_url)) {
    content <- getURLContent(ru_url)
  } else {
    stop("Does not appear to be a URL and matching file not found.")
  }
  
  
  try({
    xml_root <- xmlRoot(xmlParse(content,
                                 useInternalNodes = TRUE))
    n.reports <- length(xmlToList(xml_root))
    
    RU_df <- data.frame(RowIndex = seq(1,n.reports), ReportingUnit = "", ReportingUnitName = "", stringsAsFactors = F)
    
    for(i in seq(1,n.reports)){
      reporttype <- xmlSApply(xml_root[[i]][["DataType"]],xmlValue)
      if(reporttype == "USE"){
        reportingunit_use <- xmlSApply(xml_root[[i]][["ReportUnitIdentifier"]],xmlValue)
        reportingunitname_use <- xmlSApply(xml_root[[i]][["ReportUnitName"]],xmlValue)
      }else{
        reportingunit_use <- NA
        reportingunitname_use <- NA
      }
      RU_df[i,"ReportingUnit"]<-as.character(reportingunit_use[1])
      RU_df[i,"ReportingUnitName"]<-as.character(reportingunitname_use[1])
    }
    RU_df <- RU_df[(!is.na(RU_df$ReportingUnit)),]
    
    return(RU_df)
  })
}