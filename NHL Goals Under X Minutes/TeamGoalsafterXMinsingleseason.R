library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)

#selecting all NHL teams to just their ID and name
nhlteams <- nhl_teams() %>%
  select(id, name)

#################################
#What time do you want to get
time <- 120 #the time between goals(in seconds)


#########################
#What season you want to get ex. if you want the 19/20 season you put 2019
season <- 2020

#populating the data frame with columns
stats <- data.frame( Team=character(), gamesPlayed=integer(), GAGP=integer(), GoalsScoredUnder2Min=double(), OppTeamScored = double(), OppTeamScoredPercent = double(),OppTeamScoredAgainstTeam=double(), TeamScored=double(), TeamScoredAgainstOppTeam=double())


emptyListForGA <- list()
tempList <- list()
#for 1-32 teams, run through the for loop
for (teamNum in 1:length(nhlteams$id)){
  if(nhlteams$id[teamNum] == 55){
    break
  }
  
  print(nhlteams$name[teamNum]) #prints team name
  TeamName <- nhlteams$name[teamNum] 
  #pulls the schedule for that team
  schedule <- nhlapi:::nhl_from_json(sprintf("https://statsapi.web.nhl.com/api/v1/schedule?season=%s%s&teamId=%s&gameTypes=R", season, season+1, nhlteams$id[teamNum]))
  getgamePK <- schedule[["dates"]][["games"]]
  
  #getting the GA/GP 
  print(nhlteams$id[teamNum])
  teamGA  <- nhl_teams_stats(nhlteams$id[teamNum],season)
  teamGA <- as.double(((teamGA[[8]][[1]])[[1]][[1]][[8]][[1]]))
  
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
      emptyListForGA[[e]] <- getGoals
      gamesPlayed <- e
    }
  }
  goalsUnder2Min <- do.call(rbind, emptyListForGA)
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
  
  GAGP <- as.integer(teamGA * gamesPlayed)
  
  tempDF <- data.frame(TeamName, gamesPlayed, GAGP, count(goalsUnder2Min) , count(a), count(a)/GAGP , g, count(b), h)
  #stats <- rbind(stats, tempDF)
  tempList[[teamNum]] <- tempDF
  
  
}


stats <- do.call(rbind, tempList)
