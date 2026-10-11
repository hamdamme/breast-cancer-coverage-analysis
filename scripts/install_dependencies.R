packages <- c("readxl", "ggplot2", "sf", "maps", "leaflet", "htmlwidgets")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
