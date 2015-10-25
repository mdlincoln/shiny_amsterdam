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
      addProviderTiles("Esri.WorldGrayCanvas") %>%
      fitBounds(lng1 = global_min_lon, lat1 = global_min_lat,
                lng2 = global_max_lon, lat2 = global_max_lat) %>%
      addLegend("bottomright", pal = pal, values = map_aggregate()$type, title = "Place type")
  })

  pal <- colorFactor(brewer.pal(n_distinct(location_data$type), "Paired"), unique(location_data$type))

  observe({
    leafletProxy("amsterdam_map", data = map_aggregate()) %>%
      clearShapes() %>%
      addCircles(radius = ~sqrt(count) * 10, popup = ~short_place,
                 layerId = ~short_place, color = ~pal(type), opacity = 0.8)
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

  visible_obj_table <- reactive({
    selected_objects() %>%
      mutate(
        obj_no = substring(id, 4),
        object_link = paste0("<a href='https://www.rijksmuseum.nl/en/collection/", obj_no, "'>", obj_no, "</a>"),
        thumb_link = paste0(str_replace(webImage.url, "=s0", "=s100")),
        object_img = ifelse(webImage.url == "", "no image", paste0("<img src='", thumb_link, "'>"))
      )
  })

  output$object_table <- renderDataTable({
    visible_obj_table() %>%
      select("object number" = object_link, title, "image" = object_img)
  }, escape = FALSE, selection = "single", server = FALSE)

  selected_object <- reactive({
    input$object_table_rows_selected
  })

  output$object_info <- renderUI({
    if(is.null(selected_object()))
      return(p("Select an object to view in detail."))

    object_row <- visible_obj_table()[selected_object(),]

    places <- location_data$short_place[location_data$id == object_row$id]

    div(
      if(!is.na(object_row$thumb_link))
        img(src = str_replace(object_row$thumb_link, "s100", "s0"), width = "100%"),
      p(strong("Title: "), object_row$title),
      p(strong("Date: "), paste(object_row$dating.yearEarly, object_row$dating.yearLate, sep = "-")),
      p(strong("Type: "), object_row$objectTypes.0),
      p(strong("Creators: "), paste(na.omit(c(object_row$principalMakers.0.name, object_row$principalMakers.1.name, object_row$principalMakers.2.name, object_row$principalMakers.3.name)), collapse = ", ")),
      p(strong("Places: "), paste(places, collapse = ", "))
    )
  })

})
