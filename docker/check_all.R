# bundled checks for protocols
library(protocolhelper)
check_all <- function(protocol_code) {
  check_fm <-
    tryCatch(
      protocolhelper::check_frontmatter(protocol_code),
      error = function(e) e
    )
  check_str <-
    tryCatch(
      protocolhelper::check_structure(protocol_code),
      error = function(e) e
    )
  if (inherits(check_fm, "error") | inherits(check_str, "error")) {
    stop(
      sprintf(
        "One or more errors occurred in either check_frontmatter or
        check_structure: %s \n",
        c(check_fm$message, check_str$message)
      )
    )
  }
}
check_all(Sys.getenv("GITHUB_HEAD_REF"))  
