#' Create a dataset for simulation of single dose of busulfan 
#'
#' \code{bsfnPkparam} will create a dataset for simulation of single dose of busulfan 
#' 
#' @param Weight Body weight (kg)
#' @param Dose Dose of single busulfan (mg)
#' @param N The number of simulated subjects
#' @return The dataset of pharmacokinetic parameters of subjects after single busulfan dose following multivariate normal
#' @export
#' @examples 
#' bsfnPkparam(Weight = 20, Dose = 200, N = 20)
#' bsfnPkparam(20,500)
#' @importFrom mgcv rmvn
#' @import dplyr
#' @import tibble
#' @seealso \url{https://asancpt.github.io/bsfnsim}

bsfnPkparam <- function(Weight=30, rate = 100, dur = 3, sex = 'male', N = 20){
  mgcv::rmvn(n = N, mu = BsfnMu, V = BsfnSigma) %>% # MVN: positive semi definite covariance matrix
    as_tibble() %>% 
    select(eta1 = 1, eta2 = 2) %>% 
    mutate(CL = theta$t1 * sqrt(Weight) * exp(eta1), # L/hr
           V  = theta$t2 * sqrt(Weight) * ifelse(sex == 'male', 1 + theta$t3, 1) * exp(eta2), # L
           lambda = CL / V, # k
           Css = rate / CL, # steady state plasma conc
           Half_life = 0.693 / lambda) %>% 
    mutate(subjid = row_number())
}
# bsfnPkparam()
           #Tmax = (log(Ka) - log(Ke)) / (Ka - Ke),
           #Cmax = Dose / V * Ka / (Ka - Ke) * (exp(-Ke * Tmax) - exp(-Ka * Tmax)), 
           #AUC  = Dose / CL, # mg/h/L

# CL & V are known, C=1/V, lambda = CL/V


#' Create a dataset for simulation of multiple dose of busulfan 
#'
#' \code{bsfnPkparamMulti} will create a dataset for simulation of multiple dose of busulfan 
#'
#' @param Weight Body weight (kg)
#' @param Dose Dose of multiple busulfan (mg)
#' @param N The number of simulated subjects
#' @param Tau The interval of multiple dosing (hour)
#' @return The dataset of pharmacokinetic parameters of subjects after multiple busulfan dose following multivariate normal
#' @export
#' @examples 
#' bsfnPkparamMulti(Weight = 20, Dose = 200, N = 20, Tau = 8)
#' bsfnPkparamMulti(20,500)
#' @importFrom mgcv rmvn
#' @import dplyr
#' @import tibble
#' @seealso \url{https://asancpt.github.io/bsfnsim}

bsfnPkparamMulti <- function(Weight, Dose, N = 20, Tau = 8){
  mgcv::rmvn(N, BsfnMu, BsfnSigma) %>% 
    as_tibble() %>% 
    select(eta1 = 1, eta2 = 2, eta3 = 3) %>% 
    mutate(CL = theta$t1 * Weight * exp(eta1), # L/hr
           V  = theta$t2 * Weight * exp(eta2), # L
           Ka = 4.268 * exp(eta3), # /hr
           Ke = CL / V, # /hr
           Half_life = 0.693 / Ke,
           Tmax = (log(Ka) - log(Ke)) / (Ka - Ke),
           Cmax = Dose / V * Ka / (Ka - Ke) * (exp(-Ke * Tmax) - exp(-Ka * Tmax)),
           AUC  = Dose / CL,
           AI = 1/(1-exp(-1*Ke*Tau)),
           Aavss = 1.44 * Dose * Half_life / Tau,
           Cavss = Dose / (CL * Tau), 
           Cminss = Dose * exp(-Ke * Tau) / (V * (1 - exp(-Ke * Tau))),
           Cmaxss = Dose / (V * (1 - exp(-Ke * Tau)))) %>% 
    mutate(subjid = row_number()) %>% 
    select(subjid, TmaxS = Tmax, CmaxS = Cmax, AUCS = AUC, 
           AI, Aavss, Cavss, Cmaxss, Cminss)
}
