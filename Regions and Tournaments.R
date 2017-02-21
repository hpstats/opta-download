start.row <- grep("allRegions",home.html)
end.row <- start.row + grep("favoriteTournaments",
                            home.html[start.row:length(home.html)])[1] - 3

regions.competitions <- data.table(long.string = home.html[start.row:end.row])
regions.competitions$long.string[1] <- substr(regions.competitions$long.string[1],19,
                                              nchar(regions.competitions$long.string))
regions.competitions2 <- data.table(str_split_fixed(regions.competitions$long.string,
                                                    ',',5))
regions <- data.table(region.id = substr(regions.competitions2$V2,5,
                                         nchar(regions.competitions2$V2)),
                         region.type = substr(regions.competitions2$V1,7,7),
                         region.name = substr(regions.competitions2$V4,9,
                                              nchar(regions.competitions2$V4)
                                              - 1),
                         competition.list = as.character(substr(regions.competitions2$V5,
                                                   17,
                                                   nchar(regions.competitions2$V5) - 4)))

region.table <- regions[,.(region.id, region.type, region.name)]

if(update.regions == "Y"){
  opta$con %>% db_drop_table(table = "regiontable")
  dbWriteTable(opta$con, value = region.table, name = "regiontable", append = FALSE)
}

competitions <- regions[,.(region.id, competition.list = substr(competition.list,3,
                                             nchar(competition.list)))]

s <- strsplit(competitions$competition.list, split = "id")
competition.list <- data.table(region.id = rep(competitions$region.id,
                                               sapply(s, length)),
                               str_split_fixed(unlist(s),',',3))

competition.table <- data.table(region.id = competition.list$region.id,
                                competition.id = substr(competition.list$V1,2,
                                                        nchar(competition.list$V1)),
                                competition.url = substr(competition.list$V2,7,
                                                         nchar(competition.list$V2) -
                                                           1),
                                competition.name = substr(competition.list$V3,8,
                                                          nchar(competition.list$V3) -
                                                            4))



if(update.competitions == "Y"){
  opta$con %>% db_drop_table(table = "competitiontable")
  dbWriteTable(opta$con, value = competition.table, name = "competitiontable",
               append = FALSE)
}