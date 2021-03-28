### Set up the data for the map widget
# I got the data set from my analysis from the progressiveJackpot repo
# The data set needed will be already saved to the data file

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lottodata) # Provides easy access to lottery data sets for research purposes
library(ggtext) # Improved Text Rendering Support for 'ggplot2'


#create the data needed for map widget
map_map <- read_csv("shinyJackpot/data/data_for_map.csv")
jp_map <- jackpot_size %>%
  rename(FSA = zip_code)

map_long <- left_join(map_map, jp_map, by = "FSA")

map <- map_long %>%
  group_by(longitude, latitude, Borough, Neighbourhood) %>%
  summarise(tickets = round(mean(ticket_sales)))

# save the data set
write_csv(map, file = here::here("shinyJackpot/data/map-tab.csv"))

# create the pop up message
pop_up <- paste0("<strong> Borough: </strong>",
                 map$Borough,
                 "<br><strong> Neighbourhood: </strong>",
                 map$Neighbourhood,
                 "<strong> Tickets sold: </strong>",
                 map$ticket_sales)

# clean environment
rm(map_map, jp_map, map_long, pop_up)

