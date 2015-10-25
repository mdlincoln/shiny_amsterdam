library(shiny)
library(leaflet)
library(dplyr)
library(ggvis)
library(shinydashboard)
library(DT)
library(stringr)
library(markdown)

load("data/location_data.RData")

location_data <- location_data %>% filter(short_place != "Omval, De")

global_min_lon <- min(location_data$longitude)
global_max_lon <- max(location_data$longitude)
global_min_lat <- min(location_data$latitude)
global_max_lat <- max(location_data$latitude)
