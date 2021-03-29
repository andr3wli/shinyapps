###
# Shiny app by Andrew Li and Georgios Karamanis
# With the Winstanley Lab at the Unniversity of British Columbia
###
# load required packages
library(shiny) # Web Application Framework for R
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lubridate) # Make Dealing with Dates a Little Easier
library(shinythemes) # Themes for Shiny
library(shinydashboard) # Create Dashboards with 'Shiny'
library(shinyWidgets) # Custom Inputs Widgets for Shiny
library(shinyjs) # Easily Improve the User Experience of Your Shiny Apps in Seconds

# Define the UI for for shinyRGT
ui <- fluidPage(useShinyjs(),
                navbarPage(title = "Rat Gambling Task",
                           header = tagList(
                               useShinydashboard(),
                               setBackgroundColor(color = c("ghostwhite"))
                           ),
                           inverse = TRUE,
                           theme = shinythemes::shinytheme(theme = "flatly"),

                           #intro md tab
                           tabPanel("Intro",
                                    includeMarkdown("md/intro.md"),
                                    hr()),

                           # tab for the data wrangling the RGT data
                           tabPanel("Data Wrangling",
                                    #Preamble for the long form data for the rgt
                                    fluidRow(column(12,
                                                    h1("Rat Gambling Task Data Wrangling"),
                                                    p("Use this tab to create the tidy data. Upload the messy data set you get from MEDPC2XL and choose what kind of tidy data you want."))),
                                    hr(),
                                    # the sidebar panel for uploading data

                                    sidebarLayout(

                                        # Sidebar panel for inputs ----
                                        sidebarPanel(

                                            # Input: Select a file ----
                                            fileInput("file1", "Choose CSV File",
                                                      multiple = FALSE,
                                                      accept = c("text/csv",
                                                                 "text/comma-separated-values,text/plain",
                                                                 ".csv")),
                                            HTML("<h5><b>DREADDs variables:</b></h5>"),
                                            # Add boolean value if sex is a variable of interest - one of male or female
                                            checkboxInput("sex_bool", label = "Add sex column", value = FALSE),
                                            conditionalPanel(condition = "input.sex_bool",
                                                             helpText("Add subject numbers that are male:"),
                                                             textInput("sex_col", label = NULL, placeholder = "1,2,3,4...")
                                            ),
                                            # Add boolean value if virus is a variable of interest - one of hM3, hM4, or Control
                                            checkboxInput("virus_bool", label = "Add virus column", value = FALSE),
                                            conditionalPanel(condition = "input.virus_bool",
                                                             helpText("Add subject numbers that have hM3 virus:"),
                                                             textInput("hm3_col", label = NULL, value = "", placeholder = "1,2,3,4...")
                                            ),
                                            conditionalPanel(condition = "input.virus_bool",
                                                             helpText("Add subject numbers that have hM4 virus:"),
                                                             textInput("hm4_col", label = NULL, value = "", placeholder = "1,2,3,4...")
                                            ),
                                            # Add boolean value if transgene status is a variable of interest - one of TG+ or TG-
                                            checkboxInput("tg_bool", label = "Add transgene column", value = FALSE),
                                            conditionalPanel(condition = "input.tg_bool",
                                                             helpText("Add subject numbers that are TG+:"),
                                                             textInput("tg_col", label = NULL, value = "", placeholder = "1,2,3,4...")
                                            ),

                                            # Input: Select number of rows to display
                                            helpText("Choose the appropriate data"),
                                            radioButtons("disp",
                                                         label = NULL,
                                                         choices = c("Long data" = "long",
                                                                     "Sex data" = "sex",
                                                                     "Virus data" = "virus",
                                                                     "Transgene data" = "tg"),
                                                         selected = "long"),

                                            # option to download the data
                                            helpText("Download the new data set"),
                                            downloadButton("downloadData", "Download")

                                        ),
                                        # Main panel for displaying outputs ----
                                        mainPanel(
                                            shinycssloaders::withSpinner(
                                                dataTableOutput("contents"))
                                        )

                                    )),
                           # tab for data visualization for RGT data
                           tabPanel("Data Visualization",
                                    #Preamble for the long form data for the rgt
                                    # fluidRow(column(9,
                                    #                 h1("Rat Gambling Task Data Visualization"),
                                    #                 p("Use this tab to use the tidy data generated and to create visualizations"))),
                                    # hr()),
                                    fluidRow(
                                        column(3,
                                               fileInput("file2", "Choose CSV File",
                                                         accept = c(
                                                             "text/csv",
                                                             "text/comma-separated-values",
                                                             "text/tab-separated-values",
                                                             "text/plain",
                                                             ".csv",
                                                             ".tsv"))
                                        ),
                                        column(2,
                                               # varSelectInput("x_axis", label = "x axis", mtcars, selected = names(mtcars)[1]),
                                               uiOutput("x_axis"),
                                               textInput("label_x", label = "X-axis label")),
                                        column(2,
                                               # varSelectInput("y_axis", label = "y axis", mtcars, selected = colnames(mtcars)[2]),
                                               uiOutput("y_axis"),
                                               textInput("label_y", label = "Y-axis label")),
                                        column(2,
                                               uiOutput("color"),
                                               textInput("label_legend", label = "Legend label")),

                                        column(2,
                                               sliderInput("size", label = "Size", min = 0, max = 5, step = 0.5, value = 1, ticks = FALSE),
                                               selectInput("theme", label = "Theme", choices = c("grey", "classic", "minimal", "bw", "light", "dark"), selected = "classic")),

                                    ),

                                    shinycssloaders::withSpinner(plotOutput("plot")),

                                    fluidRow(
                                        column(3,
                                               textInput("plot_title", label = "Title", value = deparse(substitute(Title))),
                                               textInput("plot_subtitle", label = "Subtitle")
                                        ),

                                        column(2,
                                               checkboxInput("add_line", label = "Add line", value = FALSE)
                                        ),

                                        column(2,
                                               checkboxInput("facet_switch", label = "Facets", value = FALSE),
                                               conditionalPanel(condition = "input.facet_switch",
                                                                # varSelectInput("facet", label = "facet",  mtcars)
                                                                uiOutput("facet")
                                               )
                                        ),

                                        column(2,
                                               checkboxInput("smoothing_switch", label = "Smoothing", value = FALSE),
                                               conditionalPanel(condition = "input.smoothing_switch",
                                                                selectInput("Smoothing", label = "Smoothing", choices = c("lm", "glm", "gam", "loess"))
                                               )
                                        ),


                                        column(2,
                                               downloadButton("export_plot", label = "Export plot"),
                                               br(),
                                               br(),
                                               downloadButton("export_code", label = "get code")
                                        )
                                    )

                           )

                           # tab for data analysis - FORTHCOMING
                           # tabPanel("Data Analysis",
                           #          fluidRow(column(12,
                           #                          h1("Place holder text"),
                           #                          p("Place holder text"))),
                           #          hr())
                ))


###################### Define server logic to read selected file ######################
server <- function(input, output) {
    # for expanding the max file size from 5mb to 30mb
    options(shiny.maxRequestSize=30*1024^2)
    output$contents <- renderDataTable({
        dataInput()
    })
    dataInput <- function() {


        req(input$file1)

        # when reading semicolon separated files,
        # having a comma separator causes `read.csv` to error
        tryCatch(
            {
                step1 <- read.csv(input$file1$datapath,
                                  header = TRUE,
                                  sep = ",")
            },
            error = function(e) {
                stop(safeError(e))
            }
        )
        # load the data set and remove the irrelevent columns
        step2 <- step1 %>%
            select(- c(Experiment, Comment, StartTime, Rew_Persev_H1, Rew_Persev_H2,
                       Rew_Persev_H3, Rew_Persev_H4, Rew_Persev_H5, Pun_Persev_H1,
                       Pun_Persev_H2, Pun_Persev_H3, Pun_Persev_H4, Pun_Persev_H5,
                       Group, Session, Pun_HeadEntry, Box))
        # standardize the dates
        step2 <- step2 %>%
            mutate(date = str_replace_all(StartDate, "2002", "02")) %>%
            select(- StartDate)

        df <- step2 %>%
            mutate(date = str_replace_all(date, "-", "/"))

        #create session number
        df$session <- match(df$date, unique(df$date))

        #create new columns for max trails, sum of omit, avg of choice lat, avg of collect lat, premature choice, and more i think
        df <- df %>%
            group_by(session, Subject) %>%
            mutate(trial = max(Trial)) %>%
            group_by(session, Subject) %>%
            mutate(omission = sum(Omit)) %>%
            group_by(session, Subject) %>%
            mutate(choice_lat = mean(Choice_Lat, na.rm = TRUE)) %>%
            # group_by(session, Subject) %>%
            # mutate(test_pre = sum(Premature_Resp)) %>%
            # mutate(premature_resp = test_pre / trial) %>%
            # select(- test_pre) %>%
            group_by(session, Subject) %>%
            mutate(pellets = sum(Pellets)) %>%
            group_by(session, Subject) %>%
            mutate(time_out = Pun_Dur) %>%
            group_by(session, Subject) %>%
            mutate(collect_lat = mean(Collect_Lat, na.rm = T))

        # use the new columns to create the premature column -> call this column premature_resp
        df <- df %>%
            group_by(session, Subject) %>%
            mutate(premature_resp = length(which(Premature_Resp == 1)) / (length(which(Premature_Resp == 1)) + omission + trial))

        # this section creates the choice percentage of p1, p2, p3, p4
        # split the data  by the task version
        group_a <- filter(df, MSN == "rGT_A-cue")
        group_b <- filter(df, MSN == "rGT_B-cue")

        # create the new choice variables for A version
        cued_a <- group_a %>%
            group_by(Subject, session) %>%
            mutate(p1_choice = length(which(Chosen == 1)) / length(which(Chosen != 0))) %>%
            mutate(p2_choice = length(which(Chosen == 4)) / length(which(Chosen != 0))) %>%
            mutate(p3_choice = length(which(Chosen == 5)) / length(which(Chosen != 0))) %>%
            mutate(p4_choice = length(which(Chosen == 2)) / length(which(Chosen != 0)))
        # remove any n/a
        cued_a <- replace(cued_a, is.na(cued_a), 0)

        # create the new choice variables for B version of task
        cued_b <- group_b %>%
            group_by(Subject, session) %>%
            mutate(p1_choice = length(which(Chosen == 2)) / length(which(Chosen != 0))) %>%
            mutate(p2_choice = length(which(Chosen == 5)) / length(which(Chosen != 0))) %>%
            mutate(p3_choice = length(which(Chosen == 4)) / length(which(Chosen != 0))) %>%
            mutate(p4_choice = length(which(Chosen == 1)) / length(which(Chosen != 0)))
        # remove n/a
        cued_b <- replace(cued_b, is.na(cued_b), 0)

        # merge the data set back together
        df2 <- rbind(cued_a, cued_b)
        # arrange by ascending order by subjects
        df2 <- df2 %>%
            arrange(Subject)

        # create the data frame needed for the long form data
        long_df <- df2 %>%
            group_by(Subject, session) %>%
            summarise(p1 = mean(p1_choice, na.rm = F),
                      p2 = mean(p2_choice, na.rm = F),
                      p3 = mean(p3_choice, na.rm = F),
                      p4 = mean(p4_choice, na.rm = F),
                      trials = mean(trial, na.rm = F),
                      omission = mean(omission, na.rm = F),
                      choice_lat = mean(choice_lat, na.rm = F),
                      premature = mean(premature_resp, na.rm = F),
                      collect_lat = mean(collect_lat, na.rm = F),
                      score = ((p1 + p2) - (p3 +p4)) * 100)



        # add new column for sex status, TG status, and virus status - Keep this to use for future analysis
        # long_df <- long_df %>%
        #     mutate(sex_status = ifelse(Subject %in% c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
        #                                               22,23,24,25,26,27,30,31,32,57,58), "Male", "Female")) %>%
        #     mutate(virus = ifelse(Subject %in% c(1,2,3,4,6,7,8,33,34,35,36,37,38,39,57,61), "hM3",
        #                           ifelse(Subject %in% c(9,10,11,12,13,14,15,16,41,42,43,44,45,46,47,48), "hM4", "Control"))) %>%
        #     mutate(tg_status = ifelse(Subject %in% c(25,26,27,28,29,30,31,32,40,53,58,59,60,62,64), "TG-", "TG+"))

        # add column for sex if checkboxinput was selected
        if(input$sex_bool){
            long_df <- long_df %>%
                mutate(sex_status = ifelse(Subject %in% c(unlist(strsplit(input$sex_col, ","))), "Male", "Female"))
        }
        # add column for TG status if checkboxinput was selected
        if(input$tg_bool){
            long_df <- long_df %>%
                mutate(tg_status = ifelse(Subject %in% c(unlist(strsplit(input$tg_col, ","))), "TG+", "TG-"))
        }
        # add column for viris if checkboxinput was selected
        if(input$virus_bool){
            long_df <- long_df %>%
                mutate(virus_status = ifelse(Subject %in% c(unlist(strsplit(input$hm3_col, ","))), "hM3",
                                             ifelse(Subject %in% c(unlist(strsplit(input$hm4_col, ","))), "hM4", "Control")))
        }


        # create the data frame for the sex data (grouped by session and sex)
        if(input$sex_bool){
            sex_df <- long_df %>%
                group_by(session, sex_status) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        } else {
            sex_df <- long_df %>%
                group_by(session) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        }
        # create the data frame for the virus data for the by session plots (groups by session, sex and virus)
        if(input$sex_bool & input$virus_bool){
            session_df <- long_df %>%
                group_by(session, virus_status, sex_status) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        } else {
            session_df <- long_df %>%
                group_by(session) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        }

        #create a data frame that seperates the data by TG status -> simialar to Hynes, Tristan, et al. "Dopamine neurons gate the intersection of cocaine use, decision making, and impulsivity." bioRxiv (2020).
        #grouped by session, sex, and TG status
        if(input$sex_bool & input$tg_bool){
            tg_df <- long_df %>%
                group_by(session, tg_status, sex_status) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        } else {
            tg_df <- long_df %>%
                group_by(session) %>%
                summarise(total_score = mean(score, na.rm = F),
                          total_p1 = mean(p1, na.rm = F),
                          total_p2 = mean(p2, na.rm = F),
                          total_p3 = mean(p3, na.rm = F),
                          total_p4 = mean(p4, na.rm = F),
                          total_trials = mean(trials, na.rm = F),
                          total_omission = mean(omission, na.rm = F),
                          total_choice_lat = mean(choice_lat, na.rm = F),
                          total_collect_lat = mean(collect_lat, na.rm = F),
                          total_premature = mean(premature, na.rm = F))
        }

        # return the tidy data set
        if(input$disp == "long") {
            return(long_df)
        } else if(input$disp == "sex"){
            return(sex_df)
        } else if(input$disp == "virus") {
            return(session_df)
        } else if(input$disp == "tg") {
            return(tg_df)
        }

        # })
    }

    ###################### Server for the DATA VISUALIZATION tab ######################
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$disp, '_data', '.csv', sep='')
        },
        content = function(file) {
            write.csv(dataInput(), file)
        }
    )

    #DATA VISUALIZATION TAB STARTS HERE
    data_upload <- reactive({
        if (is.null(input$file2)) {
            df <- mtcars
        } else {
            df <- read.csv(input$file2$datapath)
        }
    })
    # data_upload <-reactive({
    #     df <- mtcars
    # })

    output$x_axis <- renderUI({
        selectInput("x_axis", "X-axis", choices = colnames(data_upload()), selected = colnames(data_upload())[1])
    })

    output$y_axis <- renderUI({
        selectInput("y_axis", "Y-axis", choices = colnames(data_upload()), selected = colnames(data_upload())[4])
    })

    output$color <- renderUI({
        selectInput("color", "Color", choices = colnames(data_upload()), selected = NULL)
    })

    output$facet <- renderUI({
        selectInput("facet", "facet", choices = colnames(data_upload()), selected = colnames(data_upload())[4])
    })

    output$plot <- renderPlot({
        plotInput()
    })

    plotInput <- function(){
        conditions_list <- list(

            if(input$facet_switch){
                facet_wrap(vars(eval(as.name(input$facet))))
            },

            if(input$smoothing_switch){
                geom_smooth(method = input$Smoothing, color = "grey10")
            },

            if(input$add_line){
                geom_line(aes(group = eval(as.name(input$color))))
            }

        )

        data = data_upload()

        ggplot(data = data, aes(x = eval(as.name(input$x_axis)), y = eval(as.name(input$y_axis)), color = eval(as.name(input$color)))) +
            conditions_list +
            geom_point(size = input$size) +
            labs(
                title = input$plot_title,
                subtitle = input$plot_subtitle,
                x = input$label_x,
                y = input$label_y,
                color = input$label_legend
            ) +
            # scale_color_identity() +
            eval(parse(text = paste0("theme_", input$theme)))()
    }

    output$export_plot <- downloadHandler(
        filename = function() { "plot.png" },
        content = function(file) {
            ggsave(file, plot = plotInput(), device = "png")
        }
    )

    output$export_code <- downloadHandler(
        filename = function() { "code.R" },
        content = function(file) {
            writeLines(as.character(plotInput()), file)
        }
    )

    ###################### Server for the DATA ANALYSIS tab - REpeated measures ANOVA and mixed effect model ######################
}

###################### Create Shiny app ######################
shinyApp(ui, server)
