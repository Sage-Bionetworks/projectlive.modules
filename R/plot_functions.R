#' Create Plot With Config
#' This function calls a ploting function using a config, and a tibble
#'
#' @param data A tibble
#' @param config A named list. The list must have the fields "plot" and
#' tooltips". The "plot" field must be named list of the arguemnts of the
#' plot_func. The "tooltips" field must be a list of strings that are either
#' names of columns in the data, or names of aesthetics in the plot_func
#' @param plot_func A string that is the name of a plot function
#' @param ... Arguments to plotly::ggplotly
#' @importFrom magrittr %>%
#' @importFrom rlang !!!
#' @examples
#'
#' data <- dplyr::tibble(
#'  "Study Leads" = c("s1", "s2", "s3"),
#'  "Resource Type" = c("r1", "r2", "r3"),
#'  "Year" = c(2000L, 2001L, 2002L),
#'  "Month" = factor("Jul", "Jul", "Jun"),
#'  "Count" = c(10, 30, 40)
#' )
#' config <- list(
#'   "plot" = list(
#'     "x" = "Study Leads",
#'     "y" = "Count",
#'     "fill" = "Resource Type",
#'     "facet" = list("Year", "Month")
#'   ),
#'   "tooltips" = list("count", "fill")
#' )
#' create_plot_with_config(
#' data, config, "create_file_upload_timeline_plot"
#' )
#' @export
create_plot_with_config <- function(data, config, plot_func, ...){
  fig <-
    rlang::exec(plot_func, !!!config$plot, data = data) %>%
    plotly::ggplotly(
      tooltip = c(config$tooltips),
      ...
    ) %>%
    plotly::layout(
      autosize = T
    )
}


#' Create Initiative Activity Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param facet A list of string that are names of columns in the data
#' @param y A string that is the name of a column in the data
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_initiative_activity_plot <- function(
  data,
  x,
  fill,
  facet,
  y = "Count",
  y_axis_text = NULL
){
  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      position = "stack",
      alpha = 0.8,
      na.rm = TRUE,
      show.legend = FALSE
    ) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "",
      y = "Number of files"
    ) +
    ggplot2::facet_grid(cols = ggplot2::vars(!!!rlang::syms(unlist(facet)))) +
    ggplot2::theme(
      legend.text = ggplot2::element_text(size = 8),
      axis.text.x  = ggplot2::element_blank(),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "right",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Resources Generated Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param facet A list of string that are names of columns in the data
#' @param y A string that is the name of a column in the data
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_resources_generated_plot <- function(
  data,
  x,
  fill,
  facet,
  y = "Count",
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      position = "stack",
      alpha = 1.0,
      na.rm = TRUE
    ) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "",
      y = "Number of files per resource"
    ) +
    ggplot2::facet_grid(cols = ggplot2::vars(!!!rlang::syms(unlist(facet)))) +
    ggplot2::theme(
      legend.text = ggplot2::element_text(size = 8),
      axis.text.x  = ggplot2::element_blank(),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "none",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create File Upload Timeline Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param y A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param facet A list of string that are names of columns in the data
#' @param y A string that is the name of a column in the data
#' @param x_axis_text A list of parameters to
#' axis.text.x = ggplot2::element_text()
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_file_upload_timeline_plot <- function(
  data,
  x,
  fill,
  facet,
  y = "Count",
  x_axis_text = NULL,
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "", y = "Number of files uploaded") +
    ggplot2::facet_grid(
      cols = ggplot2::vars(!!!rlang::syms(unlist(facet))),
      scales = "free"
    ) +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.text.x = rlang::exec(ggplot2::element_text, !!!x_axis_text),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "right",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Publication Status Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param y A string that is the name of a column in the data
#' @param x_axis_text A list of parameters to
#' axis.text.x = ggplot2::element_text()
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!
create_publication_status_plot <- function(
  data,
  x,
  fill,
  y = "Count",
  x_axis_text = NULL,
  y_axis_text = NULL
){
  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::labs(title = "", y = "Number of publications") +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.text.x = rlang::exec(ggplot2::element_text, !!!x_axis_text),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      legend.position = "none",
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Publication Disease Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param y A string that is the name of a column in the data
#' @param x_axis_text A list of parameters to
#' axis.text.x = ggplot2::element_text()
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!
create_publication_disease_plot <- function(
  data,
  x,
  fill,
  y = "Count",
  x_axis_text = NULL,
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::labs(title = "", y = "Number of publications") +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.text.x = rlang::exec(ggplot2::element_text, !!!x_axis_text),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      legend.position = "bottom",
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Study Timeline Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param facet A list of string that are names of columns in the data
#' @param y A string that is the name of a column in the data
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_study_timeline_plot <- function(
  data,
  x,
  fill,
  facet,
  y = "Count",
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::labs(title = "", y = "Number of files uploaded") +
    ggplot2::facet_grid(cols = ggplot2::vars(!!!rlang::syms(unlist(facet)))) +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.text.x  = ggplot2::element_blank(),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "left",
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Data Focus Plots
#'
#' @param data_list A list of tibbles
#' @param config A named list that has the "plot" name. The "plot" value
#' must be a named list with the "x" name, which is a name in each tibble in the
#' data list, and a "fill" name with is a list of columns, equal to the length
#' of the data list.
#' @export
#' @examples
#' data_list <- list(
#'  "Assays" = dplyr::tribble(
#'   ~Study, ~Assays,
#'   "s1",   "a1",
#'   "s1",   "a2"
#' ),
#'  "Resources" = dplyr::tribble(
#'   ~Study, ~Resources,
#'   "s1",   "r1",
#'   "s1",   "r1"
#'  )
#' )
#'
#' config <- list(
#'   "plot" = list(
#'     "x" = "Study",
#'     "fill" = list(
#'       "Assay",
#'       "Resources"
#'     )
#'   )
#' )
# create_data_focus_plots(data_list, config)
create_data_focus_plots <- function(data_list, config){
  data_list %>%
    purrr::imap(
      ~ create_data_focus_plot(
        data = .x,
        x = config$plot$x,
        fill = .y,
        y_axis_text = config$plot$y_axis_text
      )
    ) %>%
    purrr::map(plotly::ggplotly, tooltip = config$tooltips) %>%
    plotly::subplot(titleX = TRUE)
}

#' Create Data Focus Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!
create_data_focus_plot <- function(
  data,
  x,
  fill,
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "count",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::labs(
      title = "", y = "Number of files uploaded", x = fill
    ) +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.text.x  = ggplot2::element_blank(),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "none",
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Create Annotation Activity Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param facet A list of string that are names of columns in the data
#' @param y A string that is the name of a column in the data
#' @param x_axis_text A list of parameters to
#' axis.text.x = ggplot2::element_text()
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_annotation_activity_plot <- function(
  data,
  x,
  fill,
  facet,
  y = "Count",
  x_axis_text = NULL,
  y_axis_text = NULL
  ){

  p <- data %>%
    ggplot2::ggplot() +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      alpha = 0.8,
      position = "stack"
    ) +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "", y = "Number of experimental data files") +
    ggplot2::facet_grid(
      cols = ggplot2::vars(!!!rlang::syms(unlist(facet))),
      scales = "fixed"
    ) +
    ggplot2::theme(
      legend.text = ggplot2::element_blank(),
      axis.text.x = rlang::exec(ggplot2::element_text, !!!x_axis_text),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "right",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    )
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

create_milestone_reporting_plot <- function(
  data,
  facet,
  title = NULL,
  x_axis_text = NULL
  ){
   p <- data %>%
     ggplot2::ggplot() +
     # key is not a known aesthetic for geom_bar, but is needed by plotly
     suppressWarnings(ggplot2::geom_bar(
       ggplot2::aes(
         x = !!rlang::sym("Types of Files"),
         y = !!rlang::sym("Number of Files"),
         fill = !!rlang::sym("Types of Files"),
         key = !!rlang::sym("File ID")
       ),
       stat = "identity",
       alpha = 0.8,
       na.rm = TRUE,
       show.legend = FALSE,
       position = ggplot2::position_dodge()
     )) +
     ggplot2::facet_grid(cols = ggplot2::vars(!!rlang::sym(facet))) +
     ggplot2::ggtitle(title) +
     ggplot2::theme(
       legend.text = ggplot2::element_text(size = 8),
       axis.text.x = rlang::exec(ggplot2::element_text, !!!x_axis_text),
       text = ggplot2::element_text(size = 10),
       strip.text.x = ggplot2::element_text(size = 10),
       legend.position = "right",
       panel.grid.major.y = ggplot2::element_blank(),
       panel.background = ggplot2::element_rect(fill = "grey95")
     )
   if(find_plot_theme()) p <- p + find_plot_theme()()
   return(p)
}

#' Create New Submissions Plot
#'
#' @param data A Tibble
#' @param x A string that is the name of a column in the data
#' @param fill A string that is the name of a column in the data
#' @param y A string that is the name of a column in the data
#' @param y_axis_text A list of parameters to
#' axis.text.y = ggplot2::element_text()
#'
#' @importFrom magrittr %>%
#' @importFrom rlang !!! !!
create_new_submissions_plot <- function(
  data,
  x,
  fill,
  y = "Count",
  y_axis_text = NULL
){

  text2 <- 1:nrow(data)
  p <- data %>%
    ggplot2::ggplot(ggplot2::aes(C = !!rlang::sym(y))) +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = !!rlang::sym(x),
        y = !!rlang::sym(y),
        fill = !!rlang::sym(fill),
        color = !!rlang::sym(fill)
      ),
      stat = "identity",
      position = "stack",
      alpha = 0.8,
      na.rm = TRUE,
      show.legend = FALSE
    ) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "",
      y = "Number of files"
    ) +
    ggplot2::theme(
      legend.text = ggplot2::element_text(size = 8),
      axis.text.x  = ggplot2::element_blank(),
      axis.text.y = rlang::exec(ggplot2::element_text, !!!y_axis_text),
      text = ggplot2::element_text(size = 10),
      strip.text.x = ggplot2::element_text(size = 10),
      legend.position = "right",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "grey95")
    ) +
    ggplot2:: scale_y_continuous(trans = "log10")
  if(find_plot_theme()) p <- p + find_plot_theme()()
  return(p)
}

#' Find Plot Theme
find_plot_theme <- function(){
  theme_set <- all(
    !is.null(.GlobalEnv$THEME),
    is.function(.GlobalEnv$THEME)
  )

  if(theme_set) return(.GlobalEnv$THEME)
  else return(F)
}
