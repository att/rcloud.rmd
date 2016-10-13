
`%:::%` <- function(p, f) do.call(base::`:::`, list(p, f))

drop_nulls <- function(x) {
  x [ ! vapply(x, is.null, TRUE) ]
}
