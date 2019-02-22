library(ggplot2)
library(XML)
library(RColorBrewer)
library(RCurl)
library(plotly)
library(wadeR)
library(leaflet.esri)
library(maps)
library(rgdal)

load('data/ReportingUnitSelection.Rdata')

load('data/simplehuc8.RData')
load('data/simplecounty.RData')
load('data/simplecustom.RData')

data(state)
state_center_lng <- state.center$x[which(state.name == 'Utah')]
state_center_lat <- state.center$y[which(state.name == 'Utah')]

