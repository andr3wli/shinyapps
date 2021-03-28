###
# Shiny app by Andrew Li
###
# load required packages
library(shiny) # Web Application Framework for R
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(ggiraph) # Make 'ggplot2' Graphics Interactive
library(DescTools) # Tools for Descriptive Statistics
library(DT) # A Wrapper of the JavaScript Library 'DataTables'
library(leaflet) # Create Interactive Web Maps with the JavaScript 'Leaflet'
library(lubridate) # Make Dealing with Dates a Little Easier
library(lottodata) # Provides easy access to lottery data sets for research purposes
library(ggtext) # Improved Text Rendering Support for 'ggplot2'
library(shinythemes) # Themes for Shiny

# preamble needed for the FRONTEND:

# read in the data for the relationship tab
rel_data <- read_csv("data/relationship_data.csv")

# Create the variables needed for the front end:
select_line <- c("None", "One line for the city", "One line for each borough", "One line for the city and one for each borough")
select_game <- c("Lotto 649", "Lotto Max", "Lottario")
select_year <- c(2012, 2013,2014,2015)
bor_label <- c("Scarborough", "North York", "East York", "Central Toronto", "Downtown Toronto", "York","West Toronto", "Etobicoke") # add the choices for the drop down menu
# select_outcome <- c("Ticket sales", "Net sales")
# select_demo <- c("Income", "Education", "SES", "Population", "MBSA")

# THE UI IS HERE:
ui <- fluidPage(theme = shinytheme("flatly"),
                navbarPage("Toronto Jackpot",
                           # introduction tab
                           tabPanel("Intro",
                                    includeMarkdown("md/intro.md"),
                                    hr()),

                           # # visualize the number of tickets sold by borough on to an interactive map
                           tabPanel("Map",
                                    tags$head(
                                        includeCSS("css/styles.css")),
                                    leafletOutput("map", height = 750),
                                    # overlay panel
                                    absolutePanel(id = "description",
                                                  class = "panel panel-default",
                                                  fixed = T,
                                                  draggable = T,
                                                  top = 90,
                                                  left = "auto",
                                                  right = 15,
                                                  bottom = "auto",
                                                  width = "25%",
                                                  height = "auto",
                                                  #Contents of the panel
                                                  h2("Tickets purchased by neighbourhood"),
                                                  p("This map shows the number of tickets sold on a map of Toronto.",
                                                    span(strong("Bubble size are determined by the number of tickets purchased"))),
                                                  h4("Instructions:"),
                                                  tags$ul(
                                                      tags$li("Zoom in/out and navigate the map with your mouse"),
                                                      tags$li("Select the bubbles to see the name of the borough and number of tickets purchased")))),

                           # Visualize and explore the relationships between different variables and ticket sales. Filtered by game. Inspired by Joel Le Forestier from UofT (Toronto)
                           tabPanel("Relationship",
                                    fluidRow(column(12,
                                                    h1("Visualize and Explore Relationship"),
                                                    HTML("<p>Explore the relationship between different variables and ticket sales/net sales. Through a combination of
                                                      the different possible x-variables, y-variables, and filters you can create <b>1,071,000</b> unique graphs! Hover your mouse
                                                      over a data point on the plot to see what neighbourhood it represents.</p>"),

                                    )),
                                    hr(),
                                    # sidebar panel stuff
                                    sidebarLayout(sidebarPanel(width = 3,
                                                               # filter by game: one of lotto 649, lotto max, lottario or all
                                                               h4("Explore the different relationships"),
                                                               helpText("Choose the lottery game(s) you want to explore"),
                                                               selectInput(inputId = "game_rel",
                                                                           label = NULL,
                                                                           multiple = TRUE,
                                                                           selected = "Lotto 649",
                                                                           choices = as.list(select_game)),
                                                               # filter by year
                                                               helpText("Select the year(s)"),
                                                               selectInput(inputId = "year_rel",
                                                                           label = NULL,
                                                                           multiple = TRUE,
                                                                           selected = 2012,
                                                                           choices = as.list(select_year)),
                                                               # filter by borough
                                                               helpText("Select a borough(s)"),
                                                               selectInput(inputId = "bor_rel",
                                                                           label = NULL,
                                                                           multiple = TRUE,
                                                                           selected = c("Scarborough", "North York", "East York", "Central Toronto", "Downtown Toronto", "York","West Toronto", "Etobicoke"),
                                                                           choices = as.list(bor_label)),
                                                               # select the outcome variable
                                                               helpText("Now select the outcome variable"),
                                                               selectInput(inputId = "outcome_rel",
                                                                           label = NULL,
                                                                           choices = gsub("_", " ", names(rel_data)[5:6])),
                                                               # select the demographic variable
                                                               helpText("Select the demographic variable"),
                                                               selectInput(inputId = "demo_rel",
                                                                           label = NULL,
                                                                           choices = names(rel_data)[7:11]),
                                                               helpText("Finally, select the fit lines"),
                                                               selectInput(inputId = "lines",
                                                                           label = NULL,
                                                                           choices = as.list(select_line))),
                                                  #main panel stuff for the relationship tab
                                                  mainPanel(width = 8,
                                                            # This line produces the custom title
                                                            h3(textOutput("title"), align = "center"),
                                                            # this line produces the plot
                                                            shinycssloaders::withSpinner(
                                                                girafeOutput("plot", height = "100%", width = "85%")),
                                                            # This is for the results section
                                                            h3("Result Summary", align = "center"),
                                                            p(textOutput("cor"), "Note, the data presented is for exploratory data analysis. It is not for inferring causality.")),
                                    )),

                           # Visualize and explore the relationship between jackpot size and ticket sales
                           tabPanel("Size vs Sales",
                                    #Preamble text at the top
                                    fluidRow(column(12,
                                                    h1("Jackpot Size vs Ticket Sales"),
                                                    HTML("<p> Explore and visualize the relationship between the <span style='color:#000099;'> <b>jackpot size</b></span> and <span style='color:#FF9900;'> <b>tickets sales</b>. </span>
                                                         Click between the tabs to see the relationship over a year, month, and week. As well, filter by year and lottery game. </p>"))
                                    ),
                                    hr(),
                                    # the siddebar panel
                                    sidebarLayout(
                                        sidebarPanel(
                                            selectInput(inputId = "year_size",
                                                        label = "Select a year",
                                                        choices = as.list(select_year)),
                                            selectInput(inputId = "game_size",
                                                        label = "Select a game",
                                                        choices = as.list(select_game))
                                        ),
                                        # main panel
                                        mainPanel(
                                            tabsetPanel(
                                                tabPanel("Year",
                                                         h3(textOutput("title_year"),  align = "center"),
                                                         fluidRow(
                                                             column(6, shinycssloaders::withSpinner(plotOutput("ploty_size"))),
                                                             column(6, shinycssloaders::withSpinner(plotOutput("ploty_sales")))
                                                         )),
                                                tabPanel("Month",
                                                         h3(textOutput("title_month"),  align = "center"),
                                                         fluidRow(
                                                             column(6, shinycssloaders::withSpinner(plotOutput("plotm_size"))),
                                                             column(6, shinycssloaders::withSpinner(plotOutput("plotm_sales")))
                                                         )),
                                                tabPanel("Week",
                                                         h3(textOutput("title_week"),  align = "center"),
                                                         fluidRow(
                                                             column(6, shinycssloaders::withSpinner(plotOutput("plotw_size"))),
                                                             column(6, shinycssloaders::withSpinner(plotOutput("plotw_sales")))
                                                         ))
                                            )
                                        )
                                    )

                           ),
                           # Visualize and explore the relationships between different demographic info and lottery ticket sales (by games)
                           tabPanel("Data",
                                    fluidRow(column(12,
                                                    h1("The Raw Data"),
                                                    p("This tab shows the (almost) raw data as recieved from",
                                                      span(tags$a(href = 'https://osf.io/qwrxy/', 'Open Science Framework')),
                                                      "/",
                                                      span(tags$a(href = "https://andr3wli.github.io/lottodata/", "lottodata")),
                                                      "R package.",
                                                      "Explore the data via filtering, sorting, and searching."),
                                                    br(),
                                                    h4("Instructions"),
                                                    p("Use the check box buttons to sort through lottery games, years and boroughs. The dplyr::filter function is used under the hood. Download the data for more data wrangling options 😊.")
                                    )),
                                    hr(),
                                    sidebarLayout(sidebarPanel(width = 3,
                                                               h4("Explore the data"),
                                                               # filter by games
                                                               helpText("Choose the lottery game(s) you want to explore"),
                                                               checkboxGroupInput("game",
                                                                                  label = NULL,
                                                                                  choices = list("Lotto 649" = "Lotto 649", "Lotto Max" = "Lotto Max", "Lottario" = "Lottario"),
                                                                                  selected = "Lotto 649"),
                                                               # filter by year
                                                               helpText("Now filter through the year(s)"),
                                                               checkboxGroupInput("year",
                                                                                  label = NULL,
                                                                                  choices = list("2012" = "2012", "2013" = "2013", "2014" = "2014", "2015" = "2015"),
                                                                                  selected = "2012"),
                                                               # filter by borough via select inpput widget
                                                               helpText("Finally, select a borough(s)"),
                                                               selectInput(inputId = "select_bor",
                                                                           label = NULL,
                                                                           multiple = TRUE,
                                                                           selected = "Downtown Toronto",
                                                                           choices = as.list(bor_label)),
                                                               # option to download the entire/filtered data set
                                                               helpText("Download the filtered data!"),
                                                               downloadButton("downloadData", "Download")
                                    ),
                                    mainPanel(dataTableOutput("data", height = "100%")))

                           )
                ))


################################################################################################   SERVER  ################################################################################################
# THE SERVER IS HERE:
server <- function(input, output) {

#Preamble for the BACKEND:

    #Preamble for the RELATIONSHIP TAB:
    rel_data <- read_csv("data/relationship_data.csv") # read in the data for the server
    rel_colors <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666")

    # Preamble for MAP LEAFLET TAB:
    # suppressWarnings(source("./data_wrangling/map.R"))
    map <- read_csv("data/map-tab.csv") # load the data
    pop_up <- paste0("<strong> Borough: </strong>", # load the pop up message for the radius in map
                     map$Borough,
                     "<br><strong> Tickets sold: </strong>",
                     map$tickets)
    bor <- colorFactor( #add the colors for the radius in the map
        palette = c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666"),
        domain = map$Borough
    )

    # preamble for the jackpot SIZE and ticket SALES tab
    year_data <- read_csv("data/month_data.csv") # data for the year data
    month_data <- read_csv("data/per_month.csv") # data for the month data
    week_data <- read_csv("data/week_data.csv") # data for the weekly data

    #Preamble for the DATA TAB:
    jp <- read_csv("data/data_tab_data.csv") # load the data
    # names(bor_label) <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666") # so the colors and cat variable doesnt change

    # the leaflet map tab server
    output$map <- renderLeaflet({
        map %>%
            leaflet() %>%
            addProviderTiles("Stamen.TonerLite",
                             options = providerTileOptions(noWrap = TRUE)) %>%
            setView(lng = -79.347015, lat = 43.651070, zoom = 12) %>%
            addCircles(radius = ~1.1 * tickets, popup = pop_up, color = ~bor(Borough), stroke = T,
                       fillOpacity = 0.6)
    })

    # the relationship tab backend stuff: title, result summary, and the plot

    # generates the title for the plot in the main panel of the relationship tab
    output$title <- renderPrint({
        r_title <- cor.test(rel_data[[gsub(" ", "_", input$outcome_rel)]], rel_data[[ input$demo_rel]])$estimate

        cat("Relationship between city", input$demo_rel, "and", gsub("_", " ", input$outcome_rel), ": r = ", round(r_title, 2))
    })

    # generates the result summary
    output$cor <- renderPrint({
        df <- cor.test(rel_data[[gsub(" ", "_", input$outcome_rel)]], rel_data[[ input$demo_rel]])[["parameter"]][["df"]]
        r <- cor.test(rel_data[[gsub(" ", "_", input$outcome_rel)]], rel_data[[input$demo_rel]])$estimate
        p <- cor.test(rel_data[[gsub(" ", "_", input$outcome_rel)]], rel_data[[input$demo_rel]])$p.value

        if(p >= .05) {
            return(cat(paste0("There is no significant relationship between ", input$demo_rel), " and ", gsub("_", " ", input$outcome_rel), " (r(", df, ") = ", round(r,2), ", p = ", round(p, 3), ")."))
        }
        else if(p < .05 & p >= .001 & r < .3 & r > 0){
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), ". This is a small, positive, statistically significant effect.")))
        }
        else  if(p < .05 & p >= .001 & r <= .5 & r > .3){
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), "This is a medium, negative, statistically significant effect.")))
        }
        else if(p < .05 & p >= .001 & r > .5) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), ". This is a large, positive, statistically significant effect.")))
        }
        else if(p < .001 & r < .3 & r > 0){
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a small, positive, statistically significant effect.")))
        }
        else if (p < .001 & r <= .5 & r > .3){
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a medium, positive, statistically significant effect.")))
        }
        else if (p < .001 & r > .5){
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a large, positive, statistically significant effect.")))
        }
        else if (p < .05 & p >= .001 & r*-1 < .3 & r*-1 > 0) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), ". This is a small, negative, statisticallt significant effect.")))
        }
        else if (p < .05 & p >= .001 & r*-1 <= .5 & r > .3) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), ". This is a medium, negative, statisticallt significant effect.")))
        }
        else if(p < .05 & p >= .001 & r*-1 > .5) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p = ", round(p, 3), ". This is a large, negative, statisticallt significant effect.")))
        }
        else if(p < .001 & r*-1 < .3 & r*-1 > 0) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a small, negative, statistically significant effect.")))
        }
        else if(p < .001 & r*-1 <= .5 & r*-1 > .3) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a medium, negative, statistically significant effect.")))
        }
        else if (p < .001 & r*-1 > .5) {
            return(cat(paste0(input$demo_rel, " correlates with the number of ", gsub("_", " ", input$outcome_rel), " at r(", df, ") = ", round(r, 2), ", p < .001. This is a large, negative, statistically significant effect.")))
        }
    })

    # generates the plot in main panel for the relationship tab
    output$plot <- renderGirafe({
        if(input$lines == "None"){

            plot <- rel_data %>%
                filter(game %in% c(input$game_rel) & year %in% c(input$year_rel) & Borough %in% c(input$bor_rel)) %>%
                ggplot(aes_string(x = input$demo_rel, y = gsub(" ", "_", input$outcome_rel))) +
                geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
                scale_color_manual(values = rel_colors) +
                scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
                labs(x = input$demo_rel, y = gsub("_", " ", input$outcome_rel)) +
                theme_minimal()
            return(girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25)))

        } else if(input$lines == "One line for the city"){
            plot <- rel_data %>%
                filter(game %in% c(input$game_rel) & year %in% c(input$year_rel) & Borough %in% c(input$bor_rel)) %>%
                ggplot(aes_string(x = input$demo_rel, y = gsub(" ", "_", input$outcome_rel))) +
                geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
                geom_smooth(method = "lm", alpha = 0, color = "Black", size = 1.35) +
                scale_color_manual(values = rel_colors) +
                scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
                labs(x = input$demo_rel, y = gsub("_", " ", input$outcome_rel)) +
                theme_minimal()
            return(girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25)))

        } else if(input$lines == "One line for each borough"){
            plot <- rel_data %>%
                filter(game %in% c(input$game_rel) & year %in% c(input$year_rel) & Borough %in% c(input$bor_rel)) %>%
                ggplot(aes_string(x = input$demo_rel, y = gsub(" ", "_", input$outcome_rel))) +
                geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
                geom_smooth(method = "lm", alpha = 0, size = .5, aes(color = Borough)) +
                scale_color_manual(values = rel_colors) +
                scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
                labs(x = input$demo_rel, y = gsub("_", " ", input$outcome_rel)) +
                theme_minimal()
            return(girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25)))

        } else if(input$lines == "One line for the city and one for each borough") {
            plot <- rel_data %>%
                filter(game %in% c(input$game_rel) & year %in% c(input$year_rel) & Borough %in% c(input$bor_rel)) %>%
                ggplot(aes_string(x = input$demo_rel, y = gsub(" ", "_", input$outcome_rel))) +
                geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
                geom_smooth(method = "lm", alpha = 0, color = "Black", size = 1.35) +
                geom_smooth(method = "lm", alpha = 0, size = .5, aes(color = Borough)) +
                scale_color_manual(values = rel_colors) +
                scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
                labs(x = input$demo_rel, y = gsub("_", " ", input$outcome_rel)) +
                theme_minimal()
            return(girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25)))
        }
    })

    # This section powers the jackpot size vs ticket sales tab:

    # create the custom title for the year tab
    output$title_year <- renderPrint({
        cat(input$game_size, "jackpot size and ticket sales in", input$year_size)
    })
    # create the custom table for the month tab
    output$title_month <- renderPrint({
        cat(input$game_size, "jackpot size and ticket sales in", input$year_size)
    })
    # create the custom table for the month tab
    output$title_week <- renderPrint({
        cat(input$game_size, "jackpot size and ticket sales in", input$year_size)
    })

    # Plot for jackpot size for the year tab
    output$ploty_size <- renderPlot({
        year_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            mutate(month_str = factor(month_str)) %>%
            mutate(month_str = fct_relevel(month_str, c("January", "February", "March", "April", "May", "June",
                                                        "July", "August", "September", "October", "November", "December"))) %>%
            ggplot(aes(x = month_str, y = total_jp_size, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#000099'>Jackpot size</span></strong>") +
            scale_color_manual(values = "#000099") +
            scale_y_continuous(labels = scales::dollar_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # Plot for the ticket sales for the year panel
    output$ploty_sales <- renderPlot({
        year_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            mutate(month_str = factor(month_str)) %>%
            mutate(month_str = fct_relevel(month_str, c("January", "February", "March", "April", "May", "June",
                                                        "July", "August", "September", "October", "November", "December"))) %>%
            ggplot(aes(x = month_str, y = total_jp_sales, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#FF9900'>Ticket sales</span></strong>") +
            scale_color_manual(values = "#FF9900") +
            scale_y_continuous(labels = scales::comma_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # plot for jackpot size for the the month panel
    output$plotm_size <- renderPlot({
        month_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            ggplot(aes(x = factor(day), y = total_jp_size, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#000099'>Jackpot size</span></strong>") +
            scale_color_manual(values = "#000099") +
            scale_y_continuous(labels = scales::dollar_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 40, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # plot for the ticket sales for the month panel
    output$plotm_sales <- renderPlot({
        month_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            ggplot(aes(x = factor(day), y = total_jp_sales, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#FF9900'>Ticket sales</span></strong>") +
            scale_color_manual(values = "#FF9900") +
            scale_y_continuous(labels = scales::comma_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 40, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # plot for the jackpot size for the week plot
    output$plotw_size <- renderPlot({
        week_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            mutate(week = factor(week)) %>%
            mutate(week = fct_relevel(week, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
            ggplot(aes(x = week, y = total_jp_size, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#000099'>Jackpot size</span></strong>") +
            scale_color_manual(values = "#000099") +
            scale_y_continuous(labels = scales::dollar_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 50, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # plot for the ticket sales for the week plot
    output$plotw_sales <- renderPlot({
        week_data %>%
            filter(year == input$year_size & game == input$game_size) %>%
            mutate(week = factor(week)) %>%
            mutate(week = fct_relevel(week, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
            ggplot(aes(x = week, y = total_jp_sales, color = game)) +
            geom_point(size = 3) +
            geom_line(aes(group = game), size = 1) +
            labs(x = "", y = "", color = "", title ="<strong> <span style='color:#FF9900'>Ticket sales</span></strong>") +
            scale_color_manual(values = "#FF9900") +
            scale_y_continuous(labels = scales::comma_format(),
                               breaks = scales::pretty_breaks(n = 10)) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 50, hjust = 1, size =11),
                  axis.text.y = element_text(size = 11),
                  plot.title = element_markdown(),
                  legend.position = "none")
    })

    # the data exploration tab server
    output$data <- renderDataTable({
        filter(jp, game %in% c(input$game) & year %in% c(input$year) & Borough %in% c(input$select_bor))
    })


}

################################ ################################ ################################ ################################ ################################ ################################
# Run the application
shinyApp(ui = ui, server = server)

