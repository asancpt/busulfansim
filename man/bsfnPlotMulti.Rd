% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bsfnPlot.R
\name{bsfnPlotMulti}
\alias{bsfnPlotMulti}
\title{Create concentration-time curve after multiple doses of busulfan}
\usage{
bsfnPlotMulti(bsfnConcTimeMultiData, log = FALSE)
}
\arguments{
\item{bsfnConcTimeMultiData}{data frame of concentration-time dataset having column names Subject, Time, and Conc (case-sensitive)}

\item{log}{y axis log}
}
\value{
The concentration-time curve
}
\description{
\code{bsfnPlotMulti} will create concentration-time curve after multiple doses of busulfan
}
\examples{
bsfnPlotMulti(bsfnConcTimeMulti(Weight = 20, Dose = 200, N = 20, Tau = 8, Repeat = 4))
}
\seealso{
\url{https://asancpt.github.io/bsfnsim}
}
