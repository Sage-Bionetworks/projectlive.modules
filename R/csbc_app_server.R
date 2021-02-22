csbc_server <- function(input, output, session) {

  data <- shiny::reactive(csbc_example_data())

  summary_snapshot_module_server(
    id = "summary_snapshot_module",
    data = data,
    config = shiny::reactive(csbc_example_summary_snapshot_config())
  )

  study_summary_module_server(
    id = "study_summary_module",
    data = data,
    config = shiny::reactive(csbc_example_study_summary_config())
  )
}