#' get_wade_method
#'
#' Get method used for WaDE data.
#' 
#' @param wade_method_url character, a url that will return information about methodology used for a specific organization/report
#' @return \code{data.frame} containing methodology information
#' 
#' @export
#' @importFrom XML xmlRoot
#' @importFrom XML xmlParse
#' @importFrom XML xmlSApply
#' @importFrom XML xmlValue
#' @importFrom RCurl getURLContent
#' 
#' @examples 
#' wade_method_url <- paste0("https://water.utah.gov/DWRE/WADE/v0.2/GetMethod/GetMethod.php?methodid=utwre&methodname=CONSUMPTIVE_USE")
#' get_wade_method(wade_method_url)
#' 
get_wade_method <- function(wade_method_url) {
  
  xml.urlCUMethod <- getURLContent(wade_method_url)
  
  CUmethodroot <- xmlRoot(xmlParse(xml.urlCUMethod))
  
  CUmethodsummary <- CUmethodroot[["Organization"]][["Method"]]
  
  CUmethodinfo <- xmlSApply(CUmethodsummary,function(x) xmlSApply(x,xmlValue))
  
  CUmethod_df <- data.frame(t(CUmethodinfo),row.names=NULL,stringsAsFactors = FALSE)
  
  return(CUmethod_df)
}
