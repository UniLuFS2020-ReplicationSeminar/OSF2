# Use LDA to find topics in the Guardian Amazon Corpus

# Following instructions provided by https://tutorials.quanteda.io/machine-learning/topicmodel/

# Setup --------------------------------------------------------------
library(quanteda)
library(seededlda)


# sample
#sample <- sample_n(guardian_amazon_corpus, 100)

# Clean Data --------------------------------------------------------------
sample_toks <- quanteda::tokens(sample$body_text, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
sample_toks <- quanteda::tokens_remove(sample_toks, pattern = stopwords("en"))

dfmat_news <- dfm(sample_toks) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")


tmod_lda <- textmodel_lda(dfmat_news, k = 2)
terms(tmod_lda, 4)


