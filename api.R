library(plumber)
library(future)
library(promises)

plan(multicore(workers = 2))

system("Rscript script.R", wait = FALSE)

writeLog = function(level, ...) {
  cat(paste(level, "[", format(Sys.time()), "]", ..., "\n", collapse = ""))
}

FILE <- "./data/model.json"
assign("X", value = 0L, envir = .GlobalEnv)
assign("FREE", value = TRUE, envir = .GlobalEnv)

updateModel <- function() {
  if (file.exists(FILE)) {
    Sys.sleep(5L)
    x <- readLines(FILE)
    file.remove(FILE)
    x <- jsonlite::fromJSON(x)
    writeLog("INFO", "Variable updated")
    return(list(X = x$x, FREE = TRUE))
  }
  list(FREE = TRUE)
}

#* @apiTitle API check
#* @apiDescription API to check the future package

#* Return a global variable
#* @get /api-test/check
function() {
  if (.GlobalEnv$FREE) {
    assign("FREE", value = FALSE, envir = .GlobalEnv)

    promise_model <- future_promise({updateModel()})

    promise_model$then(onFulfilled = function(promise) {
      lapply(names(promise), function(name)
        assign(x = name, value = promise[[name]], envir = .GlobalEnv))
    }, onRejected = function(error) assign("FREE", value = TRUE, envir = .GlobalEnv))
  }

  list(date = Sys.time(), value = sum(.GlobalEnv$X))
}

#* @plumber
function(pr) {
  pr %>%
    pr_set_serializer(serializer_unboxed_json())
}
