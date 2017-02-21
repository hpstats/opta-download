for(i in 1:nrow(competition.table)){
  address2 <- paste(address, competition.table$competition.url[i], sep = '')
  
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
      fixtures.block <- fixtures.html[grep('DataStore', fixtures.html):
                                        (grep('stageFixtures.load', fixtures.html)[2]
                                      - 2)]
      
      
      
    }
    
    
  }
  
  Sys.sleep(5.0)
}
