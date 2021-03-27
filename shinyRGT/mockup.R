library(shiny) # Web Application Framework for R
library(ggplot2) # Create Elegant Data Visualisations Using the Grammar of Graphics
library(stringr) # Simple, Consistent Wrappers for Common String Operations

ui <- fluidPage(

  title = "Shiny ggplot",

  fluidRow(
    column(3,
           fileInput("file1", "Choose file to upload",
                     accept = c(
                       "text/csv",
                       "text/comma-separated-values",
                       "text/tab-separated-values",
                       "text/plain",
                       ".csv",
                       ".tsv"
                     )
           )
    ),
    column(2,
           # varSelectInput("x_axis", label = "x axis", mtcars, selected = names(mtcars)[1]),
           uiOutput("x_axis"),
           textInput("label_x", label = "X axis label")),
    column(2,
           # varSelectInput("y_axis", label = "y axis", mtcars, selected = colnames(mtcars)[2]),
           uiOutput("y_axis"),
           textInput("label_y", label = "Y axis label")),
    column(2,
           selectInput("color", label = "Color", choices = c("grey10", "blue", "purple", "pink")),
           selectInput("theme", label = "Theme", choices = c("grey", "classic", "minimal", "bw", "light", "dark"))
    ),
    column(2,
           sliderInput("size", label = "Size", min = 0, max = 5, step = 0.5, value = 1),
           selectInput("coordinates", label = "Coordinates", choices = c("cartesian", "fixed", "polar"))
    )
  ),



  plotOutput("plot"),
  textOutput("plot_code"),

  fluidRow(
    column(3,
           textInput("plot_title", label = "Plot title", value = deparse(substitute(mtcars))),
           textInput("plot_subtitle", label = "Plot subtitle")
    ),

    column(3,
           checkboxInput("facet_switch", label = "Facets", value = FALSE),
           conditionalPanel(condition = "input.facet_switch",
                            uiOutput("facet")
           )
    ),

    column(3,
           checkboxInput("smoothing_switch", label = "Smoothing", value = FALSE),
           conditionalPanel(condition = "input.smoothing_switch",
                            selectInput("smoothing", label = NULL, choices = c("lm", "glm", "gam", "loess"))
           )
    ),

    column(2,
           downloadButton("export_plot", label = "Export plot"),
           downloadButton("export_code", label = "Get code")
    )
  )
)



server <- function(input, output, session) {

  data_upload <- reactive({
    if (is.null(input$file1)) {
      df <- mtcars
    } else {
      df <- read.csv(input$file1$datapath)
    }
  })

  output$x_axis <- renderUI({
    selectInput("x_axis", label = " X axis", choices = names(data_upload()), selected = names(data_upload())[1])
  })

  output$y_axis <- renderUI({
    selectInput("y_axis", label = "Y axis", choices = names(data_upload()), selected = names(data_upload())[2])
  })

  output$facet <- renderUI({
    selectInput("facet", "facet", choices = names(data_upload()), selected = names(data_upload())[3])
  })


  plotInput <- function(){

    ggplot_code <- paste0(
      "ggplot(data = data, aes(x = ", input$x_axis,
      ", y = ", input$y_axis, ")) + \n",
      "geom_point(size = ", input$size, ",
    color = 'input$color') + \n",
      if (input$smoothing_switch) paste0("geom_smooth(method = ", input$smoothing, ", color = 'grey10') + \n") else NULL,
      "labs(
      title = 'input$plot_title',
      subtitle = 'input$plot_subtitle',
      x = 'input$label_x',
      y = 'input$label_y'
    ) + \n",
      "coord_", input$coordinates, "() + \n",
      if (input$facet_switch) paste0("facet_wrap(vars(", input$facet, ")) + \n") else NULL,
      "theme_", input$theme, "()"
    )

    ggplot_code <- str_replace_all(ggplot_code,
                                   c(
                                     "input\\$x_axis" = input$x_axis,
                                     "input\\$y_axis" = input$y_axis,
                                     "input\\$size" = input$size,
                                     "input\\$color" = input$color,
                                     "input\\$plot_title" = input$plot_title,
                                     "input\\$plot_subtitle" = input$plot_subtitle,
                                     "input\\$label_x" = input$label_x,
                                     "input\\$label_y" = input$label_y,
                                     "input\\$coordinates" = input$coordinates,
                                     "input\\$smoothing" = input$smoothing,
                                     "input\\$facet" = input$facet,
                                     "input\\$theme" = input$theme
                                   )
    )

    ggplot_code
  }

  output$plot <- renderPlot({
    data <- data_upload()
    eval(parse(text = plotInput()))
  })

  output$export_plot <- downloadHandler(
    filename = function() { "plot.png" },
    content = function(file) {
      data <- data_upload()
      p <- eval(parse(text = plotInput()))
      ggsave(file, plot = p, device = "png")
    }
  )

  output$export_code <- downloadHandler(
    filename = function() { "code.R" },
    content = function(file) {
      writeLines(as.character(plotInput()), file)
    }
  )

}

shinyApp(ui, server)
