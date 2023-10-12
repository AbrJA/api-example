N <- 1e7
FILE <- "./data/model.json"
FILE_TMP <- "./data/tmp_model.json"
i <- 0
while (i < 3) {
  writeLines(jsonlite::toJSON(list(x = rnorm(N)), auto_unbox = TRUE), FILE_TMP)
  file.rename(FILE_TMP, FILE)
  i <- i + 1
  Sys.sleep(60L)
}
