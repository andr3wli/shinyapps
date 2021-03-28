###
# This creates the data to be used for the data tab of the shiny app
# Merges lottodata::lotto_demographics and lottodata::jackpot_size
# clean the data frame up a bit
###

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lottodata) # Provides easy access to lottery data sets for research purposes
library(lubridate) # Make Dealing with Dates a Little Easier
library(stringr) # Simple, Consistent Wrappers for Common String Operations


# load the data
jp_datatab <- jackpot_size
dem_datatab <- lotto_demographics

# merge the data sets
dem_datatab <- left_join(jp_datatab, dem_datatab, by = "zip_code")

# separate the borough and neighborhood in the description column
# replace the parenthesis with " and nothing
dem_datatab <- dem_datatab %>%
  mutate(description = str_replace_all(description, "[(]", " -")) %>%
  mutate(description = str_replace_all(description, "[)]", ""))

# create a new column for the borough and the neighborhood
dem_datatab <- dem_datatab %>%
  separate(description, c("Borough", "Neighbourhood"), " -")

# get rid of the outlier boroughs
# will be using the 8 major boroughs:  "Scarborough", "North York", "East York", "Central Toronto", "Downtown Toronto" "York","West Toronto", "Etobicoke"
dem_datatab <- dem_datatab %>%
  filter(Borough != "EtobicokeNorthwest" & Borough != "East YorkEast Toronto" & Borough != "East Toronto")

# create new columns for month and day of week as string and rename some of them
dem_datatab <- dem_datatab %>%
  mutate(Month = as.character(start_date, format = "%b"),
         Day = as.character(start_date, format = "%a")) %>%
  rename(FSA = zip_code,
         day_of_month = day)

# delete columns that are not needed
final_datatab <- dem_datatab %>%
  select(c(Borough, Neighbourhood, game, ticket_sales, jackpot_size, year, Month, Day, day_of_month))



# clear environment
rm(list = c("dem",
            "dem_datatab",
            "jp",
            "jp_datatab"))

#save the data to the data folder
write_csv(final_datatab, file = here::here("shinyJackpot", "data", "data_tab_data.csv"))
