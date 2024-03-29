% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/oauth_functions.R
\name{get_oauth_access_token}
\alias{get_oauth_access_token}
\title{Get OAuth Access Token}
\usage{
get_oauth_access_token(oauth_list, session)
}
\arguments{
\item{oauth_list}{A named list. The list must have the following items:
\itemize{
\item "config" a named list of parameters for theis specific shiny app. It
must have a field named "app_url".
\item "endpoint" an object of type httr::oauth_endpoint()
\item "app" an object pf type httr::oauth_app()
}}

\item{session}{a shiny session}
}
\description{
Get OAuth Access Token
}
