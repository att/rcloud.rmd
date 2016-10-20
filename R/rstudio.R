
rstudio_to_rcloud_rmd <- function() {

  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::textInput("url", "RCloud URL"),
      actionButton("exportButton", "Export"),
      actionButton("cancelButton", "Cancel")
    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent(input$exportButton, {

      shiny::stopApp()
    })

    shiny::observeEvent(input$cancelButton, {
      shiny::stopApp()
    })
  }

  ##  viewer <- shiny::dialogViewer("Export to RCloud", 400, 300)
  viewer <- shiny::browserViewer()
  shiny::runGadget(ui, server, viewer = viewer)
}
