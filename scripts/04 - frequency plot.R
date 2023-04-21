library("wordcloud2")
library("tm")
library("readr")
library("dplyr")
library("ggplot2")
library("plotly")

# load the data

load("guardian_amazon_corpus.RData")

# duplicate the dataset for the transformation

guardian_amazon_title <- guardian_amazon_corpus

# create corpus object 

guardian_amazon_title <- Corpus(VectorSource(guardian_amazon_title$web_title))

# built function to remove HTML tags from a text 

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
  tm_map(removeWords, stopwords("SMART"))

# create TDM object with word frequencies

tdm <- TermDocumentMatrix(guardian_amazon_title) %>%
  as.matrix()

# create vector of the total frequency of each word

words <- sort(rowSums(tdm), decreasing = TRUE)

# create dataframe with two columns (unique words from guardian_amazon_title corpus 
# and corresponding frequency of each word)

df <- data.frame(word = names(words), freq = words)
df$word_freq <- paste(df$word, df$freq, sep = ": \n")

# remove rows with strings lower as two characters

df <- df %>% 
  filter(nchar(as.character(word)) >2,
         word !="don'")

# create data frame with top 35 words

df_top35 <- head(df, 35)

library("viridis")

# create a radar plot with top 35 words

ggplot(data=df_top35, aes(x=word_freq, y=freq, fill=word_freq))+
   geom_bar(width = 0.75, stat = "identity", colour = "black", size = 0.3)+
  scale_fill_viridis(discrete = TRUE,
                     option = "D")+
  coord_polar(theta = "x")+
  coord_polar(start = 0)+
    ylim(-2000, 2200)+
  ggtitle("Top 35 Words of Guardian Article Titles on Amazon by Frequency")+
  xlab("")+
  ylab("")+
  theme_minimal()+
  theme(legend.position = "none")+
  labs(x = NULL, y = NULL)
