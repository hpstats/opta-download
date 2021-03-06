setwd("C:/Users/Neil/Documents/Stats/Github_repos/opta-download")

update.regions <- "Y"
update.competitions <- "Y"
update.teams <- "Y"
update.matches <- "Y"

library(data.table)
library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(rvest)
library(RSQLite)
library(lubridate)

opta <- src_sqlite("C:/Users/Neil/Documents/Stats/SQL Databases/opta",create = FALSE)

address <- "https://www.whoscored.com"

tries <- 0

while (tries < 5){
  home.html <- try(readLines(address))
  if(class(home.html) == "try-error" | length(home.html) <= 50){
    tries <- tries + 1
    Sys.sleep(5.0)
  } else {
    tries <- 10
  }
}

if (tries == 5){
  error <- address
} else {
  if (update.regions == "Y" || update.competitions == "Y"){
    source("Regions and Tournaments.R")
  } else {
    
  }
}

if (update.matches == "Y"  || update.teams == "Y"){
  source("Matches.R")
} else {
  
}