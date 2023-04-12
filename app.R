library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(markdown)


load("bustabit_new.RData")
load("bustabit_player.RData")
load("bustabit_standardized.RData")
load("bustabit_clus_avg.RData")
load("bustabit_clus_avg_named.RData")


# Convert Username column to UTF-8 encoding
bustabit_new$Username <- iconv(bustabit_new$Username, from = "latin1", to = "UTF-8")



# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Bustabit Analysis"),
  
  dashboardSidebar(
    selectInput("username", "Select a username", choices = unique(bustabit_new$Username)),
    dateRangeInput("date_range", "Select date range", 
                   start = min(bustabit_new$PlayDate), end = max(bustabit_new$PlayDate)),
    numericInput("bet_amount", "Enter bet amount", value = 5, min = 0),
    downloadButton("download_data", "Download Filtered Data"),
    br()
    
  ),
  
  dashboardBody(
    tabBox(
      title = "Bustabit Player Analysis", height = "920px", width = 12,  # Width in bootstrap, height in px
      
      # tab1 - platform        
      tabPanel(
        "Platform Introduction",
        titlePanel("Platform Introduction"),
        div(
          includeMarkdown("Platform Introduction.md"), 
          align = "justify"
        )
      ),
      
      # tab2 - data          
      tabPanel(
        "Data Introduction",
        titlePanel("Data Introduction"),
        DT::dataTableOutput("pt_new"),
        div(
          includeMarkdown("Data Introduction.md"), 
          align = "justify"
        )
      ),
      
      # tab3 -  overview   
      tabPanel(
        "Interactive Overview",
        h2("Summary"),
        verbatimTextOutput("profit_summary"),
        fluidRow(
          box(title = "Filtered Data", solidHeader = TRUE, width = 6, 
              DTOutput("filtered_data")),
          box(title = "Profit/Loss Histogram", solidHeader = TRUE, width = 6,
              plotOutput("profit_loss_histogram"))
        )
      ),
      
      # tab4 - groupby players
      tabPanel(
        "Data per Players",
        titlePanel("Data per Players"),
        div(
          includeMarkdown("Data Group by Players.md"), 
          align = "justify"
        ),
        tags$div(
          tags$h2("Summary of Data Group by Players"),
          DT::dataTableOutput("pt_player")
        )
      ),
      
      # tab5 - Normalization and K means Clustering
      tabPanel(
        "Normalization and Clustering",
        titlePanel("Normalization and Clustering"),
        div(
          includeMarkdown("Normalization.md"), 
          align = "justify"
        ),
        DT::dataTableOutput("pt_norm"),
        div(
          includeMarkdown("K means Clustering.md"), 
          align = "justify"
        ),
        DT::dataTableOutput("pt_kmeans"),
      ),
      
      # tab6 - Visualize the clusters
      tabPanel(
        "Visualize the clusters",
        titlePanel("Visualize the clusters"),
        fluidRow(
          column(width = 12,
                 plotOutput("parallel_plot")
          )
        ),
        fluidRow(
          column(width = 12, plotOutput("cluster_plot"))
        )
      ),
        
      # tab7 - Analyzing the Groups of Gamblers
      tabPanel(
        "Analyzing the Groups of Gamblers",
        titlePanel("Analyzing the Groups of Gamblers"),
        DT::dataTableOutput("pt_named"),
        div(
          includeMarkdown("Analyzing the Groups of Gamblers.md"), 
          align = "justify"
        )
      )
        
      
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  # Create filtered data based on inputs
  filtered_data <- reactive({
    bustabit_new %>%
      filter(Username == input$username,
             PlayDate >= input$date_range[1],
             PlayDate <= input$date_range[2],
             Bet == input$bet_amount) %>%
      select(Bet, CashedOut, Bonus, Profit, BustedAt, PlayDate, Losses)
  })
  
  # Render filtered data table
  output$filtered_data <- renderDT({
    filtered_data()
  })
  
  # Render data table  on tab2-6
  output$pt_new <- DT::renderDataTable(bustabit_new,options = list(pageLength = 5))
  output$pt_player <- DT::renderDataTable(bustabit_player)
  output$pt_norm <- DT::renderDataTable(bustabit_standardized,options = list(pageLength = 5))
  output$pt_kmeans <- DT::renderDataTable(bustabit_clus_avg,options = list(pageLength = 5))
  output$pt_named <- DT::renderDataTable(bustabit_clus_avg_named,options = list(pageLength = 5))
  

  
  # Render profit/loss histogramon tab3
  output$profit_loss_histogram <- renderPlot({
    filtered_data() %>%
      ggplot(aes(x = Profit-Losses)) +
      geom_histogram(binwidth = 0.5, fill = "#0072B2") +
      labs(title = "Profit/Loss Histogram", x = "Profit/Loss", y = "Frequency")
  })
  
  
  # Download filtered data as CSV
  output$download_data <- downloadHandler(
    filename = function() {
      paste("bustabit_", input$username, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data(), file)
    }
  )
  
  # Render profit summary
  output$profit_summary <- renderPrint({
    paste("Total profit/loss for ", input$username, ": $",
          round(sum((filtered_data()$Profit - filtered_data()$Losses)), 2))
  })
  
  # vilualize cluster - a Parallel Coordinate Plot
    # Create the min-max scaling function
    min_max_standard <- function(x) {
      (x -  min(x)) / (max(x) - min(x))
    }
    
    # Apply this function to each numeric variable in the bustabit_clus_avg object
    bustabit_avg_minmax <- bustabit_clus_avg %>%
      mutate_if(is.numeric, min_max_standard)
    
    # Load the GGally package
    library(GGally)
    
    output$parallel_plot <- renderPlot({
      # Create a parallel coordinate plot of the values
      ggparcoord(
        bustabit_avg_minmax, 
        columns = 2:ncol(bustabit_avg_minmax), 
        groupColumn = "cluster", 
        scale = "globalminmax", 
        order = "skewness"
      ) + 
        theme(axis.text.x = element_text(size=6))
    })
  
  # cluster_plot
    output$cluster_plot <- renderPlot({
      # Calculate the principal components of the standardized data
      my_pc <- bustabit_standardized %>%
        select(-Username) %>%
        prcomp()
      my_pc <- as.data.frame(my_pc$x)
      
      # Store the cluster assignments in the new data frame
      my_pc$cluster <- bustabit_player$cluster
      
      # Use ggplot() to plot PC2 vs PC1, and color by the cluster assignment
      p1 <- ggplot(my_pc, aes(x=PC1, y=PC2, color=cluster))+
        geom_point()
      
      # Return the plot
      p1
    })
  
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
