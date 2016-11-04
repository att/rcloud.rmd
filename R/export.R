
## Create an Rmd and return it as a string, or
## write it to a file (if file is not NULL)

exportRmd <- function(id, version, file = NULL) {

  res <- rcloud.support::rcloud.get.notebook(id, version)

  if (! res$ok) return(NULL)

  cells <- res$content$files
  cells <- cells[grep("^part", names(cells))]
  if (!length(names(cells))) return(NULL)

  cnums <- suppressWarnings(as.integer(
    gsub("^\\D+(\\d+)\\..*", "\\1", names(cells))
  ))
  cells <- cells[match(sort.int(cnums), cnums)]

  tmp <- file
  if (is.null(tmp)) {
    tmp <- tempfile(fileext = ".Rmd")
    on.exit(unlink(tmp), add = TRUE)
  }

  cat("", file = tmp)

  for (cell in cells) {
    if (grepl("^part.*\\.R$", cell$filename)) {
      cat(format_r_cell(cell), file = tmp, append = TRUE)

    } else if (grepl("^part.*\\.md$", cell$filename)) {
      cat(format_md_cell(cell), file = tmp, append = TRUE)

    } else if (grepl("^part.*\\.Rmd$", cell$filename)) {
      cat(format_rmd_cell(cell), file = tmp, append = TRUE)
    }
  }

  if (is.null(file)) {
    list(
      description = res$content$description,
      rmd = readChar(tmp, file.info(tmp)$size)
    )
  } else {
    invisible()
  }
}

format_r_cell <- function(cell) {
  ## Handle ##> headers, these are chunk options
  options <- if (grepl("^##>", cell$content)) {
    split <- strsplit(cell$content, "\n")[[1]]
    line <- split[1]
    cell$content <- paste(split[-1], collapse = "\n")
    paste0(" ", sub("^##>\\s*", "", line))
  }

  paste0("```{r", options, "}\n", cell$content, "\n```\n")
}

format_md_cell <- function(cell) {
  paste0(cell$content, "\n")
}

format_rmd_cell <- function(cell) {
  paste0(cell$content, "\n")
}
