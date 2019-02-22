#' get_state_spatial_units
#'
#' Returns an `SpatialPolygonsDataframe` of county, huc, or aquifer boundaries for a state. (Aquifers not supported yet)
#'
#' 
#' @param state character name of state
#' @param unit_type chr, type of unit to be mapped; acceptable options are "county", "huc", or "aquifer"
#' @param year int, a year for which representative units are needed. (not implemented)
#' 
#' @export
#' 
#' @importFrom wateRuse subset_county_polygons
#' @importFrom wateRuse subset_huc_polygons
#' @importFrom wateRuse stateCd
#' 
#' @examples 
#' state <- "Delaware" 
#' unit_type <- "huc"
#' year <- 2010
#' plot_units <- get_state_spatial_units(state, unit_type, year)
#' plot_units
#' 
get_state_spatial_units <- function(state, unit_type, year){
  
  if(unit_type=="county"){
    
    spatial_units_sp <- subset_county_polygons(year, "STATE_TERR", state)
    
  } else if (unit_type=="huc"){
    
    state <- stateCd$STUSAB[which(stateCd$STATE_NAME == state)]
    
    spatial_units_sp <- subset_huc_polygons(year, "STATES", state)
    
    label_name <- "NAME"
    id_name <- "HUC8"
    
  } else if (unit_type=="aquifer"){
    
    stop("aquifer not supported yet")
    
  }
  
  names(spatial_units_sp@data)[which(names(spatial_units_sp@data) == label_name)] <- "wade_app_label"
  names(spatial_units_sp@data)[which(names(spatial_units_sp@data) == id_name)] <- "wade_app_id"
  
  return(spatial_units_sp)
  
}