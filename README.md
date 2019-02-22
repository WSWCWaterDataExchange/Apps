# Apps
This repository includes applications and packages that work with the WaDE web services and data.

These tools are being developed to help demonstrate the utility of sharing data via WaDE. 
Goals include:
- facilitating data summarization
- demonstrating convenient visualization techniques
- enabling quick comparisons of water use or diversions (for instance, by sector (e.g. agricultural or municipal/industrial))

The R Shiny applications consists of two primary R scripts: ui.R and server.R. The server.R script uses the WaDE web services to query the WaDE database and return water use data for the user-specified reporting units. Additional scripts may be included in the application folders to augment functionality or provide datasets to the application. 
To run these apps locally, you may need to install the following packages, as well as the wadeR package (see below for a description and installation instructions):
```
install.packages("ggplot2","XML","RColorBrewer","RCurl","plotly","leaflet.esri","maps","rgdal")
```
---

Apps used for the WaDE Data Portal include:
- CatalogApp_Location
- CatalogApp_DatatypeAgg
- CatalogApp_DatatypeSS

---

The Utah Data App is hosted at the link below. Note that the app may take a few seconds to load (due to the Secure Sockets Layer (SSL) Certificate that is installed on the App data server).

http://apps.westernstateswater.org/

---

This repository also contains an R package (under development), called **wadeR**.
Functions in wadeR include:

| Function | Description |
|----------|-------------|
| get_wade_data | Retrieves data (e.g. consumptive use, diversions, etc.) from a given url which utilizes the WaDE GetSummary web service (or file) and parses through the XML. |
| get_reporting_units | Retrieves content from a url using the WaDE GetCatalog_GetAll web service and parses through the XML to return a dataframe of reporting units for a specific state. |

The package can be installed and loaded using the following commands:

```
library(devtools)
install_github("WSWCWaterDataExchange/Apps/wadeR")
```
You will need to install several dependencies:
```
install.packages("wateRuse","RCurl","XML")
```
Load the wadeR package using:
```
library(wadeR)
```


