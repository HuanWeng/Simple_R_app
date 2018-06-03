library(shiny)
library(tidyverse)
library(DT)
library(colourpicker)

abc <- read_csv("abc.csv")

ui <- fluidPage(titlePanel("Virginia ABC Store prices"),
                sidebarLayout(
                  sidebarPanel(
                    sliderInput(
                      "priceInput",
                      "Price",
                      min = 0,
                      max = 100,
                      value = c(25, 40),
                      pre = "$"
                    ),
                    checkboxInput(
                      "sortInput",
                      "Sort by price",
                      value = TRUE
                    ),
                    checkboxGroupInput(
                      "typeInput",
                      "Product type",
                      choiceNames = list("Mixers", "Rimmers", "Spirits", "Wine"),
                      choiceValues = list("Mixers", "Rimmers", "Spirits", "Wine")
                    ),
                    selectInput(
                      "proofInput",
                      "Proof",
                      choices = c("0-40", "40-80", "80-120", "120-160", "160+")
                    ),
                    uiOutput("subtypeInput"),
                    colourInput("plotColorInput", 
                                "Color", 
                                "red")
                  ),
                  mainPanel(textOutput("number"),
                            br(),
                            downloadButton("export", label = "Download"),
                            hr(),
                            tabsetPanel(
                              tabPanel("Plot", plotOutput("coolplot")),
                              tabPanel("Table", DT::dataTableOutput("results"))
                            )
                  )
                ))

server <- function(input, output) {
  filtered <- reactive({
    if(is.null(input$subtypeInput) | is.null(input$typeInput)) {
      return(NULL)
    }
    
    abc %>%
      filter(
        CurrentPrice >= input$priceInput[1],
        CurrentPrice <= input$priceInput[2],
        Type %in% input$typeInput,
        ProofBin == input$proofInput,
        Subtype == input$subtypeInput
      )
  })
  
  output$subtypeInput <- renderUI({
    subtypeFilter <- filter(abc, Type %in% input$typeInput)
    selectInput("subtypeInput", "Subtype",
                sort(unique(subtypeFilter$Subtype)),
                selected = "Whiskey")
  })
  
  output$number <- renderText({
    if (is.null(input$typeInput)) {
      paste("We found 0 option(s) for you")
    }
    else {
      paste("We found", nrow(filtered()), "option(s) for you")
    }
  })
  
  output$export <- downloadHandler(
    paste("abc-data-", Sys.Date(), ".csv", sep=""),
    content = function(file) {
      write.csv(filtered(), file)
    }
  )
  
  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    ggplot(filtered(), aes(Size)) +
      geom_histogram(fill = input$plotColorInput)
  })
  
  output$results <- DT::renderDataTable({
    if(input$sortInput == TRUE & !is.null(filtered())) {
      filtered() %>%
        arrange(desc(CurrentPrice))
    }
    else {
      filtered()
    }
  })
}

shinyApp(ui = ui, server = server)