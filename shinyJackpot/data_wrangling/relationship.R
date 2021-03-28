###
# data wrangling
# This code generates cleans and wrangles the data for the relationship tab
# Create relevant variables and merges the different data sets
# Finally, saves the tidy data sets in the data subdirectory of the repo
####

#load the differeent libraries needed for this
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lottodata) # Provides easy access to lottery data sets for research purposes
library(lubridate) # Make Dealing with Dates a Little Easier
library(stringr) # Simple, Consistent Wrappers for Common String Operations

# load the dirty data sets I will be working with
jp_rel <- jackpot_size
dem_rel <- lotto_demographics
pop_rel <- read_csv("shinyJackpot/untidy_data/TorontoDem_2011.csv", col_names = F)

# Work on the dem data set - use my old work to seperate the description column to be 2 new columns: borough and neighbourhood

# replace the parenthesis in description column for easy separation of the description column
dem_rel <- dem_rel %>%
  mutate(description = str_replace_all(description, "[(]", " -")) %>%
  mutate(description = str_replace_all(description, "[)]", ""))

# create a new column for the borough and the neighborhood
dem_rel <- dem_rel %>%
  separate(description, c("Borough", "Neighbourhood"), " -")

# get rid of the outlier boroughs
# will be using the 8 major boroughs:  "Scarborough", "North York", "East York", "Central Toronto", "Downtown Toronto" "York","West Toronto", "Etobicoke"
dem_rel<- dem_rel %>%
  filter(Borough != "EtobicokeNorthwest" & Borough != "East YorkEast Toronto" & Borough != "East Toronto")

# rename zip_code column
dem_rel <- dem_rel %>%
  rename(FSA = zip_code)

# give the population data set column names (x1 and x2 == FSA and population)
pop_rel <- pop_rel %>%
  rename(FSA = X1,
         population = X2)

# add the population column to this data set
dem_rel <- left_join(dem_rel, pop_rel, by = "FSA")

# now, combine the jackpot size data set to this one. I nonly want: game, ticket sales, net sales, jackpot size, and FSA, year
jp_rel <- jp_rel %>%
  select(c(zip_code, game, ticket_sales, net_sales, jackpot_size, year))
#rename the zip code column
jp_rel <- jp_rel %>%
  rename(FSA = zip_code)

# finally merge the 2 data sets together
rel_data <- left_join(dem_rel, jp_rel, by = "FSA")

# create the data frame needed for the plot
rel_data <- rel_data %>%
  group_by(Borough, Neighbourhood, game, year) %>%
  summarise(ticket_sale = mean(ticket_sales),
            net_sale = mean(net_sales),
            income = mean(income),
            ses = mean(ses),
            education = mean(education),
            mbsa = mean(mbsa),
            pop = mean(population),
            jackpot_size = mean(jackpot_size))

# rename the column names for the shiny app
rel_data <- rel_data %>%
  rename(Population = pop,
         Income = income,
         Education = education,
         MBSA = mbsa,
         SES = ses)
# Capitalize
rel_data <- rel_data %>%
  rename(Ticket_sales = ticket_sale,
         Net_sales = net_sale)


# clean environemnt
rm(jp_rel, dem_rel)

# save the data to the data foler
write_csv(rel_data, file = here::here("shinyJackpot", "data", "relationship_data.csv"))

##############################################################################################################################################
# this section will be used for making the plots before I add it to the server
# this section is my "draft"
rel_data <- read_csv("shinyJackpot/data/relationship_data.csv")

rel_data %>%
  filter(game == "Lotto 649" & year == 2012) %>%
  ggplot(aes(x = pop, y = ticket_sale, color = Borough)) +
  geom_point() +
  geom_smooth(method = "lm", alpha = 0, size = .5, aes(color = Borough)) +
  theme_minimal() +
  scale_color_manual(values = rel_colors)
  # geom_point_interactive(aes(tooltip = Neighbourhood.Name, shape = Borough, fill = Borough, color = Borough), size = 2.25)


plot <- rel_data %>%
  filter(game == "Lotto 649" & year == 2012) %>%
  ggplot(aes(x = Population, y = Ticket_sales)) +
  geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
  geom_smooth(method = "lm", alpha = 0, size = .5, aes(color = Borough)) +
  theme_minimal() +
  scale_color_manual(values = rel_colors)

  ploti <- girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25))



plot <- rel_data %>%
  filter(game == "Lotto 649" & year == 2012) %>%
  ggplot(aes(x = Income, y = Ticket_sales)) +
  geom_point_interactive(aes(tooltip = Neighbourhood, color = Borough), size = 2.25) +
  geom_smooth(method = "lm", alpha = 0, color = "Black", size = 1.5) +
  geom_smooth(method = "lm", alpha = 0, size = .5, aes(color = Borough)) +

  scale_color_manual(values = rel_colors) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +

  labs(x = "income", y = "tickets sales") +

  theme_minimal()

girafe(ggobj = plot, width_svg = 8, opts_tooltip(delay_mouseover = 25))




