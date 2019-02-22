#Load packages
library(shiny)
library(rgdal)
library(leaflet)

#Load local data
load('data/allstates.RData')


ss_allocation_co <- readRDS('data/County/ss_allocation_CO.rds')
ss_cuse_co <- readRDS('data/County/ss_cuse_CO.rds')
ss_diversion_co <- readRDS('data/County/ss_diversion_CO.rds')
ss_rf_co <- readRDS('data/County/ss_rf_CO.rds')

ss_allocation_huc <- readRDS('data/HUC/ss_allocation_HUC.rds')
ss_cuse_huc <- readRDS('data/HUC/ss_cuse_HUC.rds')
ss_diversion_huc <- readRDS('data/HUC/ss_diversion_HUC.rds')
ss_rf_huc <- readRDS('data/HUC/ss_rf_HUC.rds')

ss_allocation_custom <- readRDS('data/CustomRU/ss_allocation_custom.rds')
ss_cuse_custom <- readRDS('data/CustomRU/ss_cuse_custom.rds')
ss_diversion_custom <- readRDS('data/CustomRU/ss_diversion_custom.rds')
ss_rf_custom <- readRDS('data/CustomRU/ss_rf_custom.rds')
