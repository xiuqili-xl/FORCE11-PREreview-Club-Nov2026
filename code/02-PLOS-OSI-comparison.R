# Load libraries ----
library(tidyverse)
library(here)


# Import data ----
# PLOS Open Science Indicators, obtained from https://doi.org/10.6084/m9.figshare.21687686
# Note, based on documentation, only research articles are included (article type was “Research Article”,
# “Meta-Research Article”, or “Pre-Registered Research Article”).
plos_dataset <- read_csv(here("data_PLOS-OSI", "PLOS-Dataset_v11_Jun26.csv"))
comparator_dataset <- read_csv(here("data_PLOS-OSI", "Comparator-Dataset_v11_Jun26.csv"))


# Investigate data ----
glimpse(plos_dataset)                   # 156,170 entries
glimpse(comparator_dataset)             # 31,231 entries

table(plos_dataset$Publication_Year)            # from 2018 to 2025 (~18k to 22k per year)
table(comparator_dataset$Publication_Year)      # mostly from 2018 to 2025 (about 4000 each)


# Wrangle data ----
plos_filtered <- plos_dataset %>%
  mutate(Publication_Date = paste(Publication_Year, Publication_Month, Publication_Month, sep = "-"),
         Publication_Date = ymd(Publication_Date)) %>%
  filter(Publication_Date >= ymd("2024-01-01"), Publication_Date <= ymd("2025-06-25"))

comparator_filtered <- comparator_dataset %>%
  mutate(Publication_Month = if_else(is.na(Publication_Month), 6, Publication_Month),
         Publication_Day = if_else(is.na(Publication_Day), 15, Publication_Day),
         Publication_Date = paste(Publication_Year, Publication_Month, Publication_Month, sep = "-"),
         Publication_Date = ymd(Publication_Date)) %>%
  filter(Publication_Date >= ymd("2024-01-01"), Publication_Date <= ymd("2025-06-25"))

glimpse(plos_filtered)                # 31,374 entries
glimpse(comparator_filtered)          # 6,210 entries


# Analysis: data generation ----
# What happens if we take into account that not all articles generate data
plos_filtered %>%
  count(Data_Generated, Data_Shared, name = "no_pub") %>%
  group_by(Data_Generated) %>%
  mutate(percent = no_pub / sum(no_pub) * 100) %>%
  ungroup()
## 76.4% of PLOS articles that generated data also shared their data,

plos_filtered %>%
  count(Data_Shared, name = "no_pub") %>%
  mutate(percent = no_pub / sum(no_pub) * 100)
## 76.2% of all PLOS articles, whether or not they generated data


comparator_filtered %>%
  count(Data_Generated, Data_Shared, name = "no_pub") %>%
  group_by(Data_Generated) %>%
  mutate(percent = no_pub / sum(no_pub) * 100) %>%
  ungroup()
## 43.8% of the comparator articles that generated data also shared their data

comparator_filtered %>%
  count(Data_Shared, name = "no_pub") %>%
  mutate(percent = no_pub / sum(no_pub) * 100)
## 43.7% of all comparator articles, whether or not they generated data



# Analysis: Lawrimore et al vs PLOS-OSI ----
# Since all PLOS journals are open access, we can directly compare the two datasets





