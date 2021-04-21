# Milestone Reporting Module UI

#' @title milestone_reporting_module_ui and milestone_reporting_module_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname milestone_reporting_module
#' @export
milestone_reporting_module_ui <- function(id){
  ns <- shiny::NS(id)

  shiny::tagList(
    shinydashboard::box(
      title = "Milestone tracking",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      collapsible = FALSE,
      shiny::p("Plots used for tracking file upload milestones."),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::uiOutput(ns("join_column_choice_ui"))
        )
      ),
      # ----
      shiny::h1("Researcher reported milestone upload"),
      shiny::p(stringr::str_c(
        "Select a milestone from the dropdown below.",
        "All files will be selected with the annotated milestone.",
        sep = " "
      )),
      shiny::fluidRow(
        shiny::column(
          width = 2,
          shiny::uiOutput(ns("milestone_choice_ui"))
        )
      ),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          plotly::plotlyOutput(ns("plot2"))
        )
      ),
      # ----
      shiny::h1("Internal milestone tracking"),
      shiny::p(stringr::str_c(
        "Click on a designated upload date from the table below,",
        "and select a number of days from the slider blow.",
        "All files will be selected in a window of that many days before and after the designated upload date.",
        sep = " "
      )),
      shiny::fluidRow(
        shiny::column(
          width = 2,
          DT::dataTableOutput(ns("dt"))
        ),
        shiny::column(
          width = 4,
          shiny::sliderInput(
            inputId = ns("days_choice"),
            label = "Select Amount of Days",
            step = 1L,
            min = 30L,
            max = 365L,
            value = 60L
          )
        )
      ),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          plotly::plotlyOutput(ns("plot1"))
        )
      )
    )
  )

}

# Milestone Reporting Module Server

#' @title milestone_reporting_module_server and milestone_reporting_module_server_ui
#' @param data A named list. The list must contain a list named "tables".
#' @param config A named list.
#' @rdname milestone_reporting_module
#' @export
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom rlang .data
milestone_reporting_module_server <- function(id, data, config){
  shiny::moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      join_column_choices <- shiny::reactive({
        shiny::req(config())
        choices <- unlist(config()$join_columns)
      })

      output$join_column_choice_ui <- shiny::renderUI({
        shiny::req(join_column_choices())
        shiny::selectInput(
          inputId = ns("join_column_choice"),
          label = "Choose paramater to visualize.",
          choices = join_column_choices()
        )
      })

      files_tbl <- shiny::reactive({
        shiny::req(data(), config())
        shiny::validate(shiny::need(
          !is.null(config()),
          "Not Tracking Milestones"
        ))
        config <- purrr::pluck(config(), "files_table")
        tbl <- purrr::pluck(data(), "tables", config$name)
        format_plot_data_with_config(tbl, config)
      })

      id_tbl <- shiny::reactive({
        shiny::req(data(), config())
        shiny::validate(shiny::need(
          !is.null(config()),
          "Not Tracking Milestones"
        ))
        config <- purrr::pluck(config(), "incoming_data_table")
        tbl <- purrr::pluck(data(), "tables", config$name)
        shiny::validate(shiny::need(
          nrow(tbl) > 0,
          "Study has no current milestones."
        ))
        format_plot_data_with_config(tbl, config)
      })

      # plot1 ----

      dt_tbl <- shiny::reactive({
        shiny::req(id_tbl(), config())
        config <- config()
        create_internal_tracking_datatable(id_tbl(), config())
      })

      output$dt <- DT::renderDataTable(
        base::as.data.frame(dt_tbl()),
        server = TRUE,
        selection = list(mode = 'single', selected = 1),
        rownames = FALSE
      )

      dt_row <- shiny::reactive({
        shiny::req(dt_tbl(), input$dt_rows_selected)
        dplyr::slice(dt_tbl(), input$dt_rows_selected)
      })

      date_range_start <- shiny::reactive({
        shiny::req(input$days_choice, dt_row(), config())
        date_column <- rlang::sym(config()$date_estimate_column)
        date <- dplyr::pull(dt_row(), !!date_column)
        date - lubridate::duration(input$days_choice, 'days')
      })

      date_range_end <- shiny::reactive({
        shiny::req(input$days_choice, dt_row(), config())
        date_column <- rlang::sym(config()$date_estimate_column)
        date <- dplyr::pull(dt_row(), !!date_column)
        date + lubridate::duration(input$days_choice, 'days')
      })

      date_range_string <- shiny::reactive({
        shiny::req(date_range_start(), date_range_end())
        stringr::str_c(
          "You are now viewing files uploaded between ",
          as.character(date_range_start()),
          ", and ",
          as.character(date_range_end()),
          "."
        )
      })

      filtered_id_tbl1 <- shiny::reactive({
        shiny::req(id_tbl(),  config(), dt_row(), input$join_column_choice)
        filter_internal_data_tbl(id_tbl(),config(), dt_row(), input$join_column_choice)
      })

      filtered_files_tbl1 <- shiny::reactive({
        shiny::req(
          files_tbl(),
          config(),
          date_range_start(),
          date_range_end(),
          input$join_column_choice
        )
        filter_files_tbl(
          files_tbl(),
          config(),
          date_range_start(),
          date_range_end(),
          input$join_column_choice
        )
      })

      merged_tbl1 <- shiny::reactive({
        shiny::req(
          filtered_id_tbl1(),
          filtered_files_tbl1(),
          config(),
          input$join_column_choice
        )

        merge_tbls(
          filtered_id_tbl1(),
          filtered_files_tbl1(),
          config(),
          input$join_column_choice
        )
      })

      plot_obj1 <- shiny::reactive({
        shiny::req(merged_tbl1(), config(), input$join_column_choice, date_range_string())
        config <- config()
        join_column <- rlang::sym(input$join_column_choice)

        p <- merged_tbl1() %>%
          ggplot2::ggplot() +
          ggplot2::geom_bar(
            ggplot2::aes(
              x = !!rlang::sym("Types of Files"),
              y = !!rlang::sym("Number of Files"),
              fill = !!rlang::sym("Types of Files")
            ),
            stat = "identity",
            alpha = 0.8,
            na.rm = TRUE,
            show.legend = FALSE,
            position = ggplot2::position_dodge()
          ) +
          sagethemes::theme_sage() +
          ggplot2::facet_grid(cols = ggplot2::vars(!!rlang::sym(join_column))) +
          ggplot2::ggtitle(date_range_string()) +
          ggplot2::theme(
            legend.text = ggplot2::element_text(size = 8),
            axis.text.x  = ggplot2::element_blank(),
            text = ggplot2::element_text(size = 10),
            strip.text.x = ggplot2::element_text(size = 10),
            legend.position = "right",
            panel.grid.major.y = ggplot2::element_blank(),
            panel.background = ggplot2::element_rect(fill = "grey95")
          )
      })

      output$plot1 <- plotly::renderPlotly({
        shiny::req(plot_obj1())

        plotly::ggplotly(plot_obj1()) %>%
          plotly::layout(
            autosize = T
          )
      })

      # plot2 ----

      milestone_choices <- shiny::reactive({
        shiny::req(id_tbl(), config())
        config <- config()
        milestone_column   <- rlang::sym(config$milestone_column)

        id_tbl() %>%
          dplyr::pull(!!milestone_column) %>%
          unique() %>%
          sort()
      })

      output$milestone_choice_ui <- shiny::renderUI({
        shiny::req(milestone_choices())
        shiny::selectInput(
          inputId = ns("milestone_choice"),
          label = "Choose Milestone",
          choices = milestone_choices()
        )
      })

      filtered_files_tbl2 <- shiny::reactive({
        shiny::req(
          files_tbl(),
          input$milestone_choice,
          config(),
          input$join_column_choice
        )
        config <- config()

        join_column <- rlang::sym(input$join_column_choice)
        actual_column <- rlang::sym(config$actual_files_column)
        milestone_column <- rlang::sym(config$milestone_column)

        files_tbl() %>%
          dplyr::filter(!!milestone_column == input$milestone_choice) %>%
          dplyr::group_by(!!join_column) %>%
          dplyr::summarise(!!actual_column := dplyr::n())
      })

      filtered_id_tbl2 <- shiny::reactive({
        shiny::req(
          id_tbl(),
          input$milestone_choice,
          config(),
          input$join_column_choice
        )
        config <- config()
        milestone_column <- rlang::sym(config$milestone_column)
        expected_column  <- rlang::sym(config$expected_files_column)
        join_column      <- rlang::sym(input$join_column_choice)

        id_tbl() %>%
          dplyr::filter(!!milestone_column == input$milestone_choice) %>%
          dplyr::select(
            !!join_column,
            !!milestone_column,
            !!expected_column
          )
      })

      merged_tbl2 <- shiny::reactive({

        shiny::req(
          filtered_id_tbl2(),
          filtered_files_tbl2(),
          config(),
          input$join_column_choice
        )
        config <- config()

        date_column     <- rlang::sym(config$date_created_column)
        actual_column   <- rlang::sym(config$actual_files_column)
        join_column     <- rlang::sym(input$join_column_choice)
        expected_column <- rlang::sym(config$expected_files_column)

        filtered_id_tbl2() %>%
          dplyr::full_join(filtered_files_tbl2(), by = input$join_column_choice) %>%
          dplyr::mutate(
            !!actual_column := dplyr::if_else(
              is.na(!!actual_column),
              0L,
              !!actual_column
            )
          ) %>%
          dplyr::select(!!join_column, !!expected_column, !!actual_column) %>%
          tidyr::pivot_longer(
            cols = -c(!!join_column),
            names_to = "Types of Files",
            values_to = "Number of Files"
          ) %>%
          dplyr::mutate(
            "Types of Files" = base::factor(
              .data$`Types of Files`,
              levels = c(
                config$expected_files_column, config$actual_files_column
              )
            )
          )
      })

      plot_obj2 <- shiny::reactive({
        shiny::req(merged_tbl2(), config(), input$join_column_choice)
        config <- config()
        join_column <- rlang::sym(input$join_column_choice)

        p <- merged_tbl2() %>%
          ggplot2::ggplot() +
          ggplot2::geom_bar(
            ggplot2::aes(
              x = !!rlang::sym("Types of Files"),
              y = !!rlang::sym("Number of Files"),
              fill = !!rlang::sym("Types of Files")
            ),
            stat = "identity",
            alpha = 0.8,
            na.rm = TRUE,
            show.legend = FALSE,
            position = ggplot2::position_dodge()
          ) +
          sagethemes::theme_sage() +
          ggplot2::facet_grid(cols = ggplot2::vars(!!rlang::sym(join_column))) +
          ggplot2::theme(
            legend.text = ggplot2::element_text(size = 8),
            axis.text.x  = ggplot2::element_blank(),
            text = ggplot2::element_text(size = 10),
            strip.text.x = ggplot2::element_text(size = 10),
            legend.position = "right",
            panel.grid.major.y = ggplot2::element_blank(),
            panel.background = ggplot2::element_rect(fill = "grey95")
          )
      })

      output$plot2 <- plotly::renderPlotly({
        shiny::req(plot_obj2())

        plotly::ggplotly(plot_obj2()) %>%
          plotly::layout(
            autosize = T
          )
      })

    }
  )
}
