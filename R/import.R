
importRmd <- function(raw) {
  lines <- strsplit(raw, "\n", fixed = TRUE)[[1]]
  parsed <- parse_rmd(lines)

  list(
    description = "foobar",
    files = mapply(seq_along(parsed), parsed, FUN = function(num, chunk) {

      if (inherits(chunk, "yaml")) {
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
}
