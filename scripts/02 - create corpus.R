# Create corpus of Guardian articles on the company Amazon

# Setup --------------------------------------------------------------

library("spacyr")
spacy_initialize(python_executable = "/Users/aiolf1/opt/miniconda3/bin/python",
                 model = "en_core_web_sm")


# Clean Data --------------------------------------------------------------

# Load data
df <- read.csv("guardian_amazon.csv")

# Create corpus dataframe
guardian_amazon_corpus <- df

# Remove rows that are not articles
guardian_amazon_corpus$wordcount <- as.numeric(guardian_amazon_corpus$wordcount)
guardian_amazon_corpus <- guardian_amazon_corpus %>% 
  filter(wordcount > 20)


# Create Corpus --------------------------------------------------------------

# Only include articles that reference Amazon as a company by using Named Entity Recognition by spacy

org_entity <- c("ORG_I", "ORG_B", "ORG_O") # spacyr entity ORG: Companies, agencies, institutions, etc.
dataframes_list <- list() # Create empty list to add dataframes to

# Use spacy to tag text
for (row in 1:nrow(guardian_amazon_corpus)) {
  parsedtxt_temp <- spacy_parse(guardian_amazon_corpus$body_text[row]) # Tag text
  parsedtxt_temp <- parsedtxt_temp %>% filter(token == "Amazon") # Only keep row with "Amazon" as a token, keeping things efficient
  parsedtxt_temp <- parsedtxt_temp %>% filter(entity %in% org_entity) # Only keep entities that are companies
  
  if (nrow(parsedtxt_temp) > 0) { # Check if there are any rows left after filtering
    parsedtxt_temp$doc_id <- guardian_amazon_corpus$X[row] # Keep track of text IDs
    dataframes_list[[row]] <- parsedtxt_temp # Append to list for rbind further below
  }
  print(row) # Keep track of progress
}

# Merge all dataframes together
guardian_amazon_tagged <- do.call(rbind, dataframes_list)

# Only keep articles that refer to Amazon as a company
guardian_amazon_corpus <- guardian_amazon_corpus %>% 
  filter(X %in% guardian_amazon_tagged$doc_id)

# Save corpus to file
save(guardian_amazon_corpus, file = "guardian_amazon_corpus.RData")