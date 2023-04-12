library("wordcloud2")
library("tm")
library("readr")
library("dplyr")

# load the data

load("guardian_amazon_corpus.RData")

# duplicate the dataset for the transformation

guardian_amazon_title <- guardian_amazon_corpus

# create a corpus object 

guardian_amazon_title <- Corpus(VectorSource(guardian_amazon_title$web_title))

# built a function to remove HTML tags from a text 

removeHTML <- function(text){
  text = gsub(pattern = '<. +\\">', '', text)
  text = gsub(pattern = '</ .+>', '', text)
  return(text)
}

# use tm package:
# to to remove any HTML tags
# to remove any numbers from the text
# to remove any punctuation marks from the text
# to remove any leading or trailing whitespace from the text
# to convert all text to lowercase
# to remove common English stopwords
# to remove additional stopwords
# to reduce words to their root form

guardian_amazon_title <- guardian_amazon_title %>% 
  tm_map(content_transformer(removeHTML)) %>% 
  tm_map(removeNumbers) %>% 
  tm_map(removePunctuation) %>% #
  tm_map(stripWhitespace) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(removeWords, stopwords("SMART")) %>%
  tm_map(stemDocument)

# create a TDM object with word frequencies

tdm <- TermDocumentMatrix(guardian_amazon_title) %>%
  as.matrix()

# create a vector of the total frequency of each word

words <- sort(rowSums(tdm), decreasing = TRUE)

# create a dataframe with two columns (unique words from guardian_amazon_title corpus 
# and corresponding frequency of each word)

df <- data.frame(word = names(words), freq = words)

# remove rows with strings lower as two characters

df <- df %>% 
  filter(nchar(as.character(word)) >2,
         word !="don'")

# select colors from guardian and amazon logos

guardian.amazon.colors <- c("#072964", "#221f1f", "#fffffe")
guardian.amazon.background <- "#ff9900" 
  
library("extrafont")

# design the word cloud

wordcloud2(df,
           color = rep_len(guardian.amazon.colors, nrow(df)),
           backgroundColor = guardian.amazon.background,
           fontFamily = "DM Sans",
           size = 2.5,
           minSize = 5,
           rotateRatio = 0)


  