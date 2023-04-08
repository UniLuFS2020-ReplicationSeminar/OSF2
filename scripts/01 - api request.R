library(tidyverse)
library(httr)
library(guardianapi)
library(here)

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

# Set API key and endpoint URL
api_key <- rstudioapi::askForPassword()
endpoint <- "https://content.guardianapis.com/search"

# Set query parameters
parameters <- list(q = "amazon",
                   from_date = "2000-01-01",
                   to_date = "2022-12-31",
                   page_size = 5000)

# Send GET request to API and retrieve response
response <- GET(endpoint, query = c(parameters, list(apiKey = api_key)))

# Extract data from response
data <- content(response, "parsed")
articles <- data$response$results

