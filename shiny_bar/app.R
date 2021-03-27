library(shiny)
library(shinyWidgets)
library(tidyverse)
library(ggforce)
options(shiny.autoreload = TRUE)
theme_set(theme_void())

country <- c("Canada", "USA", "Austraia", "Argentina", "Australia", "Barbados", "Belgium", "Bermuda", "Brazil", "Bulgaria",
             "Chile", "Croatia", "Cuba", "Czech Rebublic", "Denmark", "Dominican Republic")

ui <- fluidPage(

  tags$head(
    tags$style(HTML("
      @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
      h1 {
        font-family: 'Lobster', cursive;
        font-weight: 500;
        line-height: 1.1;
        color: #ad1d28;
      }
    "))
  ),

  headerPanel("Andrew's Shiny Bar"),

  sidebarPanel(
    h4(
      "Do you need a drink but all the bars are closed?"
    ),
    br(),
    chooseSliderSkin("Round"),
    tags$head(
      tags$style(HTML(
        '.irs-from, .irs-to, .irs-min, .irs-max, .irs-single {
            visibility: hidden !important;}
            .irs-bar, .irs-bar-edge {background: brown;}
            .irs-slider {border-color: brown;}
            '))),
    align="",
    radioButtons("radio", label = "Choose your drink:",
                 choices = list("Beer" = 1, "Red wine" = 2, "White wine" = 3),
                 selected = 1),

    selectInput(inputId = "country",
                label = "Where do you want your beverage from?",
                choices = as.list(country)),

    sliderInput(inputId = "length",
                label = "How much do you want to drink?",
                min = 5,
                max = 25,
                value = 10,
                ticks = FALSE),
    br(),br(),
    em(
      span("Created by", a(href = "https://github.com/andr3wli?tab=repositories", "Andrew Li")),
      HTML("&bull;"),
      span("Code", a(href = "", "on GitHub"))
    )
  ),

  mainPanel(
    h3(textOutput("title")),
    plotOutput("plots")

  )

)

server <- function(input, output) {

  output$title <- renderText({
    if (input$radio == 1){
      return(paste0("Enjoy your beer from ", input$country, "!"))
    }
    if(input$radio == 2 ){
      return(paste0("Enjoy your red wine from ", input$country, "!"))
    }
    if(input$radio == 3){
      return(paste0("Enjoy your white wine from ", input$country, "!"))
    }
    # if(input$radio == 4){
    #   return(paste0("Enjoy your gin from ", input$country, "!"))
    # }
  })
  geom_beer <- function(length = input$length) {

    x = length / 2

    beer <- function(x, y, color = "#bdbdbd", lineend = "butt") {
      list(
        geom_segment(aes(x = -x + 1.5, xend = x - 1.5,
                         y = y, yend = y),
                     size = 60, lineend = lineend, color = color)
      )
    }

    beer_top <- beer(x, 2, lineend = "butt")
    beer_bottom <- beer(x, 0, color = "#969696", lineend = "butt")
    beer_body <- beer(x, 1, color = "#ef3b2c")

    logo <- list(
      geom_segment(aes(x = -x + 3.5, xend = x - 3.5, y = 1.5, yend = 1.5),
                   size = 25, lineend = "round", color = "white"),
      geom_text(aes(x = 0, y = 1.5), label="BEER", size = 12.5),
      geom_text(aes(x = 0, y = -1.5), label=paste("Made in", input$country), size = 5)
    )

    limits <- list(
      xlim(-15, 15),
      ylim(-8, 8)
    )

    return(c(beer_top, beer_bottom, beer_body, logo, limits))
  }

  geom_wine <- function(length = input$length) {

    x = length / 2

    wine <- function(x, y, color = "#00441b", lineend = "butt") {
      list(
        geom_segment(aes(x = -x + 1.5, xend = x - 1.5,
                         y = y, yend = y),
                     size = 60, lineend = lineend, color = color)
      )
    }


    wine_top <- wine(x, 2, color = "#67001f", lineend = "butt")
    wine_bottom <- wine(x, 1, color = "#67001f", lineend = "butt")
    wine_body <- wine(x, -1, color = "#67001f")
    wine_neck <- wine(0.6 * x, 3.5, color = "#67001f")
    wine_cork <- wine(0.6 * x, 5, color = "#980043")

    logo <- list(
      geom_segment(aes(x = -x + 1.5, xend = x - 1.5, y = 1.5, yend = 1.5),
                   size = 25, lineend = "butt", color = "#980043"),
      annotate("text", x = 0, y = 1.5, label = "WINE", size = 10, color = "#ffffd9"),
      annotate("text", x = 0, y = 0.75, label = paste("Made in", input$country), size = 3.5, colour = "#ffffd9")
    )

    limits <- list(
      xlim(-10, 10),
      ylim(-6, 6)
    )

    return(c( wine_cork, wine_neck, wine_top, wine_bottom, wine_body, logo, limits))
  }
  output$plots <- renderPlot({

    if(input$radio == 1){
      return(ggplot() +
               geom_beer() +
               coord_fixed(clip = "off")
      )
    }

    if(input$radio == 2){
      return(
        ggplot() +
          geom_wine() +
          coord_fixed(clip = "off")
      )
    }

  })

}
shinyApp(ui = ui, server = server)
