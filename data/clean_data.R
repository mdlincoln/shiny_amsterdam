# Import the results of data processing ruby scripts, and reshape into a form
# usable for GIS plotting

library(dplyr)
library(tidyr)
library(stringr)
library(readr)

orig_landscape_data <- read_csv("data/object_data.csv")
name_coordinates <- read_csv("data/location_coordinates.csv")

# Only use those named coordinates with exact values
name_coordinates <- name_coordinates %>% filter(!(is.na(longitude) & is.na(latitude)))

drop_types <- c("avondmaalskelk", "beeld", "beeldhouwwerk", "bouwfragment", "document", "kan", "balkon", "schaal (objectnaam)", "drinkschaal", "tazza", "troffel")

# Use non-location columns as the id variables. This results in a table with one
# row per location; artworks with multiple locations will be represented with
# multiple rows.
multi_row_data <- orig_landscape_data %>%
  gather(
  key=numPlace,
  value=place,
  classification.places.0:classification.places.8,
  na.rm=TRUE) %>%
  filter(!(objectTypes.0 %in% drop_types))

# Join coordinates to each artwork/location row, keeping only those rows with
# places specified in name_coordinates
location_data <- name_coordinates %>% inner_join(multi_row_data, by="place") %>% select(-description) %>% filter(type != "")

location_data$short_place <- str_match(location_data$place, "(.*) \\(Amsterdam\\)")[,2]

save(location_data, file = "data/location_data.RData")
