# Load libraries ----
library(tidyverse)
library(here)
library(scales)      # label_wrap
library(ggpubr)
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


## Reproduce Figure 1 ----
figure1_data <- funder_summary %>%
  filter(total_articles >= 2694, aggregated_works_count > 100000) %>% 
  arrange(desc(open_data_pct)) %>%
  filter(row_number() <= 20)

figure1a <- ggplot(data = figure1_data,
                   mapping = aes(y = reorder(funder_name, open_data_pct))) +
  geom_col(mapping = aes(x = open_data_pct, fill = total_articles), width = 0.8) +
  geom_text(mapping = aes(x = open_data_pct + 4, label = paste0(open_data_pct, "%")),
            size = 3) +
  scale_x_continuous(limits = c(0, 32)) +
  scale_y_discrete(labels = label_wrap(35), name = NULL) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, transform = "log10") +
  theme_bw()

figure1b <- ggplot(data = figure1_data,
                   mapping = aes(y = reorder(funder_name, corrected_pct))) +
  geom_col(mapping = aes(x = corrected_pct, fill = total_articles), width = 0.8) +
  geom_errorbar(mapping = aes(xmin = ci_lo_pct, xmax = ci_hi_pct), width = 0.2) +
  geom_text(mapping = aes(x = ci_hi_pct + 4, label = paste0(corrected_pct, "%")),
            size = 3) +
  scale_x_continuous(limits = c(0, 32)) +
  scale_y_discrete(labels = label_wrap(35), name = NULL) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, transform = "log10") +
  theme_bw()

ggarrange(figure1a, figure1b,
          ncol = 2, nrow = 1, 
          common.legend = TRUE, legend = "right") %>%
  annotate_figure(top = text_grob("Reproduction of Table 1 from summary statistics\n(Larimore et al bioRxiv 2026)", 
                                  size = 14))

ggsave(filename = "figure1_reproduction.png", path = here("outputs_graphs"),
       width = 10, height = 6, units = "in", dpi = 300, bg = "white")



## Reproduce Table 1 ----
table1 <- funder_summary %>%
  filter(total_articles >= 1709, aggregated_works_count > 50000) %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct, corrected_pct) %>%
  arrange(desc(open_data_pct))

write_csv(table1, here("outputs_tables", "rep_table1.csv"))

table1_md <- kable(table1, format = "markdown")
writeLines(table1_md, here("outputs_tables", "rep_table1.md"))



## US ----
funder_us_by_pct <- funder_summary %>%
  filter(country == "USA") %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct, aggregated_works_count) %>%
  arrange(desc(open_data_pct)) %>%
  mutate(no = row_number(), .before = funder_name)

write_csv(funder_us_by_pct, here("outputs_tables", "exp_us_by_pct_open_data.csv"))

funder_us_by_pct_md <- kable(funder_us_by_pct, format = "markdown")
writeLines(funder_us_by_pct_md, here("outputs_tables", "exp_us_by_pct_open_data.md"))


## China ----
funder_china_by_pct <- funder_summary %>%
  filter(country == "China") %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct, aggregated_works_count) %>%
  arrange(desc(open_data_pct)) %>%
  mutate(no = row_number(), .before = funder_name)

write_csv(funder_us_by_pct, here("outputs_tables", "exp_china_by_pct_open_data.csv"))

funder_china_by_pct_md <- kable(funder_china_by_pct, format = "markdown")
writeLines(funder_china_by_pct_md, here("outputs_tables", "exp_china_by_pct_open_data.md"))


## restrict to the ones shown in Table 1
funder_summary %>%
  filter(country == "China", 
         total_articles >= 1709, aggregated_works_count > 50000) %>%
  select(funder_name, country, total_articles, open_data_articles, open_data_pct) %>%
  arrange(desc(open_data_pct))



# Explore journal dataset ----
glimpse(journal_summary)           # 1,388 journals


## Reproduce Figure 2 ----
figure2_data <- journal_summary %>%
  filter(total_articles >= 4262) %>% 
  arrange(desc(open_data_pct)) %>%
  filter(row_number() <= 20)

figure2a <- ggplot(data = figure2_data,
       mapping = aes(y = reorder(journal, open_data_pct))) +
  geom_col(mapping = aes(x = open_data_pct, fill = total_articles), width = 0.8) +
  geom_text(mapping = aes(x = open_data_pct + 5, label = paste0(open_data_pct, "%")),
            size = 3) +
  scale_x_continuous(limits = c(0, 65)) +
  scale_y_discrete(labels = label_wrap(30), name = NULL) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, transform = "log10") +
  theme_bw()

figure2b <- ggplot(data = figure2_data,
       mapping = aes(y = reorder(journal, corrected_pct))) +
  geom_col(mapping = aes(x = corrected_pct, fill = total_articles), width = 0.8) +
  geom_errorbar(mapping = aes(xmin = ci_lo_pct, xmax = ci_hi_pct), width = 0.2) +
  geom_text(mapping = aes(x = ci_hi_pct + 6, label = paste0(corrected_pct, "%")),
            size = 3) +
  scale_x_continuous(limits = c(0, 65)) +
  scale_y_discrete(labels = label_wrap(30), name = NULL) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, transform = "log10") +
  theme_bw()

ggarrange(figure2a, figure2b,
          ncol = 2, nrow = 1, 
          common.legend = TRUE, legend = "right") %>%
  annotate_figure(top = text_grob("Reproduction of Table 2 from summary statistics\n(Larimore et al bioRxiv 2026)", 
                                  size = 14))

ggsave(filename = "figure2_reproduction.png", path = here("outputs_graphs"),
       width = 10, height = 6, units = "in", dpi = 300, bg = "white")


## Explore Figure 2 as a lollipop graph ----
ggplot(data = figure2_data,
       mapping = aes(y = reorder(journal, open_data_pct))) +
  geom_segment(mapping = aes(x = 0, xend = open_data_pct,
                             yend = reorder(journal, open_data_pct))) +
  geom_point(mapping = aes(x = open_data_pct, size = total_articles),
             color = "darkblue") +
  scale_x_continuous(limits = c(0, 65)) +
  scale_y_discrete(labels = label_wrap(30), name = NULL) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, transform = "log10") +
  theme_bw() +
  labs(title = "Explore lollipop graph for Figure 2",
       subtitle = "(Larimore et al bioRxiv 2026)")

ggsave(filename = "figure2_lollipop-graph.png", path = here("outputs_graphs"),
       width = 6, height = 6, units = "in", dpi = 300, bg = "white")


## Reproduce Table 2 ----
table2 <- journal_summary %>%
  filter(total_articles >= 1815) %>%
  arrange(desc(open_data_pct)) %>%
  select(journal, total_articles, open_data_articles, open_data_pct, corrected_pct)

write_csv(table2, here("outputs_tables", "rep_table1.csv"))

table2_md <- kable(table2, format = "markdown")
writeLines(table2_md, here("outputs_tables", "rep_table1.md"))


## Total ranking ----
journal_summary %>%
  arrange(desc(open_data_pct)) %>%
  mutate(no = row_number()) %>%
  select(no, journal, total_articles, open_data_pct, corrected_od) %>%
  view()


## PLOS journals ----
## look for plos journals in the dataset, in preparation for comparison with PLOS OSI
plos_article_count <- journal_summary %>%
  filter(str_detect(str_to_lower(journal), "plos")) %>%
  select(journal, total_articles, pdf_covered, xml_only) %>%
  mutate(pdf_coverage = pdf_covered / total_articles * 100, 
         total_count_match = (total_articles == pdf_covered + xml_only))

write_csv(plos_article_count, here("outputs_tables", "exp_plos_count_in_corpus.csv"))

plos_article_count_md <- kable(plos_article_count, format = "markdown")
writeLines(plos_article_count_md, here("outputs_tables", "exp_plos_count_in_corpus.md"))

## pdf coverage for PLOS family of journals range between 35% - 50%, 
## which seems pretty low considering the entire family of journals is digital only..



