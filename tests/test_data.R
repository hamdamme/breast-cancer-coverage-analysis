args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)][1])
root <- dirname(dirname(normalizePath(script)))
source(file.path(root, "R", "prepare_data.R"))
data <- prepare_data(file.path(root, "data_r_code"))
stopifnot(nrow(data) == 51, data$State[1] == "Alabama")
expect_error <- function(value, pattern) {
  error <- tryCatch({validate_data(value); NULL}, error = identity)
  stopifnot(inherits(error, "error"), grepl(pattern, conditionMessage(error)))
}
expect_error(rbind(data, data[1, ]), "Duplicate")
expect_error(data[-1, ], "Expected 50")
bad <- data; bad$Uninsured_percent[1] <- NA_real_
expect_error(bad, "finite numeric")
bad <- data; bad$Uninsured_percent[1] <- 101
expect_error(bad, "valid range")
bad <- data; bad$Insured_percent[1] <- 0
expect_error(bad, "sum to")
cat("Input checks passed: schema, state coverage, duplicates, missing values, ranges, and totals\n")
