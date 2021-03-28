###
# This creates the data to be used for the size vs sales tab of the shiny app
# Aggregates the lottodata::jackpot_size by year and game
###

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lottodata) # Provides easy access to lottery data sets for research purposes
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(lubridate) # Make Dealing with Dates a Little Easier

# load the data from lottodata r package
size_jp <- jackpot_size
dem_jp <- lotto_demographics

# replace the parenthesis in description column for easy separation of the description column
dem_jp <- dem_jp %>%
  mutate(description = str_replace_all(description, "[(]", " -")) %>%
  mutate(description = str_replace_all(description, "[)]", ""))

# create a new column for the borough and the neighborhood
dem_jp <- dem_jp %>%
  separate(description, c("Borough", "Neighbourhood"), " -")

# get rid of the outlier boroughs
# will be using the 8 major boroughs:  "Scarborough", "North York", "East York", "Central Toronto", "Downtown Toronto" "York","West Toronto", "Etobicoke"
dem_jp <- dem_jp %>%
  filter(Borough != "EtobicokeNorthwest" & Borough != "East YorkEast Toronto" & Borough != "East Toronto")

# merge the demographics data and the jackpot size data
combined_size <- left_join(dem_jp, size_jp, by = "zip_code")

# add month and the day of the week as a string
combined_size$month_str <- as.character(combined_size$start_date, format = "%B")
combined_size$week <- as.character(combined_size$start_date, format = "%A")

# reorder the month_str and game columns and turn em into a factor first
combined_size <- combined_size %>%
  mutate(month_str = factor(month_str)) %>%
  mutate(month_str = fct_relevel(month_str, c("January", "February", "March", "April", "May", "June",
                                              "July", "August", "September", "October", "November", "December"))) %>%
  mutate(game =factor(game)) %>%
  mutate(game = fct_relevel(game, c("Lotto Max", "Lotto 649", "Lottario"))) %>%
  mutate(week = factor(week)) %>%
  mutate(week = fct_relevel(week, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

# summmarize the final data set (for the monthly plots)
final_size <- combined_size %>%
  group_by(game, year, month_str, Borough, Neighbourhood) %>%
  summarise(mean_sales = mean(ticket_sales),
            mean_jpsize = mean(jackpot_size))

# create a new data set from the final data for 1 more level of summary
# need this data for the sick plot from that paper
month_data <- final_size %>%
  group_by(game, year, month_str) %>%
  summarise(total_jp_size = mean(mean_jpsize),
            total_jp_sales = mean(mean_sales))

# same thing as before but making the data for the week
week_data <- combined_size %>%
  group_by(game, year, week, Borough, Neighbourhood) %>%
  summarise(mean_sales = mean(ticket_sales),
            mean_jpsize = mean(jackpot_size))

week_data <- week_data %>%
  group_by(game, year, week) %>%
  summarise(total_jp_size = mean(mean_jpsize),
            total_jp_sales = mean(mean_sales))

# same thing but for monthly effect (28, 30, or 31 days)
by_month <- combined_size %>%
  group_by(game, year, day, Borough, Neighbourhood) %>%
  summarise(mean_sales = mean(ticket_sales),
            mean_jpsize = mean(jackpot_size))
by_month <- by_month %>%
  group_by(game, year, day) %>%
  summarise(total_jp_size = mean(mean_jpsize),
            total_jp_sales = mean(mean_sales))

#save the data
write_csv(final_size, file = here::here("data", "size_vs_sales_data.csv"))
write_csv(month_data, file = here::here("data", "month_data.csv")) # for the by month plots
write_csv(week_data, file = here::here("data", "week_data.csv")) # for the weekly plots
write_csv(by_month, file = here::here("data", "per_month.csv")) # for the days of the month plots

# clear the enviornment
rm(combined_size, data_for_paper, dem_jp, month_data, week_data)

# Data viz for app.R
theme_set(theme_classic())

### "Draft for the shiny app, testing out how the plot looks like and what not
month_data <- read_csv("shinyJackpot/data/month_data.csv")
week_data <- read_csv("shinyJackpot/data/week_data.csv")

game_col <- c("Lotto Max", "Lotto 649", "Lottario")
names(game_col) <- c("#33a02c", "#1f78b4", "#e31a1c")

# by year comparison for jackpot size
year_data %>%
  filter(year == 2013 & game == "Lotto 649") %>%
  mutate(month_str = factor(month_str)) %>%
  mutate(month_str = fct_relevel(month_str, c("January", "February", "March", "April", "May", "June",
                                              "July", "August", "September", "October", "November", "December"))) %>%
  ggplot(aes(x = month_str, y = total_jp_size, color = game)) +
  geom_point(size = 1.7) +
  geom_line(aes(group = game)) +
  labs(x = "", y = "", color = "", title ="Jackpot size") +
  scale_color_manual(values = "#000099") +
  scale_y_continuous(labels = scales::dollar_format(),
                     breaks = scales::pretty_breaks(n = 10)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
        axis.text.y = element_text(size = 11),
        plot.title = element_text(size = 13, face = "bold"),
        legend.position = "none")

# within month comparison for jackpot size
by_month %>%
  filter(year == 2013 & game == "Lotto 649") %>%
  ggplot(aes(x = factor(day), y = total_jp_size, color = game)) +
  geom_point() +
  geom_line(aes(group = game)) +
  labs(x = "", y = "", color = "", title ="Jackpot size") +
  scale_color_manual(values = names(game_col)) +
  scale_y_continuous(labels = scales::dollar_format(),
                     breaks = scales::pretty_breaks(n = 10)) +
  theme(axis.text.x = element_text(angle = 40, hjust = 1, size =11),
        axis.text.y = element_text(size = 11),
        plot.title = element_text(size = 13, face = "bold"),
        legend.position = "bottom")

# day of the week comparision for jackpot size
week_data %>%
  filter(year == 2013 & game == "Lottario") %>%
  mutate(week = factor(week)) %>%
  mutate(week = fct_relevel(week, c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  ggplot(aes(x = week, y = total_jp_size, color = game)) +
  geom_point() +
  geom_line(aes(group = game)) +
  labs(x = "", y = "", color = "", title ="Jackpot size") +
  scale_color_manual(values = names(game_col)) +
  scale_y_continuous(labels = scales::dollar_format(),
                     breaks = scales::pretty_breaks(n = 10)) +
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
        axis.text.y = element_text(size = 11),
        plot.title = element_text(size = 13, face = "bold"),
        legend.position = "bottom")

############################################################################## Ticket sales here
# by month comparison for jackpot size
month_data %>%
  filter(year == 2013 & game == "Lotto 649") %>%
  mutate(month_str = factor(month_str)) %>%
  mutate(month_str = fct_relevel(month_str, c("January", "February", "March", "April", "May", "June",
                                              "July", "August", "September", "October", "November", "December"))) %>%
  ggplot(aes(x = month_str, y = total_jp_sales, color = game)) +
  geom_point() +
  geom_line(aes(group = game)) +
  labs(x = "", y = "", color = "", title ="Jackpot size") +
  scale_color_manual(values = names(game_col)) +
  scale_y_continuous(labels = scales::comma_format(),
                     breaks = scales::pretty_breaks(n = 10)) +
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
        axis.text.y = element_text(size = 11),
        plot.title = element_text(size = 13, face = "bold"),
        legend.position = "bottom")



# b <- data_for_paper %>%
#   filter(year == 2013) %>%
#   ggplot(aes(x = month_str, y = total_jp_sales, color = game)) +
#   geom_point() +
#   geom_line(aes(group = game)) +
#   labs(x = "", y = "", color = "", title = "Number of tickets sold") +
#   scale_color_manual(values = names(game_col)) +
#   scale_y_continuous(labels = scales::comma_format(),
#                      breaks = scales::pretty_breaks(n = 10)) +
#   theme(axis.text.x = element_text(angle = 70, hjust = 1, size = 11),
#         axis.text.y = element_text(size = 11),
#         plot.title = element_text(size = 13, face = "bold"),
#         legend.position = "bottom")
#
#
# c <- a + b
# c + plot_annotation(title = "2012",
#                     theme = theme(plot.title = element_text(size = 18, face = "bold")))
#
#
# # lott_size <-
#   data_for_paper %>%
#   filter(year == 2013, game == "Lottario") %>%
#   ggplot(aes(x = month_str, y = total_jp_size)) +
#   geom_point(color = "#33a02c") +
#   geom_line(aes(group = game), color = "#33a02c") +
#   labs(x = "", y = "", title ="Jackpot size") +
#   scale_color_manual(values = names(game_col)) +
#   scale_y_continuous(labels = scales::dollar_format(),
#                      breaks = scales::pretty_breaks(n = 10)) +
#   theme(axis.text.x = element_text(angle = 70, hjust = 1, size =11),
#         axis.text.y = element_text(size = 11),
#         plot.title = element_text(size = 13, face = "bold"),
#         legend.position = "bottom")
#
# # lott_sales <-
#   data_for_paper %>%
#   filter(year == 2013 & game == "Lottario") %>%
#   ggplot(aes(x = month_str, y = total_jp_sales)) +
#   geom_point() +
#   geom_line(aes(group = game)) +
#   labs(x = "", y = "", title = "Number of tickets sold") +
#   scale_color_manual(values = names(game_col)) +
#   scale_y_continuous(labels = scales::comma_format(),
#                      breaks = scales::pretty_breaks(n = 10)) +
#   theme(axis.text.x = element_text(angle = 70, hjust = 1, size = 11),
#         axis.text.y = element_text(size = 11),
#         plot.title = element_text(size = 13, face = "bold"),
#         legend.position = "bottom")
#
# lott_size + lott_sales



