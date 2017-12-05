#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
#Load library environment
library(shiny)
library(ggplot2)
library(lubridate)
library(forecast)
library(plyr)
#Load the data from csv
data <- read.csv("ad_sales_data.csv", header = TRUE, stringsAsFactors = FALSE, sep = ",")
#reformat and preprocess the data
names(data) <- tolower(names(data))
data$month <- as.Date(data$month, format = "%m/%d/%y")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$date <- renderText({paste("Compiled:", as.character(Sys.Date()))})
  output$plot_ads_history <- renderPlot({
    plot_ads_history <- ggplot(data, aes(x = month, y = advertising)) + geom_point(color = "red", size = 2) + geom_line(alpha = 0.75, size = 1, color = "black") + xlab("Month") + ylab("Advertising Expenditures") + theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.text= element_text(size = 16), legend.position = "bottom", legend.title= element_text(size = 20))
    print(plot_ads_history)
  })
  output$plot_sales_history <- renderPlot({
    plot_sales_history <- ggplot(data, aes(x = month, y = sales)) + geom_point(color = "green", size = 2) + geom_line(alpha = 0.75, size = 1, color = "black") + xlab("Month") + ylab("Sales") + theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.text= element_text(size = 16), legend.position = "bottom", legend.title= element_text(size = 20))
    print(plot_sales_history)
  })
  
  forecast_function <- function(month_end, year_end, a, b, c){
      fc_data <- data.frame(ReportDate = as.Date(data$month, format = "%Y-%m-%d"), 
                            advertising = data$advertising,
                            sales = data$sales, 
                            Type = "Train")

    fc_data <- arrange(fc_data, ReportDate)
    n_month <- length(seq(from = max(fc_data$ReportDate), to = as.Date(paste(paste(year_end, month_end, sep = "-"), 01, sep = "-"), format = "%Y-%m-%d"), by = 'month')) -1
    fc.ts_ad <- ts(fc_data$advertising, start = c(year(min(fc_data$ReportDate)), month(min(fc_data$ReportDate))), frequency = 12)
    fc.ts_sales <- ts(fc_data$sales, start = c(year(min(fc_data$ReportDate)), month(min(fc_data$ReportDate))), frequency = 12)
    fit_ad <- HoltWinters(fc.ts_ad, alpha = a, beta = b, gamma = c)
    fit_sales <- HoltWinters(fc.ts_sales, alpha = a, beta = b, gamma = c)
    fc_ad <- predict(fit_ad, n.ahead = n_month)
    fc_sales <- predict(fit_sales, n.ahead = n_month)
    fc_ad <- ifelse(fc_ad < 0, 0, fc_ad)
    fc_sales <- ifelse(fc_sales < 0, 0, fc_sales)
    
    data.fc <- data.frame(ReportDate = seq(from = (max(fc_data$ReportDate) %m+% months(1)), to = as.Date(paste(paste(year_end, month_end, sep = "-"), 01, sep = "-"), format = "%Y-%m-%d"), by = "month"),
                          fc_ad,
                          fc_sales,
                          Type = "Forecast")
    names(data.fc)[2:3] <- c("advertising", "sales")
    data.all <- rbind(fc_data, data.fc)
    data.all$Month <- format(data.all$ReportDate, "%Y-%m")
    return(data.all)
  }

#Calculate for Advertising
  ads <- reactive({
     all <- forecast_function( input$month_end, input$year_end, input$alpha_ad, input$beta_ad, input$gamma_ad)
     return(all)
  })
  output$plot_ads <- renderPlot({
    ggplot(ads(), aes(x = Month, y = advertising, color = Type)) + geom_point() + geom_line(alpha = 0.5, size = 0.5, aes(group = Type)) + xlab("Month") + ylab("Advertising Expenditures") + theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.text= element_text(size = 7), legend.position = "bottom", legend.title= element_text(size = 10))
  })

#Calculate for Sales
  sales <- reactive({
    all <- forecast_function(input$month_end, input$year_end, input$alpha_sales, input$beta_sales, input$gamma_sales)
    return(all)
  })
  output$plot_sales <- renderPlot({
    ggplot(sales(), aes(x = Month, y = sales, color = Type)) + geom_point() + geom_line(alpha = 0.5, size = 0.5, aes(group = Type)) + xlab("Month") + ylab("Sales") + theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.text= element_text(size = 7), legend.position = "bottom", legend.title= element_text(size = 10))
  })
  
})
