library(shiny)
library(shinysurveys)
# library(plotrix)
library(ggplot2)
library(dplyr)
library(tibble)
library(purrr)

LIKERT5 <- c("Strongly agree", "Agree", "Neither agree nor disagree",
             "Disagree", "Strongly disagree")

create_get_point <- function(center_x, center_y) {
  get_point <- function(score, angle) {
    x <- center_x + score * cos(angle * pi / 180)
    y <- center_y + score * sin(angle * pi / 180)
    return(data.frame(x, y))
  }
  return(get_point)
}


plot_results <- function(results) {
  center_x <- 6
  center_y <- 6
  radius <- c(2, 4)
  
  # Create circles
  theta <- seq(0, 2 * pi, length.out = 100)
  circle_outer <- tibble(
    x = center_x + radius[2] * cos(theta),
    y = center_y + radius[2] * sin(theta),
    group = "outer"
  )
  
  circle_inner <- tibble(
    x = center_x + radius[1] * cos(theta),
    y = center_y + radius[1] * sin(theta),
    group = "inner"
  )
  
  # Directional arrows
  offset_angles <- c(45, 135, 225, 315)
  cardinal_angles <- c(0, 90, 180, 270)
  text_angles <- seq(22.5, 360 - 22.5, by = 45)
  descriptive_text <- c("Organise", "Implement", "Market", "Create", "Play", "Discover",
                        "Appraise", "Conclude")
  
  arrow_df <- tibble(
    angle = offset_angles,
    xend = center_x + radius[2] * cos(angle * pi / 180),
    yend = center_y + radius[2] * sin(angle * pi / 180)
  )
  
  cardinal_df <- tibble(
    angle = cardinal_angles,
    xend = center_x + radius[2] * 1.1 * cos(angle * pi / 180),
    yend = center_y + radius[2] * 1.1 * sin(angle * pi / 180)
  )
  
  text_df <- tibble(
    label = descriptive_text,
    x = center_x + radius[2] * 0.8 * cos(text_angles * pi / 180),
    y = center_y + radius[2] * 0.8 * sin(text_angles * pi / 180)
  )

  # Score points
  max_score <- 12
  scaled_scores <- results[1, 1:4] / max_score * radius[2]

  get_point <- create_get_point(center_x, center_y)

  scores_df <- map2_dfr(scaled_scores, offset_angles, ~ get_point(.x, .y))
  
  # Plot
  ggplot() +
    geom_path(data = circle_outer, aes(x, y), color = "#2da13a") +
    geom_path(data = circle_inner, aes(x, y), color = "#2da13a", linetype = "dashed") +
    geom_segment(data = arrow_df, aes(x = center_x, y = center_y, xend = xend, yend = yend),
                 color = "grey", linewidth = 1) +
    geom_segment(data = cardinal_df, aes(x = center_x, y = center_y, xend = xend, yend = yend),
                 color = "grey", linetype = "dashed", linewidth = 1) +
    geom_text(data = text_df, aes(x, y, label = label)) +
    geom_text(aes(x = c(6, 11, 6, 1), y = c(11, 6, 1, 6),
                  label = c("Rational", "Stage 2", "Intuition", "Stage 1"))) +
    geom_polygon(data = scores_df, aes(x = x, y = y),
             fill = "#232173", alpha = 0.3) +
    geom_point(data = scores_df, aes(x, y), color = "#232173", size = 4) +
    geom_segment(data = scores_df %>%
                   mutate(xend = lead(x, default = first(x)),
                          yend = lead(y, default = first(y))),
                 aes(x = x, y = y, xend = xend, yend = yend),
                 color = "#232173", size = 1.5) +
    coord_fixed() +
    theme_void() +
    ggtitle("Preferred problem-solving style")
}


analyst <- c(
  "I consistently conduct thorough investigations and gather evidence before making decisions.",
  "I prefer a methodical and deliberate approach to tasks, valuing precision over speed.",
  "I actively seek to identify and understand the root causes of problems.",
  "I prepare extensively and study relevant materials before engaging in new tasks or discussions.",
  "I base my arguments on verified data and factual evidence rather than intuition or speculation.",
  "I frequently ask analytical questions such as 'What is happening?' and 'Why is this occurring?'",
  "I am confident working with numbers and interpreting quantitative data.",
  "I structure and organize information systematically to enhance clarity and understanding.",
  "I know how to access and navigate databases to retrieve accurate and relevant information.",
  "I look for subtle differences and distinctions that may influence outcomes.",
  "I apply logical rules and frameworks to interpret and make sense of complex information.",
  "I prefer to have detailed information available to support sound decision-making."
)
engineer <- c(
  "I prefer to maintain control over my work processes and outcomes.",
  "I am decisive and confident in making firm, well-considered decisions.",
  "I am uncomfortable with prolonged inaction and prefer to take initiative.",
  "I value autonomy and seek the freedom to manage both my own work and that of others effectively.",
  "I implement solutions using structured protocols and clear procedures.",
  "I tend to prioritize technical accuracy over emotional or subjective input from others.",
  "I possess strong technical skills and apply them to solve practical problems.",
  "I aim to develop long-term, sustainable solutions rather than temporary fixes.",
  "I have a keen eye for identifying flaws and inefficiencies in systems or processes.",
  "I often ask 'How can this be done?' to focus on implementation and execution.",
  "I maintain a strong focus on objectives and avoid distractions.",
  "I value efficiency and prefer not to spend time on activities that lack clear purpose."
)

explorer <- c(
  "I am drawn to unfamiliar ideas and enjoy exploring new intellectual territory.",
  "I am highly self-motivated and often feel driven to pursue new challenges.",
  "I trust my instincts and spontaneous insights when approaching problems.",
  "I am intrigued by analogies and patterns that suggest deeper connections.",
  "I have a strong sense of curiosity and enjoy asking questions that challenge assumptions.",
  "I actively seek out ambiguity and uncertainty as opportunities for discovery.",
  "I ask exploratory questions like 'What else could be possible?' and 'What if we tried this?'",
  "I look for unresolved issues and questions that invite further investigation.",
  "I enjoy challenging conventions and experimenting with alternative approaches.",
  "I am comfortable taking risks and pushing the boundaries of my current abilities.",
  "I embrace uncertainty and am willing to take calculated risks in pursuit of innovation.",
  "I can become disengaged with routine tasks and may struggle to maintain interest in long-term projects."
)

designer <- c(
  "I often visualize ideas and concepts, thinking in images rather than words.",
  "I look for patterns and relationships within information to generate insights.",
  "I ask imaginative questions like 'Why not try something different?'",
  "I view failure as a valuable opportunity to learn and refine my approach.",
  "I tend to engage in reflective thinking and imaginative exploration.",
  "I focus on overarching themes and the broader context of problems.",
  "I seek inspiration from diverse sources to fuel creative thinking.",
  "I aim to develop solutions that are not only functional but also aesthetically pleasing.",
  "I welcome feedback and use it to improve my ideas and designs.",
  "I value simplicity and elegance in problem-solving and design.",
  "I enjoy presenting and promoting ideas that I believe in.",
  "I am capable of critically evaluating my own work and making objective judgments."
)

problem_solving_questions <- data.frame(a = analyst, n = engineer, x = explorer, d = designer)

create_mc_question <- function(options) {
  mc_question <- function(question_wording, question_category, question_number) {
    df <- data.frame(question = rep(question_wording, 5), option = options,
                     input_type = rep("mc", 5),
                     input_id = rep(question_number, 5),
                     dependence = rep(NA, 5), dependence_value = rep(NA, 5),
                     required = rep(TRUE, 5))
    return(df)
  }
  return(mc_question)
}

mc_question <- create_mc_question(LIKERT5)

question_lookup <- tibble(
  type = rep(c("a", "n", "x", "d"), each = 12),
  index = rep(1:12, times = 4)) %>%
  mutate(id = paste0(type, formatC(index, width = 2, flag = "0"))) %>%
  sample_frac(1)  # Shuffle the rows

# Function to extract and format each question
get_question <- function(type, index) {
  colnum <- which(colnames(problem_solving_questions) == type)
  question_text <- problem_solving_questions[index, colnum]
  mc_question(question_text, type, paste0(type, index))
}

# Build the survey data frame
df <- pmap_dfr(question_lookup, function(type, index, id) {
  get_question(type, index)
})
