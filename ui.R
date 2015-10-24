title <- "Mapping Artistic Attention in Amsterdam, 1550-1750"

year_slider <- sliderInput("year_slider", label = "Year Range", min = 1550, max = 1750,
                            value = c(1600, 1650), step = 5, sep = "")

amsterdam_map <- leafletOutput("amsterdam_map", width = "100%", height = 400)

object_table <- dataTableOutput("object_table")

location_hist <- ggvisOutput("location_hist")

header <- dashboardHeader(title = title)

sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  box(width = 12, amsterdam_map, year_slider, location_hist),
  box(width = 12, object_table)
)

dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body,
  title = title,
  skin = "green"
)
