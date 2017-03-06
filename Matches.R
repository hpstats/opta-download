new.MatchLookup <- data.table(text.string = rep('', 10000),
                              CompetitionID = rep('', 10000),
                              RegionID = rep('', 10000))
address(new.MatchLookup)
start.row <- 0

pb <- winProgressBar(title="Competition progress", label="0% done", min=0, max=100,
                     initial=0)

for(i in 1:nrow(CompetitionLookup)){
#for(i in 1:5){
  address2 <- paste(address, CompetitionLookup$CompetitionAddress[i], sep = '')
  
  tries <- 0
  
  while (tries < 5){
    comp.html <- try(readLines(address2))
    if(class(comp.html) == "try-error" | length(comp.html) <= 50){
      tries <- tries + 1
      Sys.sleep(5.0)
    } else {
      tries <- 10
    }
  }
  
  if (tries == 5){
    error <- address2
  } else {
    fixtures.line <- comp.html[grep('See monthly fixtures', comp.html)]
    fixtures.url <- substr(fixtures.line, 
                    str_locate(fixtures.line, 'href=') + 6,
                    str_locate(fixtures.line, 'class=') - 3)
    
    address3 <- paste(address, fixtures.url, sep = '')
    
    tries <- 0
    
    while (tries < 5){
      fixtures.html <- try(readLines(address3))
      if(class(fixtures.html) == "try-error" | length(fixtures.html) <= 50){
        tries <- tries + 1
        Sys.sleep(5.0)
      } else {
        tries <- 10
      }
    }
    
    if (tries == 5){
      error <- address
    } else {
      endrows <- grep('stageFixtures.load', fixtures.html)
      fixtures.block <- fixtures.html[grep('DataStore', fixtures.html):
                                        (endrows[length(endrows)]
                                      - 2)]
      
      fixtures.block[1] <- substr(fixtures.block[1],
                                  str_locate(fixtures.block[1], '\\[\\['),
                                  nchar(fixtures.block[1]))
      
      for(j in 1:length(fixtures.block)){
        new.MatchLookup[start.row + j, 1 := fixtures.block[j]]
        new.MatchLookup[start.row + j, 2 := CompetitionLookup$CompetitionID[i]]
        new.MatchLookup[start.row + j, 3 := CompetitionLookup$RegionID[i]]
      }
      
      start.row <- start.row + length(fixtures.block)
      
    }
    
  }
  info <- sprintf("%d%% done", round((i/nrow(CompetitionLookup))*100))
  
  setWinProgressBar(pb, i/(nrow(CompetitionLookup))*100, label=info)
  
  Sys.sleep(5.0)
}

address(new.MatchLookup)

close(pb)

new.MatchLookup <- new.MatchLookup[new.MatchLookup$text.string != '',]

new.MatchLookup$text.string <- substr(new.MatchLookup$text.string,
                                      3,
                                      nchar(new.MatchLookup$text.string) - 1)
new.MatchLookup$text.string <- gsub("'", "", new.MatchLookup$text.string)

text.string2 <- data.table(str_split_fixed(new.MatchLookup$text.string, ",", 21))

MatchLookup <- data.table(MatchID = text.string2$V1,
                          DateTime = ymd_hms(paste(as.Date(text.string2$V4,
                                                           ' %b %d %Y'),
                                                   paste(text.string2$V5,
                                                         ':00',
                                                         sep = ''),
                                                   sep = ' ')),
                          TeamID.Home = text.string2$V6,
                          TeamID.Away = text.string2$V9,
                          CompetitionID = new.MatchLookup$CompetitionID)

MatchLookup <- MatchLookup[month(MatchLookup$DateTime) == month(today())]
MatchLookup <- MatchLookup[year(MatchLookup$DateTime) == year(today())]

TeamLookup.home <- data.table(TeamID = text.string2$V6,
                              TeamName = text.string2$V7,
                              RegionID = new.MatchLookup$RegionID)

TeamLookup.away <- data.table(TeamID = text.string2$V9,
                              TeamName = text.string2$V10,
                              RegionID = new.MatchLookup$RegionID)

TeamLookup <- unique(rbind(TeamLookup.home, TeamLookup.away))
