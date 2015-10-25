title <- "Mapping Artistic Attention in Amsterdam, 1550-1750"
shortitle <- "Depicting Amsterdam"

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

header <- dashboardHeader(title = shortitle)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(tabName = "main_map", text = "Map", icon = icon("map-marker")),
    menuItem(text = "Source code", href = "https://github.com/mdlincoln/shiny_amsterdam", icon = icon("code-fork"))
  )
)

main_map <- tabItem(
  tabName = "main_map",
  box(width = 12, includeMarkdown("md/about.md")),
  box(
    width = 12,
    fluidRow(
      column(3, year_slider, place_types),
      column(9, amsterdam_map)),
    fluidRow(location_hist)),
  box(width = 6, object_table),
  box(width = 6, object_info))



body <- dashboardBody(
  tabItems(
    main_map
  )
)

dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body,
  title = title,
  skin = "red"
)
