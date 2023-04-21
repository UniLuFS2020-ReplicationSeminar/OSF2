library(tidyverse)
library(here)
library(rstudioapi)
library(jsonlite)
library(httr)
library(guardianapi)


# Using guardianapi package -----------------------------------------------------

# Load API key
gu_api_key()

# GET request
api_request <- gu_content(query = "amazon",
                          from_date = "2000-01-01",
                          to_date = "2022-12-31")

# Save data as data frame
df <- api_request %>% select(-tags)
df <- as.data.frame(df)
write.csv(df, here::here("guardian_amazon.csv"))


# Manual GET request using httr package -----------------------------------

# Set API key and base URL
api_key <- rstudioapi::askForPassword()
base_url <- "https://content.guardianapis.com/search"

# Find out length
overview_query_url <- str_c(base_url, "?q=", "amazon",
                            "&show-fields=all",
                            "&from-date=", "2000-01-01",
                            "&to-date=", "2022-12-31",
                            "&page-size=50",
                            "&api-key=", api_key)
length <- as.numeric(httr::content(httr::GET(overview_query_url))[["response"]][["total"]])
# For testing the script without straining the API limit
#length = 200

# Predefine df object
df <- data.frame()

# Loop
for (i in 1:(ceiling(length/50))){
  # Set query parameters
  parameters <- list(q = "amazon",
                     "from-date" = "2000-01-01",
                     "to-date" = "2022-12-31",
                     "show-fields" = "all",
                     "page" = i,
                     "page-size" = 50)
  
  # Set request header for API identification
  headers <- c("api-key" = api_key)
  
  # Send GET request to API and retrieve response
  response <- httr::GET(base_url,
                        add_headers(.headers = headers),
                        query=parameters)
  
  # Extract the content of the response 
  content <- httr::content(response, as = "parsed")
  
  # Matrix for temporary storing of content
  matrix <- matrix(nrow = 50, ncol = 3, byrow = T)
  
  # Store data in Matrix
  for (j in 1:length(content$response$results)) {
    temp_content <- content$response$results[[j]]
    if(is.null(temp_content$fields$body) == T){temp_content$fields$body = 'Empty'}
    matrix[j,] <- c(temp_content$fields$firstPublicationDate,
                    temp_content$fields$headline,
                    temp_content$fields$body)
  }
  
  # Add Matrix to df for every iteration
  df <- rbind(df, matrix)
  
}

colnames(df) <- c("publication date", "headline", "text")
# Save in working directory
write.csv(df, here::here("guardian_amazon_manual.csv"))
