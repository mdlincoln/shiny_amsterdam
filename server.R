library(leaflet)
library(ggplot2)
library(maps)
library(dplyr)

# From a future version of Shiny
bindEvent <- function(eventExpr, callback, env=parent.frame(), quoted=FALSE) {
  eventFunc <- exprToFunction(eventExpr, env, quoted)

  initialized <- FALSE
  invisible(observe({
    eventVal <- eventFunc()
    if (!initialized)
      initialized <<- TRUE
    else
      isolate(callback())
  }))
}

shinyServer(function(input, output, session) {

  makeReactiveBinding('selectedLocation')

  # Draw only those locations within a certain year range, and tally the
  # number of works made showing each location
  select_locations <- reactive({
    selected <- location_data %>%
    filter(dating.yearLate >= input$year_range[1] &
             dating.yearEarly <= input$year_range[2]) %>%
    group_by(place, latitude, longitude) %>%
    tally()
    return(selected)
  })

  # Create the map; this is not the "real" map, but rather a proxy
  # object that lets us control the leaflet map on the page.
  map <- createLeafletMap(session, 'map')

  # Functions to run every time the map or filters are changed
  observe({

    locations <- select_locations()

    # Re-draw the map with each change
    map$clearShapes()

    # Draw circles for each locaiton on the map
    map$addCircle(
      lat = locations$latitude,
      lng = locations$longitude,
      radius = ((100 * locations$n) / max(10, input$map_zoom)^2),
      layerId = locations$place
    )
  })

  # Pop-ups on click
  observe({
    event <- input$map_shape_click
    if (is.null(event))
      return()
    map$clearPopups()

    locations <- select_locations()

    isolate({
      location <- locations[locations$place == event$id,]
      selectedLocation <<- location
      content <- as.character(tagList(
        tags$strong(paste(location$place)),
        tags$br(),
        paste("Depicted", location$n, "times between", input$year_range[1], "and", input$year_range[2])
      ))
      map$showPopup(event$lat, event$lng, content, event$id)
    })
  })

  output$desc <- reactive({
    if (is.null(input$map_bounds))
      return(list())
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom
    )
  })
})
