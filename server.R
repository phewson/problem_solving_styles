library(shiny)
library(shinysurveys)
library(purrr)
library(stringr)

results <- reactiveVal(NULL)  # Define globally within server

server <- function(input, output, session) {
  renderSurvey()

  observeEvent(input$submit, {
    types <- c("a", "n", "x", "d")

    # Collect responses dynamically
    responses <- map(types, function(type) {
      ids <- paste0(type, 1:12)
      map_chr(ids, ~ input[[.x]])
    })
    names(responses) <- types

    # Count agreement responses
    scores <- map_int(responses, ~ sum(str_detect(.x, "Strongly agree|Agree")))

    # Store results
    results(data.frame(
      a_score = scores["a"],
      e_score = scores["n"],
      x_score = scores["x"],
      d_score = scores["d"]
    ))

    showModal(modalDialog(
      title = "An interpretation of your results",
      plotOutput("results_plot")
    ))
  })

  output$results_plot <- renderPlot({
    req(results())  # Ensure results is available
    plot_results(results())  # Call your plotting function
  })
}
server
