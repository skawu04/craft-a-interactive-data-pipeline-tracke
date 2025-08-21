# 0qgp_craft_a_interac.R

# Load necessary libraries
library(shiny)
library(DT)
library(dygraphs)
library(ggplot2)

# Create a sample data pipeline
pipeline_data <- data.frame(
  stage = c("Ingestion", "Processing", "Storage", "Analysis"),
  timestamp = Sys.time() + c(0, 60, 120, 180),
  status = c("In Progress", "Completed", "In Progress", "Pending"),
  description = c("Data ingestion from source", "Data processing and transformation", "Data storage in database", "Data analysis and visualization")
)

# Create a Shiny UI for the pipeline tracker
ui <- fluidPage(
  titlePanel("Interactive Data Pipeline Tracker"),
  sidebarLayout(
    sidebarPanel(
      h4("Pipeline Stages"),
      checkboxGroupInput("stages", "Select stages to view:", unique(pipeline_data$stage), selected = unique(pipeline_data$stage))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Table", DT::dataTableOutput("table")),
        tabPanel("Chart", dygraphOutput("chart")),
        tabPanel("Description", textOutput("description"))
      )
    )
  )
)

# Create a Shiny server for the pipeline tracker
server <- function(input, output) {
  filtered_data <- reactive({
    pipeline_data[pipeline_data$stage %in% input$stages, ]
  })
  
  output$table <- DT::renderDataTable({
    filtered_data()
  })
  
  output$chart <- renderDygraph({
    dygraph(filtered_data()$timestamp, main = "Pipeline Timeline") %>%
      dySeries("status") %>%
      dyOptions(stepPlot = TRUE)
  })
  
  output$description <- renderText({
    description <- filtered_data()$description[1]
    if (nchar(description) > 0) {
      return(description)
    } else {
      return("No description available")
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)