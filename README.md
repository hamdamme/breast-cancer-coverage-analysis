# Breast Cancer & Insurance Coverage Analysis (2022)

A reproducible R analysis comparing female breast cancer incidence with adult insurance coverage across 50 U.S. states and District of Columbia. It produces validated data, two charts, a descriptive summary, and an interactive map.

## Scope and interpretation

Cancer incidence is the age-adjusted female rate per 100,000. Insurance coverage is for all civilian noninstitutionalized adults aged 19–64, not women only. The populations differ, so this project examines aggregate geographic association rather than incidence among insured versus uninsured women. It does not estimate individual risk or establish causation.

The map shows the contiguous states and District of Columbia. The charts and CSV retain Alaska, Hawaii, and District of Columbia. Education and income extensions are excluded until their provenance and variable definitions are verified.

## Requirements and setup

Use R 4.1 or later. Dependencies: readxl, ggplot2, sf, maps, leaflet, and htmlwidgets. The sf package may require GDAL, GEOS, PROJ, and udunits development libraries on Linux; see the [sf installation guide](https://r-spatial.github.io/sf/#installing).

```sh
git clone https://github.com/hamdamme/breast-cancer-coverage-analysis.git
cd breast-cancer-coverage-analysis
Rscript scripts/install_dependencies.R
Rscript tests/test_data.R
Rscript scripts/run_analysis.R
python3 -m http.server 8000 --directory output
```

Open http://localhost:8000 to view the report and interactive map. Map tiles require internet access. No Pandoc installation is required.

## Architecture

- `R/prepare_data.R` selects the verified 2022 populations, checks the insurance workbook layout, joins by state, and validates completeness, duplicates, numeric ranges, and coverage totals.
- `scripts/run_analysis.R` generates charts, a map, a CSV, and descriptive output.
- `tests/test_data.R` exercises input validation with valid and deliberately invalid data.
- `data_r_code/` contains the two published aggregate source datasets.
- `output/` is generated and ignored by Git. `session-info.txt` records the R and dependency versions used for a run.

The inputs are preserved in their supplied formats to keep the original values inspectable. The workbook layout is checked before numbered columns are read, avoiding silent interpretation of a changed source schema.

## Data and limitations

See [DATA_SOURCES.md](DATA_SOURCES.md) for sources, definitions, and provenance limits. The analysis uses one year, state averages, and an unweighted descriptive correlation. It does not adjust for screening, age distributions beyond the supplied incidence adjustment, socioeconomic factors, or survey uncertainty. The table does not contain cancer rates stratified by insurance status.

GitHub Actions checks script syntax and input validation. The complete chart and map pipeline is verified locally; CI does not render the report.

## Attribution and status

Original study contributors: Lavinia Nedelcu, Hamdam Aynazarov, and Naima Kazi. This repository preserves that attribution. The original presentation and exploratory files remain local; they are not published as verified findings.

See [ROADMAP.md](ROADMAP.md) for verified progress and planned work.
