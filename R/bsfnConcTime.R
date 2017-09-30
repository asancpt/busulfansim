#' Create a dataset of the concentration-time curve of single oral administration of busulfan
#'
#' \code{bsfnConcTime} will create a dataset of the concentration-time curve
#' 
#' @param Weight Body weight (kg)
#' @param Dose Dose of single busulfan (mg)
#' @param N The number of simulated subjects
#' @return The dataset of concentration and time of simulated subjects
#' @export
#' @examples 
#' bsfnConcTime(Weight = 20, Dose = 200, N = 20)
#' bsfnConcTime(20, 200)
#' @import dplyr
#' @seealso \url{https://asancpt.github.io/bsfnsim}

bsfnConcTime <- function(Weight=60, rate = 100, dur = 3, sex = 'male', N = 20){
  concData <- bsfnPkparam(Weight, rate, dur, sex, N) %>% 
    left_join(expand.grid(subjid = seq(1, N, length.out = N),
                          Time = seq(0,24, by = 0.1)), by = "subjid") %>%
    mutate(Conc = ifelse(test = Time >= dur,
                         # after infusion
                         yes = rate * (V * lambda) * (1 - exp(-lambda * dur)) * exp(-lambda * (Time - dur)),
                         # before infusion
                         no = rate * (V * lambda) * (1 - exp(-lambda * Time)) )) %>%
    select(subjid, Time, Conc)
  return(concData)
}
# bsfnConcTime(sex = 'male')
# bsfnConcTime(sex = 'female')
# test : ggplot(bsfnConcTime(), aes(x=Time, y=Conc, group = subjid)) + geom_line()
# test : ggplot(bsfnConcTime(), aes(x=Time, y=Conc, group = subjid)) + geom_line() + scale_y_log10()

#' Create a dataset of the concentration-time curve of multiple dosing of busulfan
#'
#' \code{bsfnConcTimeMulti} will create a dataset of the concentration-time curve of multiple oral administrations of busulfan
#' 
#' @param Weight Body weight (kg)
#' @param Dose Dose of single busulfan (mg)
#' @param N The number of simulated subjects
#' @param Tau The interval of multiple dosing (hour)
#' @param Repeat The number of dosing
#' @return The dataset of concentration and time of simulated subjects of multiple dosing
#' @export
#' @examples 
#' bsfnConcTimeMulti(Weight = 20, Dose = 200, N = 20, Tau = 8, Repeat = 4)
#' bsfnConcTimeMulti(20, 200)
#' @import dplyr
#' @seealso \url{https://asancpt.github.io/bsfnsim}

bsfnConcTimeMulti <- function(Weight, Dose, N = 20, Tau = 8, Repeat = 4){
  #Weight=20; Dose=300; N = 20; Tau = 8; Repeat = 4
  
  Subject <- seq(1, N, length.out = N) # 
  Time <- seq(0, 96, by = 0.1) # 
  Grid <- expand.grid(x = Subject, y = Time) %>% 
    as_tibble() %>% 
    select(Subject=x, Time=y)
  
  ggsuper <- bsfnPkparam(Weight, Dose, N) %>% 
    select(CL, V, Ka, Ke) %>% 
    mutate(Subject = row_number()) %>% 
    left_join(Grid, by = "Subject") %>% 
    mutate(Conc = Dose / V * Ka / (Ka - Ke) * (exp(-Ke * Time) - exp(-Ka * Time))) %>% 
    group_by(Subject) %>% 
    mutate(ConcOrig = Conc, 
           ConcTemp = 0)
  
  ## Superposition
  for (i in 1:Repeat){
    Frame <- Tau * 10 * i
    ggsuper <- ggsuper %>% 
      mutate(Conc = Conc + ConcTemp) %>% 
      mutate(ConcTemp = lag(ConcOrig, n = Frame, default = 0))
  }
  
  ggsuper <- ggsuper %>% select(Subject, Time, Conc)
  return(ggsuper)
}
