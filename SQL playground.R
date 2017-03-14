opta <- src_sqlite("C:/Users/Neil/Documents/Stats/SQL Databases/opta",create = FALSE)

RegionLookup <- tbl(opta, 'RegionLookup')
CompetitionLookup <- tbl(opta, 'CompetitionLookup')

region <- filter(RegionLookup, RegionName == 'USA')
region.comps <- left_join(region, CompetitionLookup, by = "RegionID")
region.comps