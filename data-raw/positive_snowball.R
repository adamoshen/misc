library(tibble)
library(dplyr)
library(tidytext)
library(qs)

neg_words <- c("isn't", "aren't", "wasn't", "weren't", "hasn't", "haven't", "hadn't", "doesn't",
               "don't", "didn't", "won't", "wouldn't", "shan't", "shouldn't", "can't", "cannot",
               "couldn't", "mustn't", "against", "no", "nor", "not")

positive_snowball <- tidytext::stop_words %>%
  dplyr::filter(lexicon == "snowball") %>%
  dplyr::filter(!(word %in% neg_words))

qs::qsave(positive_snowball, "./data-raw/positive_snowball.qs")
saveRDS(positive_snowball, "./data-raw/positive_snowball.rds", version=2)
