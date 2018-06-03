#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Define UI for application that draws a histogram
shinyUI(fluidPage(titlePanel("Virginia ABC Store prices"),
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
)))