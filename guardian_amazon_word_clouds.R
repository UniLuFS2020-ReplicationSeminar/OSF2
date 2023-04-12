library("wordcloud2")
library("tm")
library("readr")
library("dplyr")

guardian_amazon_title <- guardian_amazon_corpus

guardian_amazon_title <- Corpus(VectorSource(guardian_amazon_title$web_title))

removeHTML <- function(text){
  text = gsub(pattern = '<. +\\">', '', text)
  text = gsub(pattern = '</ .+>', '', text)
  return(text)
}

guardian_amazon_title <- guardian_amazon_title %>%
  tm_map(content_transformer(removeHTML)) %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(removeWords, stopwords("SMART")) %>%
  tm_map(stemDocument)

tdm <- TermDocumentMatrix(guardian_amazon_title) %>%
  as.matrix()

words <- sort(rowSums(tdm), decreasing = TRUE)

df <- data.frame(word = names(words), freq = words)

df <- df %>% 
  filter(nchar(as.character(word)) >2,
         word !="don'")

guardian.amazon.colors <- c("#072964", "#221f1f", "#fffffe")
guardian.amazon.background <- "#ff9900" 
  
library("extrafont")

wordcloud2(df,
           color = rep_len(guardian.amazon.colors, nrow(df)),
           backgroundColor = guardian.amazon.background,
           fontFamily = "DM Sans",
           size = 2.5,
           minSize = 5,
           rotateRatio = 0)


  