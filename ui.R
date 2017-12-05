
library(shiny)
library(ggplot2)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Real-time Holt-Winters Time Series Forecast"),
  fluidRow(
    column(9, h4(uiOutput("repo"))),
    column(3, h4(textOutput("date")))
  ),
  hr(),
  fluidRow(
    h3("Introduction to Holt-Winters Time Series"),
    p("If you have a time series that can be described using an additive model with increasing or decreasing trend and seasonality, you can use Holt-Winters exponential smoothing to make short-term forecasts. Holt-Winters exponential smoothing estimates the level, slope and seasonal component at the current time point. Smoothing is controlled by three parameters: alpha, beta, and gamma, for the estimates of the level, slope b of the trend component, and the seasonal component, respectively, at the current time point. The parameters alpha, beta and gamma all have values between 0 and 1, and values that are close to 0 mean that relatively little weight is placed on the most recent observations when making forecasts of future values."),
    p("Below is an example of Holt-Winters Forecast.")
  ),
  fluidRow(
    h3("36 Consecutive Monthly Advertising Expense and Sales Data of a Dietary Weight Control Product"),
    p("The following two charts show the monthly advertising expenditures and Sales in past 36 months of a dietary weight control product."),
    column(6, 
           h4("Advertising Expenditures"),
           plotOutput('plot_ads_history')),
    column(6,
           h4("Sales"),
           plotOutput('plot_sales_history'))
  ),
  fluidRow(
    h3("Forecast for Future Advertising Expenditures and Sales"),
    hr(),
    h4("Please select the month and year you want to forecast to"), 
    p("The default starting month is Jan 2018 since the current available historical data is till Dec 2017"),
    br(),
    column(3,
           selectInput("month_start", "Starting Month:", choices = c(1:1))),
    column(3,
           selectInput("year_start", "Starting Year:", choices = c(2018:2018))),
    column(3,
           selectInput("month_end", "Ending Month:", choices = c(1:12))),
    column(3,
           selectInput("year_end", "Ending Year:", choices = c((as.integer(format(Sys.Date(),"%Y"))+1) : (as.integer((format(Sys.Date(),"%Y")))+4))))
  ),
  fluidRow(
    h4("Please select the Holt-Winters forecast parameters for the time series."),
    column(4, p("Alpha: Specifies how to smooth the level component")),
    column(4, p("Beta: Specifies how to smooth the trend component")),
    column(4, p("Gamma: Specifies how to smooth the seasonal component"))
  ),
  navlistPanel(
    "Forecast Perspective",
    tabPanel(
      "Advertising Expenditures",
      sidebarLayout(
        sidebarPanel(
          h4("Parameter Selection:"),
          sliderInput("alpha_ad", "Alpha:", min = 0, max = 1, value = 0.5, step = 0.01),
          sliderInput("beta_ad", "Beta:", min = 0, max = 1, value = 0.5, step = 0.01),
          sliderInput("gamma_ad", "Gamma:", min = 0, max = 1, value = 0.5, step = 0.01)
      ),
      mainPanel("Future Advertising Expenditures Forecast", plotOutput("plot_ads"))
      )
  ),
  tabPanel(
    "Sales",
    sidebarLayout(
      sidebarPanel(
        h4("Parameter Selection:"),
        sliderInput("alpha_sales", "Alpha:", min = 0, max = 1, value = 0.5, step = 0.01),
        sliderInput("beta_sales", "Beta:", min = 0, max = 1, value = 0.5, step = 0.01),
        sliderInput("gamma_sales", "Gamma:", min = 0, max = 1, value = 0.5, step = 0.01)
      ),
      mainPanel("Sales Forecast", plotOutput("plot_sales"))
    )
  )
  )
))
