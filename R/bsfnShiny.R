#' Run shiny app to interactively simulate plasma busulfan concentration.
#' 
#' \code{bsfnShiny} runs an internal shiny app \code{Busulfan Concentration Predictor} in order to interactively simulate plasma busulfan concentration.
#' 
#' @return NULL
#' @export
#' @import shiny
#' @seealso \url{https://asan.shinyapps.io/bsfn/}

bsfnShiny <- function() {
  appDir <- system.file("shiny-examples", package = "bsfnsim")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `bsfnsim`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal")
}
