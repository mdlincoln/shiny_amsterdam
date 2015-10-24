shinyServer(function(input, output, session) {

  # Reactive data values

  min_year <- reactive({
    input$year_slider[1]
  })

  max_year <- reactive({
    input$year_slider[2]
  })

  map_objects <- reactive({
    location_data %>%
      filter(dating.yearEarly < max_year() & dating.yearLate >= min_year())
  })

  map_aggregate <- reactive({
    map_objects() %>%
      group_by_("short_place", "longitude", "latitude", "type") %>%
      summarize(count = n())
  })

  # Tables

  # Visualizations

  output$amsterdam_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      fitBounds(lng1 = global_min_lon, lat1 = global_min_lat,
                lng2 = global_max_lon, lat2 = global_max_lat)
  })

  observe({
    leafletProxy("amsterdam_map", data = map_aggregate()) %>%
      clearShapes() %>%
      addCircles(radius = ~sqrt(count) * 10, popup = ~short_place,
                 layerId = ~short_place)
  })
  })

})
