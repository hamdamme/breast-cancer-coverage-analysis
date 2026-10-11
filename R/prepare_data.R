expected_states <- c(state.name, "District of Columbia")

validate_data <- function(data) {
  required <- c("State", "Incidence_per_100k", "Insured_percent", "Uninsured_percent")
  if (!all(required %in% names(data))) stop("Missing required analysis columns")
  if (anyDuplicated(data$State)) stop("Duplicate state rows")
  if (!setequal(data$State, expected_states)) stop("Expected 50 states and District of Columbia")
  rates <- data[required[-1]]
  if (!all(vapply(rates, is.numeric, logical(1))) || any(!is.finite(as.matrix(rates)))) {
    stop("Rates must be finite numeric values")
  }
  if (any(data$Incidence_per_100k < 0) ||
      any(data$Insured_percent < 0 | data$Insured_percent > 100) ||
      any(data$Uninsured_percent < 0 | data$Uninsured_percent > 100)) stop("Rate outside valid range")
  if (any(abs(data$Insured_percent + data$Uninsured_percent - 100) > 0.2)) {
    stop("Insured and uninsured percentages must sum to approximately 100")
  }
  invisible(data)
}

prepare_data <- function(data_dir) {
  cancer <- read.csv(file.path(data_dir, "breast_cancer_2022_data.csv"), check.names = FALSE)
  required <- c("AREA", "YEAR", "SEX", "RACE", "SITE", "EVENT_TYPE", "AGE_ADJUSTED_RATE")
  if (!all(required %in% names(cancer))) stop("Cancer input schema has changed")
  cancer <- cancer[cancer$YEAR == 2022 & cancer$SEX == "Female" &
                     cancer$RACE == "All Races" & cancer$SITE == "Female Breast" &
                     cancer$EVENT_TYPE == "Incidence" & cancer$AREA %in% expected_states, ]
  cancer <- data.frame(State = cancer$AREA, Incidence_per_100k = as.numeric(cancer$AGE_ADJUSTED_RATE))
  if (anyDuplicated(cancer$State)) stop("Duplicate cancer state rows")

  path <- file.path(data_dir, "health_insurance_2022_data.xlsx")
  headers <- readxl::read_excel(path, sheet = "hi05_acs", col_names = FALSE, n_max = 10,
                                .name_repair = "minimal")
  if (!grepl("All Persons: 2022", headers[[1]][2], fixed = TRUE) ||
      headers[[5]][6] != "Any health insurance" || headers[[7]][7] != "Percent" ||
      headers[[53]][6] != "Uninsured" || headers[[55]][8] != "Percent") {
    stop("Insurance input year or column layout has changed")
  }
  insurance <- readxl::read_excel(path, sheet = "hi05_acs", skip = 5, .name_repair = "unique_quiet")
  selected <- !is.na(insurance$Characteristic) & insurance$Characteristic == "19 - 64 years" &
    insurance[["Nation/State"]] %in% expected_states
  insurance <- insurance[selected, ]
  coverage <- data.frame(State = insurance[["Nation/State"]],
                         Insured_percent = as.numeric(insurance[["...7"]]),
                         Uninsured_percent = as.numeric(insurance[["...55"]]))
  if (anyDuplicated(coverage$State)) stop("Duplicate insurance state rows")
  data <- merge(cancer, coverage, by = "State", all = TRUE)
  validate_data(data)
  data[order(data$State), ]
}
