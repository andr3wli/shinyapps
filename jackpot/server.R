library(shiny) # Web Application Framework for R
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lubridate) # Make Dealing with Dates a Little Easier
library(plotly) # Create Interactive Web Graphics via 'plotly.js'
library(lottodata) # Provides easy access to lottery data sets for research purposes


server <- function(input, output) {
  jackpot <- read_csv("www/Jackpot_sizes.csv")
  # jackpot <- jackpot_size
  jackpot <- jackpot %>%
    mutate(date = ymd(DATE)) %>%
    mutate_at(vars(DATE), funs(year, month, day))

  year_label <- c("2012", "2013", "2014", "2015")
  game_label <- c("Lotto 649", "Lotto Max", "Lottario")
  zip_label <- c("M1B","M1C","M1E","M1G","M1H","M1J","M1K","M1L","M1M","M1P","M1R","M1S","M1T","M1V","M1W",
                 "M2H","M2J","M2K","M2N","M3B","M3C","M3H","M3J","M3K","M3L","M3M","M3N",
                 "M4C","M4E","M4G","M4H","M4J","M4K","M4L","M4M","M4N","M4P","M4W","M4X",
                 "M4Y,","M5A","M5B","M5G","M5J","M5P","M5R","M5S","M5T","M5V","M6A","M6B","M6C","M6E","M6G",
                 "M6H","M6J","M6K","M6L","M6M","M6N","M6P","M6R","M6S","M8V","M8W","M8Y","M8Z","M9A","M9B","M9C","M9L","M9M","M9N","M9P",
                 "M9R","M9V","M9W","M2R","M4S","M4T","M5M",
                 "M8X","M5C","M5E","M1N","M2M","M3A","M4B","M4A","M2P","M5N","M1X","M5H","M2L","M4V","M4R","M5X","M5L","M5K","M7A")



  output$plot <- renderPlotly({
    p <- jackpot %>%
      filter(year == input$select_year_t & GAME == input$select_game_t & FSA == input$select_zip_t) %>%
      ggplot(aes(x = day, y = TICKETS, fill = as.factor(month))) +
      geom_col(show.legend = F) +
      facet_wrap(~month, labeller = labeller(month =
                                               c("1" = "January", "2" = "February", "3" = "March", "4" = "April", "5" = "May",
                                                 "6" = "June", "7" = "July", "8" = "August", "9" = "September", "10" = "October",
                                                 "11" = "November", "12" = "December"))) +
      labs(x = "", y = "# of tickets sold", title = paste(input$select_game_t, "tickets sales in", input$select_year_t, "-",input$select_zip_t)) +
      theme_classic() +
      theme(legend.position = "none") +
      scale_fill_manual(values = c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c",
                                   "#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffed6f","#b15928"))
    ggplotly(p, hoverinfo = "text",
             text = paste("Day: ", jackpot$day,
                          "<br>",
                          "# of tickets sold: ", jackpot$TICKETS,
                          "<br>",
                          "Month: ", jackpot$month)) %>%
      config(displayModeBar = F)

  })
  output$plot2 <- renderPlot({
    jackpot %>%
      filter(year == input$select_year_t & GAME == input$select_game_t & FSA == input$select_zip_t) %>%
      ggplot(aes(x = day, y = Jackpot, color = as.factor(month))) +
      geom_line(group = 1) +
      geom_point() +
      facet_wrap(~month, labeller = labeller(month =
                                               c("1" = "January", "2" = "February", "3" = "March", "4" = "April", "5" = "May",
                                                 "6" = "June", "7" = "July", "8" = "August", "9" = "September", "10" = "October",
                                                 "11" = "November", "12" = "December"))) +
      labs(x = "", y = "", title = paste(input$select_game_t, "jackpot prize in", input$select_year_t, "-",input$select_zip_t)) +
      theme_classic() +
      theme(legend.position = "none") +
      scale_y_continuous(labels = scales::dollar_format()) +
      scale_color_manual(values = c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c",
                                    "#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffed6f","#b15928"))
    # ggplotly(p, hoverinfo = "text",
    #          text = paste("Day: ", jackpot$day,
    #                       "<br>",
    #                       "# of tickets sold: ", jackpot$TICKETS,
    #                       "<br>",
    #                       "Month: ", jackpot$month)) %>%
    #     config(displayModeBar = F)
  })

}

