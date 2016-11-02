
rstudio_to_rcloud_rmd <- function() {

  ui <- miniUI::miniPage(
    add_resource_path(),
    miniUI::miniContentPanel(
      shiny::textInput("url", "RCloud URL"),
      shiny::actionButton("exportButton", "Export"),
      shiny::actionButton("cancelButton", "Cancel")
    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent(input$exportButton, {

      ## Get the text of the currently edited document
      edit_ctx <- rstudioapi::getSourceEditorContext()
      text <- paste(edit_ctx$contents, collapse = "\n")
      filename <- file_path_sans_ext(basename(
        edit_ctx$path %||% NA_character_
      ))

      session$sendCustomMessage(
        type = "rcloudexport",
        message = list(
          text = text,
          filename = filename
        )
      )

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

add_resource_path <- function() {
  shiny::addResourcePath(
    "rcloudexport",
    system.file("shiny", package = "rcloud.rmd")
  )

  shiny::tags$head(shiny::tags$script(
    src = "rcloudexport/messagehandler.js"
  ))
}
