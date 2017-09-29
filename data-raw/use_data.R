# setup ----

library(tidyverse)

BsfnSigma <- matrix(c(0.1599, 6.095e-2, 9.650e-2, 
                      6.095e-2, 4.746e-2, 1.359e-2, 
                      9.650e-2, 1.359e-2, 1.004), nrow = 3)
BsfnMu <- c(0,0,0)

theta <- list()
theta$t1 <- 1
theta$t2 <- 2

UnitTable <- tribble(~Parameters, ~Parameter,
                     "Tmax","T~max~ (hr)",
                     "Cmax","C~max~ (mg/L)",
                     "AUC","AUC (mg*hr/L)",
                     "Half_life","Half-life (hr)",
                     "CL","CL (L/hr)",
                     "V","V (L)",
                     "Ka","K~a~ (1/hr)",
                     "Ke","K~e~ (1/hr)",
                     "AI","R~ac~ (1/hr)",
                     "Aavss","A~av,ss~ (mg)",
                     "Cavss","C~av,ss~ (mg/L)",
                     "Cmaxss","C~max,ss~ (mg/L)",
                     "Cminss","C~min,ss~ (mg/L)",
                     "TmaxS","T~max,single~ (hr)",
                     "CmaxS","C~max,single~ (mg/L)",
                     "AUCS","AUC~single~ (mg*hr/L)") %>% 
  as.data.frame(stringsAsFactors = FALSE)

# save ----

devtools::use_data(BsfnSigma, 
                   BsfnMu,
                   UnitTable,
                   theta,
                   internal = TRUE, overwrite = TRUE)

# Seed <- sample.int(10000, size = 1)

# round_df <- function(x, digits) {
#   # round all numeric variables
#   # x: data frame 
#   # digits: number of digits to round
#   numeric_columns <- sapply(x, mode) == 'numeric'
#   x[numeric_columns] <-  round(x[numeric_columns], digits)
#   x
# }
