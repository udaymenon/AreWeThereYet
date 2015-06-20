
#setwd("~/datascience coursework/DataProducts")
#runApp("AreWeThereYet")
library(googleVis)
library(shiny)
PctOnTime4 <- read.csv("PctOnTime4-2008.csv")
airports <- read.csv("airports.csv")
airports <- na.omit(airports)
carriers <- read.csv("carriers.csv")
carriers <- na.omit(carriers)
carriers[,"ID"] <- c(1:nrow(carriers))

PctOnTime4$Origin <- factor(PctOnTime4$Origin, levels = levels(airports$iata))
PctOnTime4$Dest <- factor(PctOnTime4$Dest, levels = levels(airports$iata))
PctOnTime4$UniqueCarrier <- factor(PctOnTime4$UniqueCarrier,levels=levels(carriers$Code))


allAirportCodes <- unique(PctOnTime4$Origin)
allAirports <- airports$city[airports$iata %in% allAirportCodes]
allAirports <- na.omit(allAirports)
allAirports <- as.list(sort(as.vector(allAirports)))

ArrDelayMinutes2 <- read.csv("ArrDelayMinutes2-2008.csv")

shinyServer(function(input, output) {

##dataset for chart based on a selected HourOfDay and MeanDelay cutoff
  
delayAtHourAndCutoff <- reactive({
  ArrDelayMinutes2[ArrDelayMinutes2$HourOfDay == input$hourOfDay & ArrDelayMinutes2$MeanDelay > input$delayCutoff,]
  })

  output$airportDelays <- renderGvis({
    validate(
      need(nrow(delayAtHourAndCutoff()) > 0, "No delays to report!"))
    gvisGeoChart(delayAtHourAndCutoff(), 
                     locationvar="CityState", colorvar="MeanDelay", 
                     options=list(displayMode="markers", 
                                  colorAxis="{minValue: 0,  colors: ['yellow','red']}", datalessRegionColor="lightgray", region="US", resolution="provinces"))
  })

  output$originSelector <- renderUI({
    selectInput("origin", "Choose Origin:", allAirports ) 
  })
  output$destSelector <- renderUI({
    
    selectInput("dest", "Choose a Destination:",destAirports()) 
    
  })
  destAirports <- reactive({
    validate(
      need(!is.null(input$origin), "Choose an Origin")
    ) 
    originIata <- airports$iata[airports$city == input$origin]
    originIata <- as.vector(originIata)
    destIata <- PctOnTime4$Dest[PctOnTime4$Origin %in% originIata]
    destIata <- as.vector(destIata)
    destIata <- unique(destIata)
    dAirports <- airports$city[airports$iata %in% destIata]
    as.list(sort(as.vector(dAirports)))
  })
  

onTimeByOriginDest <- reactive( {
 
  validate(
    need(!is.null(input$dest), "Choose a destination")
  )
  # isolate dependency on input$origin - this solves the problem of this function being called
  # before destAirports()
   isolate({ originIata <- airports$iata[airports$city == input$origin]})
    originIata <- as.vector(originIata)
    destIata <- airports$iata[airports$city == input$dest]
    destIata <- as.vector(destIata)
    retVal <- PctOnTime4[PctOnTime4$Origin %in% originIata & PctOnTime4$Dest %in% destIata,]
    
    validate(
      need(nrow(retVal) > 0, "Choose a destination")
    )
    
      retVal$Route <- paste(retVal$Origin,"-",retVal$Dest)
      retVal$Route <- as.factor(retVal$Route)
      ##assign an int ID to each UniqueCarrier
      onTimeCarriers <- sort(unique(retVal$UniqueCarrier))
      onTimeCarriers <- as.data.frame(onTimeCarriers)
      names(onTimeCarriers) <- "UniqueCarrier"
      onTimeCarriers[,"ID"] <- c(1:nrow(onTimeCarriers))
      onTimeCarriers <- merge(onTimeCarriers[, c("UniqueCarrier", "ID")], carriers, by.x="UniqueCarrier",by.y = "Code")
      retVal <- merge(retVal[, c("UniqueCarrier", "Origin","Dest","PctOnTime","Route")], onTimeCarriers, by="UniqueCarrier")
    
    retVal

  })

output$onTimeByRoute <- renderGvis({   
  gvisBubbleChart(onTimeByOriginDest(),xvar="ID.x", yvar="PctOnTime",
                           idvar="Description", sizevar="PctOnTime", colorvar="Route",
                           options=list(
                             hAxis='{minValue:0, maxValue:6, title:"Carrier"}',
                             vAxis='{minValue:0, maxValue:1, title:"PctOnTime"}'                           
                ))
                           
  })
})

