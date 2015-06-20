
library(shiny)

# Define UI for slider demo application
shinyUI(navbarPage("Are We There Yet?", theme="bootstrap.cerulean.css",
           tabPanel("Home",
                    fluidRow(
                      column(8,offset = 2,
                         p("This application provides historical ontime data
                          for U.S. Air travel in 2008. The data for this analysis 
                           comes from the ",tags$strong("Bureau of Transportation Statistics")," which
                           tracks departure and arrival information by carrier and route,
                          for every airline in the United States."),
                         
                         p("Ontime information is computed
                          by comparing scheduled and actual arrival times and is made
                           available for every flight that originated and terminated 
                          at a domestic airport in the United States. 
                           "),
                         
                         p("We present several views of the data including:",
                           tags$ol(
                             tags$li("Mean arrival delays by time of day at each airport (Airport Delays)"),
                            tags$li("On time performance by carrier and route (OnTime By Route)")
                            
                        
                           
                           )
                        ),
                        tags$b("Airport Delays"),
                        
                        p("This view shows the average arrival delay (MeanDelay) at a given airport across all 
                          carriers servicing that airport over every day of the year 2008. ArrivalDelay = (ActualArrivalTime - ScheduledArrivalTime)
                          and is reported in minutes. Flights that arrive ahead of schedule are treated as
                          having ArrivalDelay = 0."),
                      
                        p("This tab includes two sliders, one to set the arrival time of day using a 24 hour clock,
                          and one to set the minimum delay cutoff threshold which has the effect of filtering out 
                          delays below the threshold thus reducing clutter on the map. "),
                        
                        p(tags$em("Note: Please allow additional time for rendering all data points 
                                  when the minimum delay is set below 30 min")),
                        
                        tags$b("OnTime By Route"),
                        
                        p("This view shows the percent on time (PctOnTime) for a given carrier and route. PctOnTime is 
                          computed as fraction of days in the year when a given flight arrived on or before schedule i.e.,
                          ArrivalDelay = 0. PctOnTime values are therefore in the 0-1 range"),


                        p("This tab includes two selectInput views, one for the city where the flight originates and one where it terminates.  
                          Given a pair of Originating 
                          and Destination cities, this view shows PctOnTime for every combination of carrier and
                          route. Here route is defined as a pair of airports, not cities. Thus large metros such 
                          as Chicago will include data for multiple airports (e.g., Midway and OHare)"),
                        p(tags$em("Note: The list of possible destinations is computed everytime the 
                        user selects an Originating city."))
                        
                      )                   
                    )
           ),
          tabPanel("Airport Delays",
            sidebarLayout(
            sidebarPanel(
              sliderInput("hourOfDay", "Hour Of Day:", 
                  min=0, max=24, value=12),      
              sliderInput("delayCutoff", "Min Delay Cutoff:", 
                  min = 0, max = 60, value = 30, step= 1)
              ),
              mainPanel(
                tags$em("Mouse over bubble to see detail"),
                htmlOutput("airportDelays")
              )
           )
          ),
          tabPanel("OnTime By Route",
                   sidebarLayout(
                     sidebarPanel(
                       uiOutput("originSelector"), 
                       uiOutput("destSelector")
                       
                     ),
                     mainPanel(
                       tags$em("Mouse over bubble to see detail"),
                       htmlOutput("onTimeByRoute")
                     )
                   )
          ) 
      )
)

