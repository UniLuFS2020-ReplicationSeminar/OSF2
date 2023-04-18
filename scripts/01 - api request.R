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

# Set query parameters
parameters <- list("amazon",
                   "from-date" = "2000-01-01",
                   "to-date" = "2022-12-31")

# Define search query URL
search_query_url <- str_c("https://content.guardianapis.com/search?q=amazon&show-fields=all&from-date=2000-01-01&to-date=2022-12-31&page-size=50&api-key=", api_key)

# Send GET request to API and retrieve response
response <- httr::GET(search_query_url)

# Extract data from response and parse JSON
json <- jsonlite::fromJSON(httr::content(response, as = "text"))

# Create dataframe


