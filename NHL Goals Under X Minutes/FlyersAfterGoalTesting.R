library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)

###########################################################################
#Not documented yet
###########################################################################




testJSON <- fromJSON( sprintf("https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId=2015020486"))
testJSON2 <- testJSON[["data"]]
testJSON2 <- mutate(testJSON2, endTime = period_to_seconds(ms(endTime)), startTime = period_to_seconds(ms(startTime)))

yourTeamName = "Philadelphia Flyers"

getGoals <- list()
getGoals <- testJSON2 %>%
  filter(detailCode>=1) %>%
  select(endTime, period,teamName, eventDescription) %>%
  arrange(period, endTime)
getGoals$GamePK <- "2015020486"
goalsForGame <- length(getGoals$eventDescription)

getGoals$TimeBetweenGoals <- 0

for (x in 1:goalsForGame) {
  if(x == 1){
    getGoals$TimeBetweenGoals[x] = 0
  }  else{
    if (getGoals$period[x] == getGoals$period[x - 1]) {
      getGoals$TimeBetweenGoals[x] = (getGoals$endTime[x] - getGoals$endTime[x-1])
    } else {
      getGoals$TimeBetweenGoals[x] = 0
      
    }
  }
}

getGoals$TeamScoredBefore <- ""

for (y in 1:goalsForGame) {
  if(y == 1){
    getGoals$TeamScoredBefore[y] = ""
  } else{
    if (getGoals$period[y] == getGoals$period[y - 1]) {
      getGoals$TeamScoredBefore[y] = getGoals$teamName[y-1]
    } else {
      getGoals$TimeBetweenGoals[y] = ""
      
    }
  }
}



for (z in 1:goalsForGame){
  if(getGoals$teamName[z] == yourTeamName & getGoals$TeamScoredBefore[z] == yourTeamName){
    #Your Team scored and scored before
    getGoals$GoalsDef[z] <- 0
  } else if(getGoals$teamName[z] == yourTeamName & getGoals$TeamScoredBefore[z] != yourTeamName) {
    #Your team scored and opposing team scored before
    getGoals$GoalsDef[z] <- 1
  } else if(getGoals$teamName[z] != yourTeamName & getGoals$TeamScoredBefore[z] != yourTeamName) {
    #Opposing team scored and scored before
    getGoals$GoalsDef[z] <- 2
  } else if(getGoals$teamName[z] != yourTeamName & getGoals$TeamScoredBefore[z] == yourTeamName){
    #Opposing team scored and your team scored before
    getGoals$GoalsDef[z] <- 3
  }
}

###############################################
# 0 = Your Team scored the goal and previous Goal
# 1 = Your team scored the goal and Opposing team scored previous Goal
# 2 = Opposing Team Scored goal and previous goal
# 3 = Opposing Team scored goal and your team scored previous goal
###############################################

#getGoals <- filter(getGoals, as.integer(TimeBetweenGoals) <= 180 & as.integer(TimeBetweenGoals) >= 6 ,TimeBetweenGoals!=0, TimeBetweenGoals!="")
getGoals <- filter(getGoals, eventDescription != "Shootout", period != 4)

getShift <- testJSON2 %>%
  filter(startTime!=0, period == getGoals$period[10] & endTime >= getGoals$endTime[10] & startTime < getGoals$endTime[10]) %>%
  select(id,firstName, lastName, startTime, endTime,shiftNumber,teamName, duration)


length(getGoals$endTime)

if(length(getGoals$endTime) == 0) {
  
} else {
  mylist <- list()
  for (i in 1:length(getGoals$eventDescription) ){
    print(i)
    getShift <- testJSON2 %>%
      filter(startTime!=0, period == getGoals$period[i] & endTime >= getGoals$endTime[i] & startTime < getGoals$endTime[i]) %>%
      select(id,firstName, lastName, startTime, endTime,shiftNumber,teamName, duration)
    getShift$goalType <- getGoals$eventDescription[i]
    getShift$goalDef <- getGoals$GoalsDef[i]
    getShift$gameID <- "2020020126"
    mylist[[i]] <- getShift
  }
}
























library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)



yourTeamName = "Philadelphia Flyers"


schedule <- nhlapi:::nhl_from_json("https://statsapi.web.nhl.com/api/v1/schedule?season=20202021&teamId=4&gameTypes=R")
getgamePK <- schedule[["dates"]][["games"]]



X <- list()
for (i in 1:length(getgamePK)) {
  X[i] <- getgamePK[[i]] %>%
    select(gamePk)
}
TotalShifts <- data.frame(id=integer(), firstname=character(), lastName=character(), startTime=integer(), endTime=integer(), shiftNumber=integer(), 
                          teamName=character(), duration=character(), goalType=character(), goalDef=integer(), goalTime=integer(), period=integer(),
                          gameID=integer())
mylist <- list()

for (gameID in 1:length(X)) {
  print(X[[gameID]])
  testJSON <- fromJSON( sprintf("https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId=%s", X[[gameID]]))
  testJSON2 <- testJSON[["data"]]
  testJSON2 <- mutate(testJSON2, duration = period_to_seconds(ms(duration)), endTime = period_to_seconds(ms(endTime)), startTime = period_to_seconds(ms(startTime)))
  
  getGoals <- list()
  getGoals <- testJSON2 %>%
    filter(detailCode>=1) %>%
    select(endTime, period,teamName, eventDescription) %>%
    arrange(period, endTime)
  getGoals$GamePK <- "2020020783"
  goalsForGame <- length(getGoals$eventDescription)
  
  getGoals$TimeBetweenGoals <- 0
  
  for (x in 1:goalsForGame) {
    if(x == 1){
      getGoals$TimeBetweenGoals[x] = 0
    }  else{
      if (getGoals$period[x] == getGoals$period[x - 1]) {
        getGoals$TimeBetweenGoals[x] = (getGoals$endTime[x] - getGoals$endTime[x-1])
      } else {
        getGoals$TimeBetweenGoals[x] = 0
        
      }
    }
  }
  
  getGoals$TeamScoredBefore <- ""
  
  for (y in 1:goalsForGame) {
    if(y == 1){
      getGoals$TeamScoredBefore[y] = ""
    } else{
      if (getGoals$period[y] == getGoals$period[y - 1]) {
        getGoals$TeamScoredBefore[y] = getGoals$teamName[y-1]
      } else {
        getGoals$TimeBetweenGoals[y] = ""
        
      }
    }
  }
  
  
  
  for (z in 1:goalsForGame){
    if(getGoals$teamName[z] == yourTeamName & getGoals$TeamScoredBefore[z] == yourTeamName){
      #Your Team scored and scored before
      getGoals$GoalsDef[z] <- 0
    } else if(getGoals$teamName[z] == yourTeamName & getGoals$TeamScoredBefore[z] != yourTeamName) {
      #Your team scored and opposing team scored before
      getGoals$GoalsDef[z] <- 1
    } else if(getGoals$teamName[z] != yourTeamName & getGoals$TeamScoredBefore[z] != yourTeamName) {
      #Opposing team scored and scored before
      getGoals$GoalsDef[z] <- 2
    } else if(getGoals$teamName[z] != yourTeamName & getGoals$TeamScoredBefore[z] == yourTeamName){
      #Opposing team scored and your team scored before
      getGoals$GoalsDef[z] <- 3
    }
  }
  
  ###############################################
  # 0 = Your Team scored the goal and previous Goal
  # 1 = Your team scored the goal and Opposing team scored previous Goal
  # 2 = Opposing Team Scored goal and previous goal
  # 3 = Opposing Team scored goal and your team scored previous goal
  ###############################################
  
  
  getGoals <- filter(getGoals, as.integer(TimeBetweenGoals) <= 180 & as.integer(TimeBetweenGoals) >= 6 ,TimeBetweenGoals!=0, TimeBetweenGoals!="")
  
  if(length(getGoals$endTime) == 0){
    
  } else{
    for (i in 1:length(getGoals$eventDescription) ){
      getShift <- testJSON2 %>%
        filter(startTime!=0, period == getGoals$period[i] & endTime >= getGoals$endTime[i] & startTime < getGoals$endTime[i]) %>%
        select(id,firstName, lastName, startTime, endTime,shiftNumber,teamName, duration)
      getShift$goalType <- getGoals$eventDescription[i]
      getShift$goalDef <- getGoals$GoalsDef[i]
      getShift$goalTime <- getGoals$endTime[i]
      getShift$period <- getGoals$period[i]
      getShift$gameID <- X[[gameID]]
      #mylist[[i]] <- getShift
      TotalShifts <- rbind(TotalShifts, getShift)
    }
  }
  
  
  
}

write.csv(TotalShifts,"C:\\Users\\Luke\\Desktop\\SHL\\sheeesh.csv", row.names = FALSE)
