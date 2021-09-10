# test to make sure that all the information in the map tab of shinyJackpot
# is correct and accurate

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(testthat) # Unit Testing for R

# read in the data set that was used in the map tab of the shiny app
map_data <- read_csv("shinyJackpot/data/map-tab.csv")

map_test <- function(){
  test_that("The contents of the data set is correct", {
    # check that the data set has data frame class
    expect_true("data.frame" %in% class(map_data))
    # check for the dimension
    expect_equal(dim(map_data), c(90, 5))
    # check that the data set indeed only has 5 columns
    expect_equal(colnames(map_data), c("longitude", "latitude", "Borough",
                                       "Neighbourhood", "tickets"))
    # checking the individual columns now
    expect_equal(unique(map_data$Borough), c("Etobicoke", "North York", "York",
                                             "West Toronto", "Downtown Toronto",
                                             "Central Toronto", "East York",
                                             "Scarborough"))
    expect_equal(class(map_data$Neighbourhood), "character")
  })
}
