#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(tidyverse)

abc <- read_csv("abc.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
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
})
