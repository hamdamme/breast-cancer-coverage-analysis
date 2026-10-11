args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)][1])
root <- dirname(dirname(normalizePath(script)))
source(file.path(root, "R", "prepare_data.R"))
packages <- c("readxl", "ggplot2", "sf", "maps", "leaflet", "htmlwidgets")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop(paste("Install missing packages:", paste(missing, collapse = ", ")))
output <- file.path(root, "output")
dir.create(output, showWarnings = FALSE)
data <- prepare_data(file.path(root, "data_r_code"))
write.csv(data, file.path(output, "state_metrics.csv"), row.names = FALSE)

library(ggplot2)
scatter <- ggplot(data, aes(Uninsured_percent, Incidence_per_100k)) +
  geom_point(color = "#376757", size = 2.5) +
  labs(title = "Breast cancer incidence and adult insurance coverage (2022)",
       subtitle = "Each point represents one state or District of Columbia",
       x = "Uninsured adults aged 19–64 (%)", y = "Female breast cancer incidence per 100,000",
       caption = "Different populations; aggregate association does not establish causation.") +
  theme_minimal(base_size = 12)
ggsave(file.path(output, "coverage_scatter.png"), scatter, width = 9, height = 6, dpi = 150, bg = "white")
ranking <- ggplot(data, aes(Incidence_per_100k, reorder(State, Incidence_per_100k))) +
  geom_col(fill = "#376757") +
  labs(title = "Female breast cancer incidence by state (2022)",
       x = "Age-adjusted incidence per 100,000", y = NULL) + theme_minimal(base_size = 10)
ggsave(file.path(output, "state_incidence.png"), ranking, width = 8, height = 12, dpi = 150, bg = "white")

# Approximate map outlines cover the contiguous states. All 51 jurisdictions remain in the table.
geometry <- sf::st_as_sf(maps::map("state", fill = TRUE, plot = FALSE))
geometry <- sf::st_transform(geometry, 4326)
geometry$State <- expected_states[match(geometry$ID, tolower(expected_states))]
index <- match(geometry$State, data$State)
geometry$Incidence_per_100k <- data$Incidence_per_100k[index]
geometry$Uninsured_percent <- data$Uninsured_percent[index]
if (anyNA(geometry$Incidence_per_100k)) stop("Map join contains unmatched states")
palette <- leaflet::colorNumeric("YlGnBu", domain = data$Incidence_per_100k)
labels <- sprintf("%s | Female incidence: %.1f per 100,000 | Uninsured adults 19–64: %.1f%%",
                  geometry$State, geometry$Incidence_per_100k, geometry$Uninsured_percent)
map <- leaflet::leaflet(geometry) |>
  leaflet::addTiles() |>
  leaflet::addPolygons(fillColor = ~palette(Incidence_per_100k), fillOpacity = 0.8,
                       color = "white", weight = 1, label = labels) |>
  leaflet::addLegend(pal = palette, values = data$Incidence_per_100k,
                     title = "Female incidence per 100,000") |>
  leaflet::setView(lng = -96, lat = 38, zoom = 4)
htmlwidgets::saveWidget(map, file.path(output, "map.html"), selfcontained = FALSE)
correlation <- cor(data$Incidence_per_100k, data$Uninsured_percent)
writeLines(sprintf("2022 aggregate state analysis\nJurisdictions: %d\nPearson correlation: %.4f\nUnweighted descriptive association; not causal and not an individual risk estimate.",
                   nrow(data), correlation), file.path(output, "summary.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
writeLines(c('<!doctype html><html lang="en"><meta charset="utf-8">',
 '<meta name="viewport" content="width=device-width, initial-scale=1">',
 '<title>Breast Cancer &amp; Insurance Coverage Analysis (2022)</title>',
 '<style>body{max-width:1100px;margin:40px auto;padding:0 24px;font:17px/1.6 system-ui;color:#243d36;background:#f7f5ef}iframe{width:100%;height:540px;border:1px solid #ccd7ce}img{max-width:100%;height:auto}a{color:#376757}</style>',
 '<h1>Breast Cancer &amp; Insurance Coverage Analysis (2022)</h1>',
 '<p>Female breast cancer incidence compared with insurance coverage for all adults aged 19–64. These are different populations. State averages do not establish individual risk or causation.</p>',
 '<h2>Interactive state map</h2><p>The map covers the contiguous states and District of Columbia. Alaska and Hawaii are included in the downloadable table.</p>',
 '<iframe title="State incidence and adult insurance coverage" src="map.html"></iframe>',
 '<h2>Coverage and incidence</h2><img src="coverage_scatter.png" alt="Scatter plot comparing state female incidence with adult uninsured percentage">',
 '<h2>Incidence by state</h2><img src="state_incidence.png" alt="Bar chart of incidence across 50 states and District of Columbia">',
 '<p><a href="state_metrics.csv">Download state metrics</a> · <a href="summary.txt">Descriptive summary</a></p>',
 '<p>Original study: Lavinia Nedelcu, Hamdam Aynazarov, and Naima Kazi. See repository documentation for data sources and methodology.</p></html>'), file.path(output, "index.html"))
cat("Analysis complete:", nrow(data), "jurisdictions; outputs written to output/\n")
