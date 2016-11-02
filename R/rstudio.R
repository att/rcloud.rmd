
rstudio_to_rcloud_rmd <- function() {

  rc_urls <- cached_rc_urls()

  ui <- miniUI::miniPage(
    add_resource_path(),
    miniUI::miniContentPanel(
      shiny::plotOutput("logo", height = "200px"),
      shiny::selectInput("oldurl", "Recently used RCloud URLs", rc_urls),
      shiny::textInput("newurl", "New RCloud URL"),
      shiny::actionButton("exportButton", "Export"),
      shiny::actionButton("cancelButton", "Cancel")
    )
  )

  server <- function(input, output, session) {

    output$logo <- renderImage({

      fn <- system.file(package = "rcloud.rmd", "shiny", "RCloud.svg")
      list(src = fn, alt = "RCloud -- Import Rmarkdown file")

    }, deleteFile = FALSE)

    shiny::observeEvent(input$exportButton, {

      ## Get the text of the currently edited document
      edit_ctx <- rstudioapi::getSourceEditorContext()
      text <- paste(edit_ctx$contents, collapse = "\n")
      filename <- file_path_sans_ext(basename(
        edit_ctx$path %||% NA_character_
      ))

      oldurl <- input$oldurl
      newurl <- input$newurl

      if (nzchar(newurl) && !is.na(newurl)) add_to_rc_urls(newurl)

      session$sendCustomMessage(
        type = "rcloudexport",
        message = list(
          url = if (nzchar(newurl) && !is.na(newurl)) newurl else oldurl,
          notebook = rmdToJson(text, filename)
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

rcloud_social_url <- "https://rcloud.social"

cached_rc_urls <- function() {
  rcfile <- rc_cache_file()
  tryCatch(
    {
      if (file.exists(rcfile)) {
        c(readLines(rcfile), rcloud_social_url)
      } else {
        rcloud_social_url
      }
    },
    error = function(e) {
      warning(e)
      rcloud_social_url
    }
  )
}

add_to_rc_urls <- function(entry) {
  rcfile <- rc_cache_file()
  try(
    dir.create(dirname(rcfile), recursive = TRUE),
    silent = TRUE
  )
  try(
    cat(entry, "\n", sep = "", file = rcfile, append = TRUE),
    silent = TRUE
  )
}

rc_cache_file <- function() {
  file.path(
    user_data_dir("rcloud.rmd", "rcloud.rmd"),
    "rcloud-url-cache.txt"
  )
}
