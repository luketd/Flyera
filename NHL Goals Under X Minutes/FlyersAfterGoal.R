library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)



yourTeamName = "Philadelphia Flyers"


schedule <- nhlapi:::nhl_from_json("https://statsapi.web.nhl.com/api/v1/schedule?season=20202021&teamId=4&gameTypes=R")
getgamePK <- schedule[["dates"]][["games"]]


goalsFor <- 1
goalsAgainst <- 1
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
  
  
  #getGoals <- filter(getGoals, as.integer(TimeBetweenGoals) <= 180 & as.integer(TimeBetweenGoals) >= 6 ,TimeBetweenGoals!=0, TimeBetweenGoals!="")
  getGoals <- filter(getGoals, eventDescription != "Shootout", period != 4)
  if(length(getGoals$endTime) == 0){
    
  } else{
    for (i in 1:length(getGoals$eventDescription) ){
      getShift <- testJSON2 %>%
        filter(startTime!=0, teamName == yourTeamName,  period == getGoals$period[i] & endTime >= getGoals$endTime[i] & startTime <= getGoals$endTime[i] & endTime !=getGoals$endTime[i]) %>%
        select(firstName, lastName, startTime, endTime,shiftNumber,teamName, duration)
      getShift$goalType <- getGoals$eventDescription[i]
      getShift$goalDef <- getGoals$GoalsDef[i]
      getShift$goalTime <- getGoals$endTime[i]
      getShift$period <- getGoals$period[i]
      getShift$TeamScored <- getGoals$teamName[i]
      getShift$GoalFor <- 0
      getShift$GoalAgainst <- 0
      if (getGoals$teamName[i] == yourTeamName){
        getShift$GoalFor <- goalsFor
        goalsFor <- goalsFor + 1
      } else {
        getShift$GoalAgainst <- goalsAgainst
        goalsAgainst <- goalsAgainst +1
      }
      getShift$gameID <- X[[gameID]]
      #mylist[[i]] <- getShift
      TotalShifts <- rbind(TotalShifts, getShift)
    }
    
  }
  
  
  
}

write.csv(TotalShifts,"C:\\Users\\Luke\\Desktop\\SHL\\Shiftaftergoal.csv", row.names = FALSE)

###########################
#concatenate first and last name

TotalShifts$fullName <- paste(TotalShifts$firstName, TotalShifts$lastName, sep= " ")



####################################
#split the data up to the count of shifts a player was out after a EVG, PPG, and SHG after an opposing team scored

#Total
OppScored <- TotalShifts %>%
  filter(TeamScored != yourTeamName) %>%
  group_by(fullName) %>%
  tally()


#EVG
evgOppScored <- TotalShifts %>%
  filter(TeamScored != yourTeamName, goalType=="EVG") %>%
  group_by(fullName) %>%
  tally()

#PPG
ppgOppScored <- TotalShifts %>%
  filter(TeamScored != yourTeamName, goalType=="PPG") %>%
  group_by(fullName) %>%
  tally()


#SHG
shgOppScored <- TotalShifts %>%
  filter(TeamScored != yourTeamName, goalType=="SHG") %>%
  group_by(fullName) %>%
  tally()

###########################################################
#split the data up to the count of shifts a player was out after a EVG, PPG, and SHG after your team scored

#Total
TeamScored <- TotalShifts %>%
  filter(TeamScored == yourTeamName) %>%
  group_by(fullName) %>%
  tally()


#EVG
evgTeamScored <- TotalShifts %>%
  filter(TeamScored == yourTeamName, goalType=="EVG") %>%
  group_by(fullName) %>%
  tally()

#PPG
ppgTeamScored <- TotalShifts %>%
  filter(TeamScored == yourTeamName, goalType=="PPG") %>%
  group_by(fullName) %>%
  tally()


#SHG
shgTeamScored <- TotalShifts %>%
  filter(TeamScored == yourTeamName, goalType=="SHG") %>%
  group_by(fullName) %>%
  tally()




