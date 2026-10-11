# Data sources

| Input | Source and year | Published use |
| --- | --- | --- |
| `breast_cancer_2022_data.csv` | Supplied USCS export, identified in the original study as CDC U.S. Cancer Statistics; every record has YEAR 2022 | Female, All Races, Female Breast, Incidence; age-adjusted rate per 100,000 |
| `health_insurance_2022_data.xlsx` | U.S. Census Bureau, 2022 ACS, table HI05_ACS; source and year embedded in the workbook | Any insurance and uninsured percentages for all persons aged 19–64 |
| State outlines | R maps package | Approximate contiguous state polygons for visualization; not analytical observations |

Official references: [CDC U.S. Cancer Statistics](https://www.cdc.gov/united-states-cancer-statistics/) and [Census ACS insurance tables](https://www.census.gov/data/tables/time-series/demo/health-insurance/acs-hi.html).

These are aggregate public statistics, not patient records. The supplied cancer export has not been matched byte for byte to an archived download; its exact export date is unknown. The Census workbook identifies its source directly. Source editions can be revised, so the included files define this project's input snapshot.

## Excluded exploratory inputs

The local education and income exports are not used in this published analysis. The column originally labeled bachelor’s education (`S1502_C02_014E`) describes science and engineering degree fields for a subgroup, not the overall share with a bachelor’s degree. Averaging it with the high school percentage would not create a valid combined attainment measure. The year and release edition of the income and bachelor’s exports remain unverified.

The supplied 2018 boundary files have no projection file and are not used by the reproducible pipeline. The original presentation’s claim about women aged 19–64 is not supported by the all-person insurance table or the cancer export's available fields.
