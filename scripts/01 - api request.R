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
length <- httr::content(httr::GET(overview_query_url))[["response"]][["total"]]
# For testing the script without straining the API limit
#length = 1000

# Predefine df object
df <- data.frame()

# Loop
for (i in 1:(ceiling(length/50))){
  # Set query parameters
  parameters <- list(q = "amazon",
                     "from-date" = "2000-01-01",
                     "to-date" = "2022-12-31",
                     "show-fields" = "body",
                     "page" = i,
                     "page-size" = 50,
                     "show-blocks" = "body")
  
  # Set request header for API identification
  headers <- c("api-key" = api_key)
  
  # Send GET request to API and retrieve response
  response <- httr::GET(base_url,
                        add_headers(.headers = headers),
                        query=parameters)
  
  # Extract the content of the response 
  content <- content(response, as = "parsed")
  content <- content$response$results
  
  # Matrix for temporary storing of content
  matrix <- matrix(nrow = 50, ncol = 3, byrow = T)
  
  # loop through contents list and storing date, headline, text
  for (j in 1:length(content)) {
    temp_content <- content[[j]]
    matrix[j,] <- c(temp_content$webPublicationDate,
                    temp_content$webTitle,
                    temp_content$fields$body)
  }
  
  # appending data from every new page from response
  df <- rbind(df, matrix)
  
}


