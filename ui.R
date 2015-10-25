title <- "Mapping Artistic Attention in Amsterdam, 1550-1750"

year_slider <- sliderInput("year_slider", label = "Year Range", min = 1550, max = 1750,
                            value = c(1600, 1650), step = 5, sep = "")

place_types <- checkboxGroupInput("place_types", label = "Place Types",
                                  choices = unique(location_data$type),
                                  selected = unique(location_data$type),
                                  inline = TRUE)

amsterdam_map <- leafletOutput("amsterdam_map", width = "100%", height = 400)

object_table <- dataTableOutput("object_table")

object_info <- uiOutput("object_info")

location_hist <- ggvisOutput("location_hist")

header <- dashboardHeader(title = title)

sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  box(width = 12,
      amsterdam_map,
      inputPanel(year_slider, place_types),
      location_hist),
  box(width = 6, object_table),
  box(width = 6, object_info)
)

dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body,
  title = title,
  skin = "green"
)
