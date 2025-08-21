library(shiny)
library(dplyr)
library(ggplot2)
library(purrr)
library(shinysurveys)
library(tibble)
library(stringr)

source("global.R")
if (file.exists("ui.R") && file.exists("server.R")) {
  shinyApp(
    ui = source("ui.R")$value,
    server = source("server.R")$value
  )
} else {
  stop("Missing ui.R or server.R")
}
