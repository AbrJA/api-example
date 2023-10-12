library(RestRserve)

# system("Rscript script.R", wait = FALSE)

writeLog = function(level, ...) {
  cat(paste(level, "[", format(Sys.time()), "]", ..., "\n", collapse = ""))
}

X <- 0L
FILE <- "./data/model.json"

updateVariable <- function() {
  if (file.exists(FILE)) {
    Sys.sleep(5L)
    x <- readLines(FILE)
    x <- jsonlite::fromJSON(x)
    writeLog("INFO", "Variable updated")
    return(x$x)
  }
  invisible(FALSE)
}

app <- Application$new(content_type = "application/json")

Check <- function(.req, .res) {
  updateVariable()
  .res$set_body(
    list(date = Sys.time(), value = X)
  )
}

app$add_get(path = "/api-test/check", FUN = Check)

backend = BackendRserve$new(precompile = TRUE)
backend$start(app, http_port = 8003)
