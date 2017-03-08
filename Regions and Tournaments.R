#Find list of competitions
start.row <- grep("allRegions",home.html)
end.row <- start.row + grep("favoriteTournaments",
                            home.html[start.row:length(home.html)])[1] - 3

regions.competitions <- data.table(long.string = home.html[start.row:end.row])

#Parse list
regions.competitions$long.string[1] <- substr(regions.competitions$long.string[1],19,
                                              nchar(regions.competitions$long.string))
regions.competitions2 <- data.table(str_split_fixed(regions.competitions$long.string,
                                                    ',',5))

#Create region lookup
regions <- data.table(RegionID = substr(regions.competitions2$V2,5,
                                         nchar(regions.competitions2$V2)),
                         RegionType = substr(regions.competitions2$V1,7,7),
                         RegionName = substr(regions.competitions2$V4,9,
                                              nchar(regions.competitions2$V4)
                                              - 1),
                         competition.list = as.character(substr(regions.competitions2$V5,
                                                   17,
                                                   nchar(regions.competitions2$V5) - 4)))

RegionLookup <- regions[,.(RegionID, RegionType, RegionName)]

#Update region database
if(update.regions == "Y"){
  opta$con %>% db_drop_table(table = "RegionLookup")
  dbWriteTable(opta$con, value = RegionLookup, name = "RegionLookup", append = FALSE)
}

#Parse competitions
competitions <- regions[,.(RegionID, competition.list = substr(competition.list,3,
                                             nchar(competition.list)))]

s <- strsplit(competitions$competition.list, split = "id")
competition.list <- data.table(RegionID = rep(competitions$RegionID,
                                               sapply(s, length)),
                               str_split_fixed(unlist(s),',',3))

#Create competition lookup
CompetitionLookup <- data.table(CompetitionID = substr(competition.list$V1,2,
                                                        nchar(competition.list$V1)),
                                CompetitionName = substr(competition.list$V3,8,
                                                          nchar(competition.list$V3) -
                                                            4),
                                CompetitionAddress = substr(competition.list$V2,7,
                                                            nchar(competition.list$V2) -
                                                              1),
                                RegionID = competition.list$RegionID)

CompetitionLookup <- CompetitionLookup[substr(CompetitionLookup$CompetitionAddress, 1,
                                              7) == '/Region']

rm(competition.list, competitions, regions, regions.competitions, regions.competitions2,
   RegionLookup, end.row, home.html, s, start.row, tries)

#Update competition database
if(update.competitions == "Y"){
  opta$con %>% db_drop_table(table = "CompetitionLookup")
  dbWriteTable(opta$con, value = CompetitionLookup, name = "CompetitionLookup",
               append = FALSE)
}

rm(CompetitionLookup)