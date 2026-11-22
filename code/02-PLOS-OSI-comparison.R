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
# Since all PLOS journals are open access, presumably, we can directly compare the two datasets

## Import preprint dataset and filter for just plos data ----
plos_preprint_df <- read_csv("https://raw.githubusercontent.com/nimh-dsst/osm-preprint-2026/refs/heads/develop/results/journals_summary_2024_2025.csv") %>%
  filter(str_detect(str_to_lower(journal), "plos")) %>%
  mutate(pdf_covered_pct = pdf_covered_od / pdf_covered * 100,
         xml_only_pct = xml_only_od / xml_only * 100) %>%
  select(journal, total_articles, open_data_pct, pdf_covered_pct, xml_only_pct) %>%
  arrange(desc(total_articles))


## Wrangle the PLOS OSI dataset ----
## previously we already filtered based on study timeframe; we need to further aggregate data
plos_osi_cleaned <- plos_filtered %>%
  mutate(DOI_simplified = str_remove(DOI, "10.1371/journal."), .before = "Publication_Day") %>%
  separate(col = DOI_simplified, into = c("Journal_Abbr", NA), sep = "\\.") 

table(plos_osi_cleaned$Journal_Abbr)

plos_osi_summary <- plos_osi_cleaned %>%
  group_by(Journal_Abbr) %>%
  mutate(Total_Pub = n()) %>%
  group_by(Journal_Abbr, Total_Pub, Data_Shared) %>%
  summarise(No_Pub = n()) %>%
  ungroup() %>%
  arrange(desc(Total_Pub), desc(Data_Shared)) %>%
  pivot_wider(id_cols = c(Journal_Abbr, Total_Pub), 
              names_from = Data_Shared, names_prefix = "Data_Shared_",
              values_from = "No_Pub") 

## Combine the two datasets ----
plos_comparison <- plos_osi_summary %>%
  select(-Data_Shared_FALSE) %>%
  mutate(Data_Shared_Pct = Data_Shared_TRUE / Total_Pub * 100) %>%
  mutate(Journal = case_when(Journal_Abbr == "pone" ~ "PLoS ONE",
                             Journal_Abbr == "pgph" ~ "PLOS Global Public Health",
                             Journal_Abbr == "pcbi" ~ "PLoS Computational Biology",
                             Journal_Abbr == "pntd" ~ "PLoS neglected tropical diseases",
                             Journal_Abbr == "ppat" ~ "PLoS Pathogens",
                             Journal_Abbr == "pbio" ~ "PLoS Biology",
                             Journal_Abbr == "pgen" ~ "PLoS Genetics",
                             Journal_Abbr == "pdig" ~ "PLOS Digital Health" ,
                             Journal_Abbr == "pmed" ~ "PLoS Medicine"),
         .before = Journal_Abbr) %>%
  filter(!is.na(Journal)) %>%
  left_join(plos_preprint_df, by = join_by(Journal == journal)) %>%
  mutate(No = row_number()) %>%
  select(No, Journal, Journal_Abbr, PLOS_total = Total_Pub, PLOS_pct = Data_Shared_Pct,
         preprint_total = total_articles, preprint_obs_pct = open_data_pct, 
         preprint_pdf_pct = pdf_covered_pct, preprint_xml_pct = xml_only_pct)


## Compare preprint corpus ----
plos_comp_corpus_size <- plos_comparison %>%
  select(No, Journal, Journal_Abbr, PLOS_total, preprint_total) %>%
  pivot_longer(cols = c("PLOS_total", "preprint_total"), names_to = "Data_Source", values_to = "No_Pub") %>%
  mutate(Data_Source = case_when(Data_Source == "PLOS_total" ~ "PLOS OSI",
                                 Data_Source == "preprint_total" ~ "Lawrimore et al"))

ggplot(data = plos_comp_corpus_size) +
  geom_segment(mapping = aes(x = 0, xend = No_Pub, y = Data_Source, yend = Data_Source,
                             color = Data_Source),
               linewidth = 1) +
  geom_point(mapping = aes(x = No_Pub, y = Data_Source, color = Data_Source),
             size = 3.5) +
  facet_wrap(~reorder(Journal_Abbr, No), ncol = 1, strip.position = "right") +
  scale_x_log10() +
  scale_y_discrete(name = NULL) +
  theme_bw() +
  theme(legend.position = "none") +
  labs(title = "Comparison of Lawrimore et al data\nto PLOS OSI dataset",
       subtitle = "Corpus volumne within the timeframe")

ggsave(filename = "comp_plos-corpus-volume.png", path = here("outputs_graphs"),
       width = 4, height = 6, units = "in", dpi = 300, bg = "white")



## Compare Open Data rates ----
plos_comp_open_data <- plos_comparison %>%
  select(-PLOS_total, -preprint_total) %>%
  pivot_longer(cols = -c("No", "Journal", "Journal_Abbr"), 
               names_to = "Group", values_to = "Percentage") %>%
  mutate(Data_Source = case_when(str_detect(Group, "PLOS") ~ "PLOS OSI",
                                 str_detect(Group, "preprint") ~ "Lawrimore et al"),
         Group = factor(Group, levels = c("PLOS_pct", "preprint_obs_pct", "preprint_pdf_pct", "preprint_xml_pct")))

ggplot(data = plos_comp_open_data) +
  geom_segment(mapping = aes(x = 0, xend = Percentage, y = Group, yend = Group,
                             color = Data_Source),
               linewidth = 0.8) +
  geom_point(mapping = aes(x = Percentage, y = Group, color = Data_Source),
             size = 3) +
  facet_wrap(~reorder(Journal_Abbr, No), ncol = 1, strip.position = "right") +
  scale_x_continuous(expand = 0.01, limits = c(0, 102)) +
  scale_y_discrete(limits = rev, name = NULL) +
  theme_bw() +
  theme(legend.position = "none") +
  labs(title = "Comparison of Lawrimore et al data\nto PLOS OSI dataset",
       subtitle = "Data sharing rates within the timeframe")

ggsave(filename = "comp_plos-data-sharing-rates.png", path = here("outputs_graphs"),
       width = 4, height = 10, units = "in", dpi = 300, bg = "white")
