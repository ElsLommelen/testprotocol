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
  if (inherits(check_fm, "error") ) {
    stop(sprintf("One or more errors occurred in check_frontmatter: %s \n",
                    check_fm$message))
  }
  if (inherits(check_str, "error")) {
    stop(sprintf("One or more errors occurred in check_frontmatter: %s \n",
            check_str$message))
  }
}
check_all(Sys.getenv("GITHUB_HEAD_REF"))  
