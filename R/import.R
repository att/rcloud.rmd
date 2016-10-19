
importRmd <- function(raw, filename) {
  lines <- strsplit(raw, "\n", fixed = TRUE)[[1]]
  parsed <- parse_rmd(lines)

  yaml <- NULL
  notebook <- list(
    files = mapply(seq_along(parsed), parsed, FUN = function(num, chunk) {

      if (inherits(chunk, "yaml")) {
        yaml <<- chunk
        structure(
          list(list(content = paste(chunk, collapse = "\n"))),
          names = paste0("part", num, ".md")
        )

      } else if (inherits(chunk, "inline")) {
        structure(
          list(list(content = chunk$text)),
          names = paste0("part", num, ".md")
        )

      } else if (inherits(chunk, "block")) {
        structure(
          list(list(content = paste(chunk$code, collapse = "\n"))),
          names = paste0("part", num, ".R")
        )
      }
    })
  )

  notebook$description <- make_description(yaml, filename)
  notebook
}

make_description <- function(yaml, filename) {

  yaml <- paste(
    grep("^---\\s*$", yaml, invert = TRUE, value = TRUE),
    collapse = "\n"
  )
  yaml <- tryCatch(yaml.load(yaml), error = function(e) NULL)

  from_filename <- file_path_sans_ext(basename(filename))
  from_yaml <- tryCatch(
    yaml$Title %||% yaml$title,
    error = function(e) NULL
  )
  from_yaml %||% from_filename
}
