
rstudio_to_rcloud_rmd <- function() {

  if (! check_opened_file()) return(invisible())
  if (! check_required_packages()) return(invisible())

  edit_ctx <- rstudioapi::getSourceEditorContext()
  text <- paste(edit_ctx$contents, collapse = "\n")
  filename <- file_path_sans_ext(basename(
    edit_ctx$path %||% NA_character_
  ))

  ## Copy over files to temp dir
  tmp <- tempfile()
  dir.create(tmp)
  file.copy(
    system.file("addin", package = "rcloud.rmd"),
    tmp,
    recursive = TRUE
  )

  ## Fill the templates
  data <- list(
    notebook = as.character(toJSON(rmdToJson(text, filename))),
    urls = rcloud_urls()
  )
  template(file.path(tmp, "addin", "addin_files", "submit.js"), data)
  template(file.path(tmp, "addin", "addin.html"), data)

  html <- paste0("file://", tmp, "/addin/addin.html")
  browseURL(html)
}

toJSON <- function(x) {
  x <- I(x)

  jsonlite::toJSON(
    x, dataframe = "columns", null = "null", na = "null",
    auto_unbox = TRUE, digits = 16, use_signif = TRUE,
    force = TRUE, POSIXt = "ISO8601", UTC = TRUE, rownames = FALSE,
    keep_vec_names = TRUE, json_verbatim = TRUE
  )
}

rcloud_urls <- function() {
  urls <- c("https://rcloud.social", "http://127.0.0.1:8080")
  paste0("<option value=\"", urls, "\">", urls, "</option>", collapse = "\n")
}

template <- function(file, data) {
  lines <- readLines(file)
  filled <- whisker::whisker.render(lines, data = data)
  writeLines(filled, file)
}

check_opened_file <- function() {
  tryCatch(
    { rstudioapi::getSourceEditorContext(); TRUE },
    error = function(e) {
      message("No Rmd file is open for RCloud export.")
      FALSE
    }
  )
}

check_required_packages <- function() {
  check_installed_package("jsonlite") &&
    check_installed_package("rstudioapi") &&
    check_installed_package("whisker")
}

check_installed_package <- function(pkg) {
  if (! requireNamespace(pkg, quietly = TRUE)) {
    message("Package needed for Rmd export, but not installed: ", pkg)
    FALSE
  } else {
    TRUE
  }
}
