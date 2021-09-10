# test to make sure that all the information in the relationship tab of shinyJackpot
# is correct and accurate

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(testthat) # Unit Testing for R

# read in the data that was used for this tab
relationship_data <- read_csv("shinyJackpot/data/relationship_data.csv")



relationship_test <- function(){
  test_that("The contents of the realtionship data set is correct", {
    # making sure that we are working with a data frame
    expect_true("data.frame" %in% class(relationship_data))
    # checking for the dimensions of the data set
    expect_equal(dim(relationship_data), c(1080, 12))
    # check to make sure of the col names are correct
    expect_true("MBSA" %in% colnames(relationship_data))
    expect_equal(length(unique(relationship_data$Borough)), 8)
  })
}
