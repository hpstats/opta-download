#Download match database
MatchLookup <- collect(tbl(opta, 'MatchLookup'))
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
    if (is.na(grep('matchCentreData', match.html))){
      start.row <- grep('initialMatchDataForScrappers', match.html)[1]
      end.row <- grep('initialMatchDataForScrappers', match.html)[2]
    } else {
      matchdataline <- grep('matchCentreData', match.html)[1]
    }
  }
}