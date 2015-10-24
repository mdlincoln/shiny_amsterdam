shinyServer(function(input, output, session) {

  # Reactive data values

  min_year <- reactive({
    input$year_slider[1]
  })

  max_year <- reactive({
    input$year_slider[2]
  })

  place_types <- reactive({
    input$place_types
  })

  map_objects <- reactive({
    location_data %>%
      filter(
        dating.yearEarly < max_year() &
          dating.yearLate >= min_year() &
          type %in% place_types())
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
      addProviderTiles("Acetate.terrain") %>%
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

  selected_objects <- reactive({
    if(is.null(clicked_place())) {
       map_objects()
    } else {
      map_objects() %>%
        filter(short_place == clicked_place())
    }
  })

  output$object_table <- renderDataTable({
    selected_objects() %>%
      mutate(
        obj_no = substring(id, 4),
        object_link = paste0("<a href='https://www.rijksmuseum.nl/en/collection/", obj_no, "'>", obj_no, "</a>"),
        thumb_link = paste0(str_replace(webImage.url, "=s0", "=s200")),
        object_img = paste0("<img src='", thumb_link, "'>")
      ) %>%
      select("object number" = object_link, title, "image" = object_img)
  }, escape = FALSE)

})
