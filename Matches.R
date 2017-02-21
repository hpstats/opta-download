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
    
    
    
  }
  
  Sys.sleep(5.0)
}