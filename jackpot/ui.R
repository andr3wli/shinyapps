library(shiny) # Web Application Framework for R
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lubridate) # Make Dealing with Dates a Little Easier
library(plotly) # Create Interactive Web Graphics via 'plotly.js'
library(lottodata) # Provides easy access to lottery data sets for research purposes

year_label <- c("2012", "2013", "2014", "2015")
game_label <- c("Lotto 649", "Lotto Max", "Lottario")
zip_label <- c("M1B","M1C","M1E","M1G","M1H","M1J","M1K","M1L","M1M","M1P","M1R","M1S","M1T","M1V","M1W",
               "M2H","M2J","M2K","M2N","M3B","M3C","M3H","M3J","M3K","M3L","M3M","M3N",
               "M4C","M4E","M4G","M4H","M4J","M4K","M4L","M4M","M4N","M4P","M4W","M4X",
               "M4Y,","M5A","M5B","M5G","M5J","M5P","M5R","M5S","M5T","M5V","M6A","M6B","M6C","M6E","M6G",
               "M6H","M6J","M6K","M6L","M6M","M6N","M6P","M6R","M6S","M8V","M8W","M8Y","M8Z","M9A","M9B","M9C","M9L","M9M","M9N","M9P",
               "M9R","M9V","M9W","M2R","M4S","M4T","M5M",
               "M8X","M5C","M5E","M1N","M2M","M3A","M4B","M4A","M2P","M5N","M1X","M5H","M2L","M4V","M4R","M5X","M5L","M5K","M7A")



fluidPage(
  titlePanel("Lottery ticket sales in Toronto"),
  h6("Data from", a("Open Science Framework", href="https://osf.io/qwrxy/")),
  h6("Made by", a("Andrew Li", href="http://andrewcli.me"), "with the", a("Centre for Gambling Research", href="https://cgr.psych.ubc.ca/about/")),

  sidebarLayout(
    sidebarPanel(


      selectInput(inputId = "select_year_t",
                  label = 'Select year',
                  choices = as.list(year_label)),
      selectInput(inputId = "select_game_t",
                  label = "Select game",
                  choices = as.list(game_label)),
      selectInput(inputId = "select_zip_t",
                  label = "Select zip code (first 3 digits)",
                  choices = as.list(zip_label))



    ),

    mainPanel(
      tabsetPanel(id = "plotTabset",
                  tabPanel("Ticket sales",
                           plotlyOutput("plot")
                  ),
                  tabPanel("Jackpot size",
                           plotOutput("plot2")
                  )
      )
    )
  )
)


