if(!(exists("location_data"))) {
  if(file.exists("data/location_data.RData")) {
    load("data/location_data.RData")
  } else {
    source("data/clean_data.R")
    load("data/location_data.RData")
  }
}
