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
# For testing the script without strining the API limit
#length = 1000

# Predefine df object
df <- data.frame()



