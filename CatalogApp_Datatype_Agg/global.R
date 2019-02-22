#Load packages
library(shiny)
library(rgdal)
library(leaflet)

#Load local data
load('data/allstates.RData')


agg_availability_co <- readRDS('data/County/agg_availability_CO.rds')
agg_regulatory_co <- readRDS('data/County/agg_regulatory_CO.rds')
agg_supply_co <- readRDS('data/County/agg_supply_CO.rds')
agg_use_co <- readRDS('data/County/agg_use_CO.rds')


agg_availability_huc <- readRDS('data/HUC/agg_availability_HUC.rds')
agg_regulatory_huc <- readRDS('data/HUC/agg_regulatory_HUC.rds')
agg_supply_huc <- readRDS('data/HUC/agg_supply_HUC.rds')
agg_use_huc <- readRDS('data/HUC/agg_use_HUC.rds')

agg_availability_custom <- readRDS('data/CustomRU/agg_availability_custom.rds')
agg_regulatory_custom <- readRDS('data/CustomRU/agg_regulatory_custom.rds')
agg_supply_custom <- readRDS('data/CustomRU/agg_supply_custom.rds')
agg_use_custom <- readRDS('data/CustomRU/agg_use_custom.rds')
