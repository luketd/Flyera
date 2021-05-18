library(nhlapi)
library(dplyr) 
library(jsonlite)
library(stringr)
library(lubridate)

nhl_teams() %>%
  select(id, name)

#######################
#Which NHL team do you want to check
NHLID <- 1

#########################
#What time do you want to get
time <- 120 #the time between goals(in seconds)

##############################
#What season you want to get ex. if you want the 19/20 season you put 2019
season <- 2020



schedule <- nhlapi:::nhl_from_json(sprintf("https://statsapi.web.nhl.com/api/v1/schedule?season=%s%s&teamId=%s&gameTypes=R", season, season+1, NHLID))
getgamePK <- schedule[["dates"]][["games"]]



X <- list()
for (i in 1:length(getgamePK)) {
  X[i] <- getgamePK[[i]] %>%
    select(gamePk)
}

templist1 <- list()
goalsUnderMin <- data.frame(endTime=double(), period=double(),teamName=character(), eventDescription=character(),GamePK=character(), TimeBetweenGoals = double(), TeamScoredBefore = character())

for (e in 1:length(X)){
  print(X[[e]])
  testJSON <- fromJSON( sprintf("https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId=%s", X[[e]]))
  
  testJSON2 <- testJSON[["data"]]
  testJSON2 <- mutate(testJSON2, endTime = period_to_seconds(ms(endTime)), startTime = period_to_seconds(ms(startTime)))
  
  getGoals <- list()
  getGoals <- testJSON2 %>%
    filter(detailCode>=1) %>%
    select(endTime, period,TeamScored = teamName, eventDescription) %>%
    arrange(period, endTime)
  getGoals$GamePK <- X[[e]]
  goalsForGame <- length(getGoals$eventDescription)
  
  if (length(getGoals$TeamScored) == 0){
    
  } else {
    getGoals$TimeBetweenGoals <- 0
    getGoals$TeamScoredBefore <- ""
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
    templist1[[e]] <- getGoals
    #goalsUnder2Min <- rbind(goalsUnder3Min, getGoals)
    
  }
  
  
  
  
  
}

TeamName <- "Toronto Maple Leafs"

#the amount of times that an opponent has scored in 3 minutes or less of a goal
a <- goalsUnderMin %>%
  filter(TeamScored != TeamName)

#the amount of times that your team has scored in 3 minutes or less of a goal
b <- goalsUnderMin %>%
  filter(TeamScored == TeamName)

#the G column is the amount of times that an opponent has scored in 3 minutes or less of a goal that your team has scored
g <- count(a, a$TeamScoredBefore==TeamName)
g <- g$n[2]

h <- count(b, b$TeamScoredBefore!=TeamName)
h <- h$n[2]


stats <- data.frame( Team=character(), GoalsScoredUnder3Min=double(), OppTeamScored = double(), OppTeamScoredAgainstTeam=double(), TeamScored=double(), TeamScoredAgainstOppTeam=double())
stats <- c(TeamName, count(goalsUnderMin), count(a), g, count(b), h)





