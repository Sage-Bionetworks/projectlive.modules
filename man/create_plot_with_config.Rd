% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_functions.R
\name{create_plot_with_config}
\alias{create_plot_with_config}
\title{Create Plot With Config
This function calls a ploting function using a config, and a tibble}
\usage{
create_plot_with_config(data, config, plot_func, ...)
}
\arguments{
\item{data}{A tibble}

\item{config}{A named list. The list must have the fields "plot" and
tooltips". The "plot" field must be named list of the arguemnts of the
plot_func. The "tooltips" field must be a list of strings that are either
names of columns in the data, or names of aesthetics in the plot_func}

\item{plot_func}{A string that is the name of a plot function}

\item{...}{Arguments to plotly::ggplotly}
}
\description{
Create Plot With Config
This function calls a ploting function using a config, and a tibble
}
\examples{

data <- dplyr::tibble(
 "Study Leads" = c("s1", "s2", "s3"),
 "Resource Type" = c("r1", "r2", "r3"),
 "Year" = c(2000L, 2001L, 2002L),
 "Month" = factor("Jul", "Jul", "Jun"),
 "Count" = c(10, 30, 40)
)
config <- list(
  "plot" = list(
    "x" = "Study Leads",
    "y" = "Count",
    "fill" = "Resource Type",
    "facet" = list("Year", "Month")
  ),
  "tooltips" = list("count", "fill")
)
create_plot_with_config(
data, config, "create_file_upload_timeline_plot"
)
}
