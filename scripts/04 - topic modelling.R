# Use LDA to find topics in the Guardian Amazon Corpus

# Following instructions provided by https://tutorials.quanteda.io/machine-learning/topicmodel/

# Setup --------------------------------------------------------------
library(quanteda)
library(seededlda)
library(ggplot2)
library(tidyverse)

load("guardian_amazon_corpus.RData")

# Clean Data --------------------------------------------------------------
corpus_tokens <- quanteda::tokens(guardian_amazon_corpus$body_text, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
corpus_tokens <- quanteda::tokens_remove(corpus_tokens, pattern = stopwords("en"))

# Save and load corpus_tokens to file to save time
# save(corpus_tokens, file = "corpus_tokens.RData")
load("corpus_tokens.RData")

dfm_corpus <- dfm(corpus_tokens) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

# Save and load corpus_tokens to file to save time
#save(dfm_corpus, file = "dfm_corpus.RData")
load("dfm_corpus.RData")

lda_corpus <- textmodel_lda(dfm_corpus, k = 10)

# Save and load corpus_tokens to file to save time
#save(lda_corpus, file = "lda_corpus.RData")
load("lda_corpus.RData")

terms_list <- terms(lda_corpus, 10)
terms_list <- as.data.frame(terms_list)
terms_list <- terms_list %>% 
  rename(Publishing = topic1) %>% 
  rename(Football = topic2) %>% 
  rename(Environment = topic3) %>% 
  rename(Travel = topic4) %>% 
  rename("COVID-19" = topic5) %>% 
  rename(Economy = topic6) %>% 
  rename("TV & Films" = topic7) %>% 
  rename(Politics = topic8) %>% 
  rename(Digital = topic9) %>% 
  rename("Amazon Inc." = topic10)

save(terms_list, file = "terms_list.RData") # Save for report

# assign topic as a new document-level variable$
dfm_corpus$topic <- topics(lda_corpus)

# cross-table of the topic frequency
topic_frequency <- table(dfm_corpus$topic)
topic_frequency <- as.data.frame(topic_frequency)

topic_frequency <- topic_frequency %>% 
  mutate(share = Freq / nrow(guardian_amazon_corpus) * 100) %>% 
  mutate(Var1 = case_when(Var1 == "topic1" ~ "Publishing",
                          Var1 == "topic2" ~ "Football",
                          Var1 == "topic3" ~ "Environment",
                          Var1 == "topic4" ~ "Travel",
                          Var1 == "topic5" ~ "COVID-19",
                          Var1 == "topic6" ~ "Economy",
                          Var1 == "topic7" ~ "TV & Films",
                          Var1 == "topic8" ~ "Politics",
                          Var1 == "topic9" ~ "Digital",
                          Var1 == "topic10" ~ "Amazon Inc."))

ggplot(topic_frequency, aes(x = reorder(Var1, share), y = share)) +
  geom_bar(stat="identity") + 
  xlab(" ") +
  ylab("Share of Articles in %") +
  theme_minimal() +
  coord_flip()

ggsave(
  "topic_frequency_bar_plot.png",
  plot = last_plot(),
  path = "output/",
  scale = 3,
  width = 400,
  height = 500,
  units = "px",
  dpi = 300,
)
