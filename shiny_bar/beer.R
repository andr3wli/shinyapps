library(ggforce) # Accelerating 'ggplot2'
library(tidyverse) # Easily Install and Load the 'Tidyverse'

geom_beer <- function(length = 10) {

  x = length / 2

  beer <- function(x, y, color = "#bdbdbd", lineend = "butt") {
    list(
      geom_segment(aes(x = -x + 1.5, xend = x - 1.5,
                       y = y, yend = y),
                   size = 60, lineend = lineend, color = color)
    )
  }

  beer_top <- beer(x, 2, lineend = "butt")
  beer_bottom <- beer(x, 0, color = "#969696", lineend = "butt")
  beer_body <- beer(x, 1, color = "#ef3b2c")



  logo <- list(
    geom_segment(aes(x = -x + 3.5, xend = x - 3.5, y = 1.5, yend = 1.5),
                 size = 25, lineend = "round", color = "white"),
    geom_text(aes(x = 0, y = 1.5), label="BEER", size = 13)
  )

  limits <- list(
    xlim(-10, 10),
    ylim(-6, 6)
  )

  return(c(beer_top, beer_bottom, beer_body, logo, limits))
}


ggplot() +
  geom_beer() +
  coord_fixed(clip = "off") +
  theme_void()

