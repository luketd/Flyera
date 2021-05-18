library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)


#selecting all NHL teams to just their ID and name
nhlteams <- nhl_teams() %>%
  select(id, name)


#populating the data frame with columns
stats <- data.frame( Team=character(), year=integer(),gamesPlayed=integer(), GA=integer(), GF=integer(), GoalsScoredUnder2Min=double(), OppTeamScored = double(), OppTeamScoredPercent = double(),OppTeamScoredAgainstTeam=double(), OppTeamScoredAgainstTeamPercent=double(), TeamScored=double(), TeamScoredPercent=double(), TeamScoredAgainstOppTeam=double(),  TeamScoredAgainstOppTeamPercent=double())
time <- 120 #the time between goals(in seconds)


tempList3 <- list()

for (year in 2016:2020){
  print(year)
  tempList2 <- list()
  #for 1-32 teams, run through the for loop
  for (teamNum in 1:length(nhlteams$id)){
    if(nhlteams$id[teamNum] == 55){
      break #skips the kraken
    } else if (nhlteams$id[teamNum] == 54 & year <= 2016){
      break 
    }
    
    print(nhlteams$name[teamNum]) #prints team name
    TeamName <- nhlteams$name[teamNum] 
    #pulls the schedule for that team
    schedule <- nhlapi:::nhl_from_json(sprintf("https://statsapi.web.nhl.com/api/v1/schedule?season=%s%s&teamId=%s&gameTypes=R", year, year+1, nhlteams$id[teamNum]))
    getgamePK <- schedule[["dates"]][["games"]]
    
    #getting the GA/GP 
    print(nhlteams$id[teamNum])
    team  <- nhl_teams_stats(nhlteams$id[teamNum],year)
    teamGA <- as.double(((team[[8]][[1]])[[1]][[1]][[8]][[1]]))
    teamGF <- as.double(((team[[8]][[1]])[[1]][[1]][[7]][[1]]))
    
    #pull all the game ID's from the schedule
    X <- list()
    for (i in 1:length(getgamePK)) {
      X[i] <- getgamePK[[i]] %>%
        select(gamePk)
    }
    #populating the data frame with columns
    goalsUnder2Min <- data.frame(endTime=double(), period=double(),teamName=character(), eventDescription=character(),GamePK=character(), TimeBetweenGoals = double(), TeamScoredBefore = character())
    
    #for loop that takes the gameID to get the individual game shifts
    
    goalsList <- list()
    tempList1 <- list()
    for (e in 1:length(X)){
      testJSON <- fromJSON( sprintf("https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId=%s", X[[e]]))
      
      testJSON2 <- testJSON[["data"]]
      
      if (length(is.na.data.frame(testJSON2)) == 0){
        #if game was not played, skip
      } else {
        #change the time ex(1:32) to seconds 92 seconds
        testJSON2 <- mutate(testJSON2, endTime = period_to_seconds(ms(endTime)), startTime = period_to_seconds(ms(startTime)))
        
        #getting a list of all of the goals that are scored
        getGoals <- list()
        getGoals <- testJSON2 %>%
          filter(detailCode>=1) %>%
          select(endTime, period,TeamScored = teamName, eventDescription) %>%
          arrange(period, endTime)
        getGoals$GamePK <- X[[e]]
        goalsForGame <- length(getGoals$eventDescription)
        
        getGoals$TimeBetweenGoals <- 0
        getGoals$TeamScoredBefore <- ""
        #getting the time between goals & who scored the previous goal
        for (x in 1:goalsForGame) {
          if(x == 1){
            getGoals$TimeBetweenGoals[x] = 0
            getGoals$TeamScoredBefore[x] = ""
          }  else{
            if (getGoals$period[x] == getGoals$period[x - 1]) {
              getGoals$TimeBetweenGoals[x] = (getGoals$endTime[x] - getGoals$endTime[x-1])
              getGoals$TeamScoredBefore[x] = getGoals$TeamScored[x-1]
            } else {
              getGoals$TeamScoredBefore[x] = ""
              getGoals$TimeBetweenGoals[x] = 0
              
            }
          }
        }
        
        
        #filter down the goal scored to X seconds, and having it above 3 seconds between goals for some errors on the NHL AP side
        
        getGoals <- filter(getGoals, as.integer(TimeBetweenGoals) <= time & as.integer(TimeBetweenGoals) >= 3.0, TimeBetweenGoals!=0, TimeBetweenGoals!="")
        #goalsUnder2Min <- rbind(goalsUnder2Min, getGoals)
        tempList1[[e]] <- getGoals
        gamesPlayed <- e
      }
      
    }
    
    goalsUnder2Min <- do.call(rbind, tempList1)
    
    #the amount of times that an opponent has scored in 3 minutes or less of a goal
    a <- goalsUnder2Min %>%
      filter(TeamScored != TeamName)
    
    #the amount of times that your team has scored in 3 minutes or less of a goal
    b <- goalsUnder2Min %>%
      filter(TeamScored == TeamName)
    
    
    #the amount of times that an opponent has scored in 3 minutes or less of a goal that your team has scored
    g <- count(a, a$TeamScoredBefore==TeamName)
    g <- g$n[2]
    
    #the amount of times that your team has scored in 3 minutes or less of a goal that the opposing has scored
    h <- count(b, b$TeamScoredBefore!=TeamName)
    h <- h$n[2]
    
    GA <- as.integer(teamGA * gamesPlayed)
    GF <- as.integer(teamGF * gamesPlayed)
    yearX <- paste(year, year+1, sep="/")
    tempDF <- data.frame(TeamName, yearX, gamesPlayed, GF, GA, count(goalsUnder2Min) , count(a), count(a)/GA , g, g/GA, count(b), count(b)/GF, h, h/GF )
    tempList2[[teamNum]] <- tempDF
    #stats <- rbind(stats, tempDF)
    
  }
  tempList3[[year]] <- tempList2
  
  
  
}
stats <- do.call(rbind, tempList3)

NHLstats <- do.call(rbind, stats)





write.csv(NHLstats,"C:\\Users\\Luke\\Desktop\\SHL\\5years.csv", row.names = FALSE)


