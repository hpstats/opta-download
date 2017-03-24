library(data.table)
library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(rvest)
library(RSQLite)
library(lubridate)

opta <- src_sqlite("C:/Users/Neil/Documents/Stats/SQL Databases/opta",create = FALSE)

RegionLookup <- tbl(opta, 'RegionLookup')
CompetitionLookup <- tbl(opta, 'CompetitionLookup')

region <- filter(RegionLookup, substr(RegionName,1,1) == 'E')
region.comps <- left_join(region, CompetitionLookup, by = "RegionID")
region.comps
