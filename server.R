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

  clicked_place <- reactive({
    if(is.null(input$amsterdam_map_shape_click)) {
      return(NULL)
    } else {
      return(input$amsterdam_map_shape_click$id)
    }
  })

  observe({
    if(is.null(clicked_place())) {
      hist_data <- location_data
    } else {
      hist_data <- location_data %>%
        filter(short_place == clicked_place())
    }

    hist_data %>%
      ggvis(~dating.year) %>%
      layer_histograms(width = 1) %>%
      scale_numeric("x", domain = c(1550, 1750)) %>%
      add_axis("x", format = "####", values = seq(1550, 1750, by = 25)) %>%
      set_options(width = "auto", height = 200, resizable = FALSE) %>%
      bind_shiny("location_hist")
  })

})
