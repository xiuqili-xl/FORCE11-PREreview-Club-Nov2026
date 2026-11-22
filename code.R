# Load libraries ----
library(tidyverse)
library(here)
library(knitr)       # for exporting tables are markdowns


# Import data ----
# directly from https://github.com/nimh-dsst/osm-preprint-2026
funder_summary <- read_csv("https://raw.githubusercontent.com/nimh-dsst/osm-preprint-2026/refs/heads/develop/results/funders_summary_2024_2025.csv")
journal_summary <- read_csv("https://raw.githubusercontent.com/nimh-dsst/osm-preprint-2026/refs/heads/develop/results/journals_summary_2024_2025.csv")
# we'll start with these two, bc they appeart to be the ones used for the dashboard
# dashboard data folder: https://github.com/nimh-dsst/osm-dashboard/tree/main/dashboard/data


# Explore funder data ----
glimpse(funder_summary)       # 1,833 funders

table(funder_summary$country)
# Canada: 55. China 366, UK: 102, USA: 309, and many more

table(funder_summary$funder_type)
# includes: government (84), philanthropy (9), supranational (2); 
# but also a lot of NA (e.g., universities)


## US ----
funder_us_by_pct <- funder_summary %>%
  filter(country == "USA") %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct) %>%
  arrange(desc(open_data_pct))

write_csv(funder_us_by_pct, here("outputs_tables", "funder_us_by_pct_open_data.csv"))

funder_us_by_pct_md <- kable(funder_us_by_pct, format = "markdown")
writeLines(funder_us_by_pct_md, here("outputs_tables", "funder_us_by_pct_open_data.md"))


## restrict to the ones shown in Table 1
funder_summary %>%
  filter(country == "USA", 
         total_articles >= 1709, aggregated_works_count > 50000) %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct) %>%
  arrange(desc(open_data_pct))


## China ----
funder_china_by_pct <- funder_summary %>%
  filter(country == "China") %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct) %>%
  arrange(desc(open_data_pct))

write_csv(funder_us_by_pct, here("outputs_tables", "funder_china_by_pct_open_data.csv"))

funder_china_by_pct_md <- kable(funder_china_by_pct, format = "markdown")
writeLines(funder_china_by_pct_md, here("outputs_tables", "funder_china_by_pct_open_data.md"))


## restrict to the ones shown in Table 1
funder_summary %>%
  filter(country == "China", 
         total_articles >= 1709, aggregated_works_count > 50000) %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct) %>%
  arrange(desc(open_data_pct))

