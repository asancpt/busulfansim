# setup ----

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(markdown)
library(mgcv)
library(caffsim)

selectBwt <- c(23, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 84)

paramValueDesc <- function(df) {
  df %>% 
    gather(param, value) %>% 
    group_by(param) %>% 
    summarise_at(vars(value), funs(mean, sd, min, max)) %>% 
    mutate(value = sprintf('%0.2f (%0.2f) [%0.2f-%0.2f]', mean, sd, min, max)) %>% 
    select(param, value) 
}

round_df <- function(df, digits) {
  # round all numeric variables
  # df: data frame 
  # digits: number of digits to round
  numeric_columns <- sapply(df, mode) == 'numeric'
  df[numeric_columns] <-  round(df[numeric_columns], digits)
  return(df)
}

caffOverLimit <- function(caffConcTime){
  caffConcTime %>% 
    mutate(Conc40 = ifelse(Conc >=40, 0.1, 0),
           Conc80 = ifelse(Conc >=80, 0.1, 0)) %>% 
    select(Subject, Conc40, Conc80) %>% 
    group_by(Subject) %>% 
    summarise(MeanConc80 = sum(Conc80), 
              MeanConc40 = sum(Conc40)) %>% 
    select(-Subject) %>% 
    # paramValueDesc starts
    gather(param, value) %>% 
    group_by(param) %>% 
    summarise_at(vars(value), funs(mean, sd, min, max)) %>% 
    mutate(value = sprintf('%0.2f (%0.2f) [%0.2f-%0.2f]', mean, sd, min, max)) %>% 
    select(param, value) %>% 
    # paramValueDesc ends
    mutate(param = ifelse(param == 'MeanConc40', 'Duration of conc. >40mg/L (hr)', 'Duration of conc. >80mg/L (hr)'))
}

#input <- list()
#input$concBWT <- 50; input$concDose <- 200; input$concNum <- 20
#input$cmaxDose <- 50; input$cmaxNum <- 20
#input$aucDose <- 50; input$aucNum <- 20
#input$Log <- FALSE
#input$superBWT <- 20; input$superDose <- 500; input$superNum <- 20; input$superTau <- 5; input$superRepeat <- 3

# main ----

shinyServer(function(input, output, session) {
  
  # showdata ---- 
  
  output$showdata <- renderDataTable({
    #set.seed(Seed)
    showdataTable <- round_df(caffDataset(input$concBWT, input$concDose, input$concNum), 2) %>% 
      mutate(SUBJID = row_number()) %>% 
      select(9, 1:8)
    return(showdataTable)
  }, options = list(pageLength = 10))
  
  # showdataall ----
  
  output$showdataall <- renderTable({
    if (input$showme == FALSE)
      return(NULL)
    
    #set.seed(Seed)
    showall <- round_df(caffDataset(input$concBWT, input$concDose, input$concNum), 2) %>% 
      mutate(SUBJID = as.character(row_number())) %>% 
      select(9, 1:8)
    return(showall)
  })
  
  # cmaxplot ----
  
  output$plot <- renderPlot({
    ggDset <- lapply(selectBwt, function(x){
      caffDataset(x, input$cmaxDose, input$cmaxNum) %>% 
        select(Cmax) %>% 
        mutate(BWT = x)
    }) %>% 
      bind_rows()
    
    p <- ggplot(ggDset, aes(x=factor(BWT), y=Cmax, colour=Cmax)) +
      xlab("Body Weight (kg)") + ylab("Cmax (mg/L)") +
      geom_hline(yintercept = 80, colour="red") + 
      geom_hline(yintercept = 40, colour="blue") + 
      geom_hline(yintercept = 10, colour="green") +
      scale_colour_gradient(low="navy", high="red", space="Lab") + theme_linedraw()
    if (input$pformat == "Jitter") print(p + geom_jitter(position = position_jitter(width = .1)))
    if (input$pformat == "Point") print(p + geom_point())
    if (input$pformat == "Boxplot") print(p + geom_boxplot())
  })
  
  # aucplot ----
  
  output$aucplot <- renderPlot({
    ggDset <- lapply(selectBwt, function(x){
      caffDataset(x, input$aucDose, input$aucNum) %>% 
        select(AUC) %>% 
        mutate(BWT = x)
    }) %>% 
      bind_rows()
    
    p <- ggplot(ggDset, aes(x=factor(BWT), y=AUC, colour=AUC)) +
      xlab("Body Weight (kg)") + 
      ylab("AUC (mg*hr/L)") + 
      theme_linedraw()
    if (input$paucformat == "Jitter") print(p + geom_jitter(position = position_jitter(width = .1)))
    if (input$paucformat == "Point") print(p + geom_point())
    if (input$paucformat == "Boxplot") print(p + geom_boxplot())
  })
  
  # overlimit ----
  
  output$overlimit <- renderTable({
    overLimit <- caffConcTime(input$concBWT, input$concDose, input$concNum) %>% 
      caffOverdose()
    return(overLimit)
  })
  
  # overlimitMulti ----
  
  output$overlimitMulti <- renderTable({
    overLimit <- caffConcTimeMulti(input$superBWT, input$superDose, input$superNum,
                                   input$superTau, input$superRepeat) %>% 
      caffOverdose()
    return(overLimit)
  })
  
  # conccontents ----
  
  output$conccontents <- renderTable({
    descParam <- caffDataset(input$concBWT, input$concDose, input$concNum) %>% 
      gather(param, value) %>% 
      paramValueDesc() %>% 
      left_join(tribble(~param, ~name,
                        "Tmax", "Tmax (hr)",
                        "Cmax", "Cmax (mg/L)",
                        "AUC", "AUC (mg*hr/L)",
                        "Half_life", "Half_life (hr)",
                        "CL", "CL (L/hr)",
                        "V", "V (L)",
                        "Ka", "Ka (1/hr)",
                        "Ke", "Ke (1/hr)"), by = 'param') %>% 
      select(param = name, `value: mean (sd) [min-max]` = value)
    return(descParam)
  })
  
  # concplot ----
  
  output$concplot <- renderPlot({
    p <- caffPlot(caffConcTime(input$concBWT, input$concDose, input$concNum))
    return(p)
  })
  
  # supercontents ----
  
  output$supercontents <- renderTable({
    descParam <- caffDatasetMulti(input$superBWT, input$superDose, input$superNum, input$superTau) %>% 
      gather(param, value) %>% 
      paramValueDesc()
    return(descParam)
    # ConcUnit[ConcUnit == "Tmax"] <- "Tmax (hr)"
    # ConcUnit[ConcUnit == "Cmax"] <- "Cmax (mg/L)"
    # ConcUnit[ConcUnit == "Cssav"] <- "Cav,ss (mg/L)"
    # ConcUnit[ConcUnit == "AUC"] <- "AUC (mg*hr/L)"
  })
  
  # superplot ----  
  
  output$superplot <- renderPlot({
    
    p <- caffPlotMulti(caffConcTimeMulti(input$superBWT, input$superDose, input$superNum, input$superTau, input$superRepeat), 
                       log = input$Log)
    return(p)
  })
})
