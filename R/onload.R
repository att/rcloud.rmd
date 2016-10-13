
caps <- NULL

.onLoad <- function(libname, pkgname) {

  path <- system.file(
    package = "rcloud.rmd",
    "javascript",
    "rcloud.rmd.js"
  )

  caps <<- rcloud.install.js.module(
    "rcloud.rmd",
    paste(readLines(path), collapse = '\n')
  )

  ocaps <- list(importRmd = make_oc(importRmd))

  if (!is.null(caps)) caps$init(ocaps)
}

make_oc <- function(x) {
  do.call(base::`:::`, list("rcloud.support", "make.oc"))(x)
}
