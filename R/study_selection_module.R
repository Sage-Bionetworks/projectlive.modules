# Study Selection Module UI

#' @title study_selection_module_ui and study_selection_module_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname study_selection_module
study_selection_module_ui <- function(id){
  ns <- shiny::NS(id)

  shiny::tagList(
    shinydashboard::box(
      shiny::uiOutput(ns("filter_ui")),
      DT::dataTableOutput(ns("study_table")),
      title = "Participating Studies",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      collapsible = FALSE
    ),
    shinydashboard::box(
      shinydashboard::infoBoxOutput(ns('study'), width = 12),
      title = "",
      status = "primary",
      solidHeader = F,
      width = 12,
      collapsible = FALSE,
    )
  )

}

# Study Selection Module Server

#' @rdname study_selection_module
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom rlang .data
study_selection_module_server <- function(id, data, config){
  shiny::moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      filter_choices <- shiny::reactive({
        shiny::req(config(), data())
        column <- purrr::pluck(config(), "study_table", "filter_column")

        choices <- data() %>%
          purrr::pluck("tables", "studies") %>%
          dplyr::pull(column) %>%
          unlist(.) %>%
          unique() %>%
          sort() %>%
          c("All", .)
      })

      output$filter_ui <- shiny::renderUI({
        shiny::req(filter_choices())
        shiny::selectInput(
          inputId = ns("filter_value"),
          label   = "Select an initiative",
          choices = filter_choices()
        )
      })

      filtered_table <- shiny::reactive({
        shiny::req(data(), config(), input$filter_value)

        column <- purrr::pluck(config(), "study_table", "filter_column")
        table <- purrr::pluck(data(), "tables", "studies")

        if (input$filter_value != "All"){
          table <- table %>%
            filter_list_column(
              column,
              input$filter_value
            )
        }
        return(table)
      })

      study_table <- shiny::reactive({

        shiny::req(data(), config(), filtered_table())

        config <- purrr::pluck(config(), "study_table")
        config$tables$merged$count_column$count <- F

        files <- summarise_df_counts(
          data = purrr::pluck(data(), "tables", "files"),
          group_column = config$join_column,
          columns = config$tables$files$columns
        )

        tools <- summarise_df_counts(
          data = purrr::pluck(data(), "tables", "tools"),
          group_column = config$join_column,
          columns = config$tables$tools$columns
        )

        filtered_table() %>%
          dplyr::select(dplyr::all_of(
            unlist(config$tables$studies$columns)
          )) %>%
          dplyr::left_join(files, by = config$join_column) %>%
          dplyr::left_join(tools, by = config$join_column) %>%
          format_plot_data_with_config(config$tables$merged)
      })

      output$study_table <- DT::renderDataTable(
        base::as.data.frame(study_table()),
        server = TRUE,
        selection = 'single'
      )

      selected_study_row <- shiny::reactive({
        shiny::req(
          study_table(),
          config(),
          !is.null(input$study_table_rows_selected)
        )

        study_table() %>%
          dplyr::slice(input$study_table_rows_selected)
      })

      selected_study_id <- shiny::reactive({
        shiny::req(
          selected_study_row,
          config()
        )

        column_name <- purrr::pluck(config(), "study_id_column")

        selected_study_row() %>%
          dplyr::pull(column_name)
      })

      selected_study_name <- shiny::reactive({
        shiny::req(
          selected_study_row,
          config()
        )

        column_name <- purrr::pluck(config(), "study_name_column")

        selected_study_row() %>%
          dplyr::pull(column_name)
      })

      output$study <- shinydashboard::renderInfoBox({
        shiny::req(selected_study_name())
        shinydashboard::infoBox(
          "You have selected",
          selected_study_name(),
          icon = shiny::icon("file"),
          color = "light-blue",
          fill = FALSE
        )
      })

      filtered_data <- shiny::reactive({
        shiny::req(config(), data(), selected_study_id())

        column     <- config()$study_table$join_column
        study_id   <- selected_study_id()
        study_name <- selected_study_name()
        data       <- data()


        filtered_tables <- data %>%
          purrr::pluck("tables") %>%
          purrr::map(
            filter_list_column,
            column,
            study_id
          )

        data$tables            <- filtered_tables
        data$selected_study    <- study_name
        data$selected_study_id <- study_id
        return(data)
      })

      return(filtered_data)

    }
  )
}

