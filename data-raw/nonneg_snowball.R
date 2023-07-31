library(tibble)
library(dplyr)
library(tidytext)
library(qs)

neg_words <- c("isn't", "aren't", "wasn't", "weren't", "hasn't", "haven't", "hadn't", "doesn't",
               "don't", "didn't", "won't", "wouldn't", "shan't", "shouldn't", "can't", "cannot",
               "couldn't", "mustn't", "against", "no", "nor", "not")

nonneg_snowball <- tidytext::stop_words %>%
  dplyr::filter(lexicon == "snowball") %>%
  dplyr::select(-lexicon) %>%
  dplyr::filter(!(word %in% neg_words))

qs::qsave(nonneg_snowball, "./data-raw/nonneg_snowball.qs")
saveRDS(nonneg_snowball, "./data-raw/nonneg_snowball.rds", version=2)
