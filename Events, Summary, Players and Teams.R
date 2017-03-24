#Download match database
##MatchLookup <- collect(tbl(opta, 'MatchLookup'))
MatchLookup <- data.table(MatchID = c(1080824,1086220))
#Later, will have to filter out already downloaded matches

#Initialise LineupLookup
#Initialise EventLookup
#Initialise SummaryLookup
#Initialise PlayerLookup

#Progress bar
pb <- winProgressBar(title="Match progress", label="0% done", min=0, max=100,
                     initial=0)

for(i in 1:nrow(MatchLookup)){
  #Download competition home page
  address4 <- paste(address, "/Matches/", MatchLookup$MatchID[i], '/Live', sep = '')
  
  tries <- 0
  
  while (tries < 5){
    match.html <- try(readLines(address4))
    if(class(match.html) == "try-error" | length(match.html) <= 50){
      tries <- tries + 1
      Sys.sleep(5.0)
    } else {
      tries <- 10
    }
  }
  
  if (tries == 5){
    error <- address4
  } else {
    if (length(grep('matchCentreData', match.html)) == 0){
      start.row <- grep('initialMatchDataForScrappers', match.html)[1]
      end.row <- grep('initialMatchDataForScrappers', match.html)[2]
    } else {
      matchdata <- match.html[grep('matchCentreData', match.html)[1]]
      
      #Players
      player.string1 <- substr(matchdata, str_locate(matchdata,
                                                     'playerIdNameDictionary')[2] + 4,
                               nchar(matchdata))
      player.string2 <- data.table(p.string = substr(player.string1, 1,
                                                     str_locate(player.string1,
                                                                '\\}')[1]- 1))
      s <- strsplit(as.character(player.string2$p.string), ',')
      player.table <- data.table(V1=gsub('"', '', unlist(s)))
      player.table2 <- data.table(str_split_fixed(player.table$V1, ":", 2))
      
      #Other match facts
      attendance.string1 <- substr(matchdata, str_locate(matchdata, 'attendance')[2] + 3,
                               nchar(matchdata))
      attendance.string2 <- data.table(at.string = substr(attendance.string1, 1,
                                                          str_locate(attendance.string1,
                                                                ',')[1]- 1))
      
      venue.string1 <- substr(matchdata, str_locate(matchdata, 'venueName')[2] + 3, 
                              nchar(matchdata))
      venue.string2 <- data.table(ve.string = gsub('"', '',
                                                   substr(venue.string1, 1,
                                                          str_locate(venue.string1, 
                                                                ',')[1]- 1)))
      
      referee.string1 <- substr(matchdata, str_locate(matchdata, 'referee')[2] + 3,
                                nchar(matchdata))
      referee.string2 <- substr(referee.string1, str_locate(referee.string1, '"name"')[2]
                                + 3,
                                nchar(referee.string1))
      referee.string3 <- data.table(ref.string = substr(referee.string2, 1,
                                                        str_locate(referee.string2,
                                                                     ',')[1]- 3))
    }
    
    #Progress bar
    info <- sprintf("%d%% done", round((i/nrow(MatchLookup))*100))
    
    setWinProgressBar(pb, i/(nrow(MatchLookup))*100, label=info)
    
    #Sleep - as site doesn't allow downloads too frequently
    Sys.sleep(5.0)
  }
}
