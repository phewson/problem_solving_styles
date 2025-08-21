library(shiny)
library(shinysurveys)
source("global.R")
ui <- fluidPage(surveyOutput(
    df = df,
    survey_title = "Preferred problem solving styles",
    survey_description = "There are 48 questions"))

actionButton("submit", "Submit")

ui
