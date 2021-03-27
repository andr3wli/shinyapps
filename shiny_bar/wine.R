library(ggforce) # Accelerating 'ggplot2'
library(tidyverse) # Easily Install and Load the 'Tidyverse'

geom_wine <- function(length = 10) {

  x = length / 2

  wine <- function(x, y, color = "#00441b", lineend = "butt") {
    list(
      geom_segment(aes(x = -x + 1.5, xend = x - 1.5,
                       y = y, yend = y),
                   size = 60, lineend = lineend, color = color)
    )
  }


  wine_top <- wine(x, 2, color = "#67001f", lineend = "butt")
  wine_bottom <- wine(x, 1, color = "#67001f", lineend = "butt")
  wine_body <- wine(x, -1, color = "#67001f")
  wine_neck <- wine(0.6 * x, 3.5, color = "#67001f")
  wine_cork <- wine(0.6 * x, 5, color = "#980043")

  # wine_circle <- geom_circle(aes(x0 = x, y0 = 4.5, r = 2.25), n=80, linetype="solid",
  #                            size=1, inherit.aes = FALSE, fill = "#00441b")


  logo <- list(
    geom_segment(aes(x = -x + 1.5, xend = x - 1.5, y = 1.5, yend = 1.5),
                 size = 25, lineend = "butt", color = "#980043"),
    annotate("text", x = 0, y = 1.5, label = "WINE", size = 10, color = "#ffffd9")
    # geom_text(aes(x = 0, y = 1.5), label="WINE", size = 12, colour = "green"),

  )

  limits <- list(
    xlim(-10, 10),
    ylim(-6, 6)
  )

  return(c( wine_cork, wine_neck, wine_top, wine_bottom, wine_body, logo, limits))
  # return(wine_circle)
}

ggplot() +
  geom_wine() +
  coord_fixed(clip = "off") +
  theme_void()


# ggplot() +
# geom_circle(aes(x0 = 0, y0 = 0.5, r = 2.25), n=80, linetype="solid", size=1, inherit.aes = FALSE, fill = "#00441b")
