A collection of R Shiny apps that display WaDE data


Issue:
dblodgett-usgs opened this issue on Aug 14, 2017 · 3 comments
States based report unit selection map #2

I just ginned up a little test to see what we need to do to get state by state selection maps working.

Using, leaflet, this code will work.
```
library(leaflet.esri)
library(maps)
data(state)
state_center_lng <- state.center$x[which(state.name == "Washington")]
stae_center_lat <- state.center$y[which(state.name == "Washington")]
leaflet() %>%
  addTiles() %>%
  setView(lng = state_center_lng, lat = stae_center_lat, zoom = 6) %>%
  addEsriFeatureLayer(
    url='https://services.arcgis.com/dFb8rUV8WxUeyMa2/arcgis/rest/services/Washington_WRIAs/FeatureServer/0',
    useServiceSymbology = TRUE)
```
That looks like this:
<img width="630" alt="screen shot 2017-08-14 at 1 23 38 pm" src="https://user-images.githubusercontent.com/1492803/29285464-380470c2-80f4-11e7-86c0-d4f5d6da93e9.png">

If I implement the code above in shiny and capture click events like [I do here](https://github.com/WSWCWaterDataExchange/Apps/blob/master/USGSDataApp/map.R#L40) the click properties are like:
```
Browse[2]> names(clk$properties)
[1] "OBJECTID"      "WRIA_ID"       "WRIA_NR"       "WRIA_AREA_"    "WRIA_NM"       "Shape_Leng"   
[7] "WADE_URL"      "Shape__Area"   "Shape__Length"
Browse[2]> clk$properties$WRIA_ID
[1] 7
Browse[2]> clk$properties$WRIA_NR
[1] 48
Browse[2]> clk$properties$WADE_URL
[1] "https://fortress.wa.gov/ecy/wade/v0.2/GetCatalog/GetCatalog?loctype=REPORTUNIT&loctxt=48&orgid=WAECY&state=1"
```

I think the pattern implemented over in the USGS App should work for WaDE state-based apps.

Probably won't need the [mapData reactive function](https://github.com/WSWCWaterDataExchange/Apps/blob/master/USGSDataApp/map.R#L2) unless you want to set up the ability to switch states. 

We will need a [renderLeaflet output like this.](https://github.com/WSWCWaterDataExchange/Apps/blob/master/USGSDataApp/map.R#L17) but it won't need to do any data stuff -- just the leaflet.esri call pasted above.

Something along the lines of the [observe function here](https://github.com/WSWCWaterDataExchange/Apps/blob/master/USGSDataApp/map.R#L36) will be needed to capture the click events and pass up some new variable values.

To actually get the variables out of the observer, we'll need [to do this](https://github.com/WSWCWaterDataExchange/Apps/blob/master/USGSDataApp/server.R#L15) for each variable we need to pass out of the click observer.

I think that's the bones of it. This shouldn't be too bad. I'd be willing to take a crack at implementing this in one of the apps. Which one would be a good starting point?




# Sara commented
Thank you! Looks great, and yeah, not too bad. My preference would be to try it out on the CA data because that one is a little bit more complex than Utah/Wyoming. There are many Detailed Analysis Units (DAUs) in that one for which we need an easier sorting method, plus they have water supply estimates as well as water use (might be nice if we could include that also - just a change in the web service datatype parameter). It might be easier to tackle this for Utah because they should have water use estimates at the HUC-8 scale included in WaDE shortly, which is where you'd like to head eventually, right Dave? Ima let Carly chime in here too. Carly, given your experience with the R/shiny apps so far, which app would you think would be best for Dave to adjust first?

Carly commented 
Just catching up on the leaflet/leaflet.esri updates. Looks awesome! Utah would probably be the easiest one to try out first.

*Edit: Wyoming is actually the easiest to try out - I've been playing with it this afternoon to see if I could get this leaflet to work. Utah or CA would probably more interesting to work with though (multiple data types/report years to work with). 


Carly commented 
Revisiting this now that Utah has multiple types of Reporting Units available for selection... the Utah App now includes this functionality to select by reporting unit type on a map.

