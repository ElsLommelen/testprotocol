# bundled checks for protocols
library(protocolhelper)
check_all <- function(protocol_code) {
  test1 <-
    tryCatch(
      protocolhelper::check_frontmatter(protocol_code),
      error = function(e) e
    )
  test2 <-
    tryCatch(
      protocolhelper::check_structure(protocol_code),
      error = function(e) e
    )
  fail <-
    (is.list(test1) && test1$message == "error") |
      (is.list(test2) && test2$message == "error")
  if (fail) {
    stop("\nThe source code failed some checks. Please check the error message above.\n")
  }
}
check_all(Sys.getenv("GITHUB_HEAD_REF"))  
