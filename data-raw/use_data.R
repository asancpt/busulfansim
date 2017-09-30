# setup ----
library(tidyverse)

tv <- list(cl = 7.6, malev = 32.2, femalev = 29.1)
tv

theta <- list(t1 = tv$cl / sqrt(65),
              t2 = tv$femalev / sqrt(65),
              t3 = tv$malev / (tv$femalev / sqrt(65) * sqrt(65)) - 1)
theta

library(tidyverse)

# 2x2 matrix
BsfnSigma <- matrix(c(0.16, 0.063,
                      0.063, 0.09), 
                    byrow = TRUE, 
                    nrow = 2) %>% 
  print()

BsfnMu <- c(0, 0)

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
