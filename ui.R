library(leaflet)
library(ShinyDash)

shinyUI(fluidPage(
  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  leafletMap(
    "map", "100%", 400,
    initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(52.371, 4.898),
      zoom = 14
    )
  ),
  fluidRow(
    column(8, offset=3,
           h2('Locations In Amsterdam'),
           htmlWidgetOutput(
             outputId = 'desc',
             HTML(paste('The map is centered at <span id="lat"></span>, <span id="lng"></span>',
                        'with a zoom level of <span id="zoom"></span>.<br/>'
             ))
           )
    )
  ),
  hr(),
  fluidRow(
    column(3,
           sliderInput(
             inputId = "year_range",
             label = "Display Range",
             min = min(location_data$dating.yearEarly),
             max = max(location_data$dating.yearLate),
             value = c(min(location_data$dating.yearEarly), max(location_data$dating.yearLate)),
             format = "####",
             step = 1
           )
    ),
    column(4,
           h4('Visible cities')
#            tableOutput('data')
    ),
    column(5,
#            h4(id='cityTimeSeriesLabel', class='shiny-text-output')
            plotOutput('location_plot', width='100%', height='250px')
    )
  )
))
