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

lda_corpus_k10 <- textmodel_lda(dfm_corpus, k = 10)

# Save and load corpus_tokens to file to save time
#save(lda_corpus_k10, file = "lda_corpus_k10.RData")
load("lda_corpus_k10.RData")

lda_corpus_k10 <- lda_corpus
terms(lda_corpus_k10, 10)
terms_list <- terms(lda_corpus_k10, 10)

# assign topic as a new document-level variable$
dfm_corpus$topic_k10 <- topics(lda_corpus_k10)

# cross-table of the topic frequency
topic_frequency <- table(dfm_corpus$topic_k10)
topic_frequency <- as.data.frame(topic_frequency)

topic_frequency <- topic_frequency %>% 
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

ggplot(topic_frequency, aes(x = reorder(Var1, Freq), y = Freq)) +
  geom_bar(stat="identity") + 
  xlab(" ") +
  ylab("Number of Articles") +
  theme_minimal() +
  coord_flip()
