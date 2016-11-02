
## We use knitr's (internal) parser. IMO the implementation of the
## parser is a mess, it keeps modifying some global state, so it is very
## hard to follow. Which means that it is also hard to reproduce what it
## does. So we just use it. :(

parse_rmd <- function(lines) {

  ## Get the YAML header, split it off
  yaml <- character()
  if (length(lines) >= 2 && grepl("^---\\s*$", lines[1])) {
    ynos <- grep("^---\\s*$", lines)
    if (length(ynos) >= 2) {
      yaml <- lines[1:ynos[2]]
      lines <- lines[-(1:ynos[2])]
    }
  }

  opts_knit$set(out.format = 'markdown')
  ("knitr" %:::% "knit_code")$restore()
  parsed <- ("knitr" %:::% "split_file")(lines, patterns = all_patterns$md)

  res <- c(
    list(structure(class = "yaml", yaml)),
    lapply(parsed, make_chunk_parser())
  )

  drop_nulls(res)
}

make_chunk_parser <- function() {
  current_block <- 0

  function(chunk) {

    if (inherits(chunk, "inline")) {
      if (chunk$input == "") {
        NULL
      } else {
        structure(
          class = "inline",
          list(
            text = chunk$input,
            code = chunk$code,
            code_loc = chunk$location
          )
        )
      }

    } else if (inherits(chunk, "block")) {
      current_block <<- current_block + 1
      code <- ("knitr" %:::% "knit_code")$get(current_block)
      if (identical(code, "") || is.null(code) || length(code) == 0) {
        NULL
      } else {
        structure(
          class = "block",
          list(
            code = code,
            param = chunk$params
          )
        )
      }
    }

  }
}
