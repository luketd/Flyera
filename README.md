

# FlyersAfterGoal
What this file is, is a collection of shift by shift data on who was put out after a goal was scored. What is presented is
* FirstName, LastName, StartTime(seconds), endTime(seconds), shiftNumber, team, duration of shift(seconds), goalType, goalDef, GoalTime(seconds), Period, Team Scored, #Goal For, #Goal Against, gameID
* goalType
   * EVG = Even Strength Goal
   * PPG = Power Play Goal
   * SHG = Short Handed Goal
* goalDef
   * Your Team scored the goal and previous Goal
   * Your team scored the goal and Opposing team scored previous Goal
   * Opposing Team Scored goal and previous goal
   * Opposing Team scored goal and your team scored previous goal

From there you can transform the data how you like, for example get the number of times a player was put out on the ice after the opponent scored an EVG.


For example, for the Philadelphia Flyers, this is the count of which players were put out onto the ice after the opposing team scored an EVG
| Full Name           | #of times put out | avg duration of that shift |
|---------------------|-----------------|--------------|
| Ivan Provorov       | 50              | 47.82        |
| Justin Braun        | 48              | 44.79166667  |
| Travis Sanheim      | 47              | 43.31914894  |
| Kevin Hayes         | 40              | 44.2         |
| Scott Laughton      | 40              | 39.75        |
| Philippe Myers      | 39              | 43.1025641   |
| James van Riemsdyk  | 36              | 47.19444444  |
| Shayne Gostisbehere | 36              | 49.22222222  |
| Joel Farabee        | 35              | 41.77142857  |
| Nolan Patrick       | 34              | 39.76470588  |
| Travis Konecny      | 33              | 37           |
| Jakub Voracek       | 32              | 47.1875      |
| Nicolas Aube-Kubel  | 31              | 42.25806452  |
| Oskar Lindblom      | 31              | 38.70967742  |
| Claude Giroux       | 30              | 47.53333333  |
| Robert Hagg         | 26              | 50.80769231  |
| Sean Couturier      | 26              | 46.03846154  |
| Michael Raffl       | 19              | 37.42105263  |
| Erik Gustafsson     | 18              | 37.83333333  |
| Samuel Morin        | 14              | 38.28571429  |
| Connor Bunnaman     | 13              | 32.30769231  |
| Brian Elliott       | 9               | 522.5555556  |
| Carsen Twarynski    | 7               | 43.57142857  |
| Nate Prosser        | 7               | 41           |
| Wade Allison        | 7               | 38.14285714  |
| Jackson Cates       | 6               | 31.83333333  |
| Mark Friedman       | 4               | 56.75        |
| Tanner Laczynski    | 4               | 33.25        |
| Andy Andreoff       | 2               | 30.5         |
| Egor Zamula         | 2               | 8.5          |
| Maksim Sushko       | 2               | 25.5         |
| David Kase          | 1               | 30           |


# Individual Team


# TeamGoalsAfterXMin

## The goal of this and TeamGoalsafterXMin_SingleSeason is to extract the following data
* The basic information of Team Name, The Year, Games Played, Goals For, and Goals against
* Then the specific data we are pulling 
    * n = The amount of goals that happened to that team, that happened 2 minutes or less after another goal was scored
    * n.1 = The amount of goals against that happened to the team, that happened 2 minutes or less after another goal was scored
        * n.2 = The normalized version of n.1 which is n.1 / GA
    * g = The amount of goals against that happened to the team, after your team has scored a goal
        * g.GA = the normalized version of g, which is g / GA
    * n.3 = The amount of goals for that happened to the team, that happened 2 minutes or less after another goal has scored
        * n.4 = The normalized version of n.4, which is n.4 / GF
    * h = The amount of goals for that happened to the team, that happened 2 minutes or less after the opposing team has scored
        * h.gf = The normalized version of h.gf which is h.gf / GF

The result should be each team from the season's and time that you chosen in a data frame, in which you can export as a csv. For example this is the Philadelphia Flyers in the past 5 years. 

| TeamName              | yearX     | gamesPlayed | GF  | GA  | n   | n.1 | n.2                | g  | g.GA               | n.3 | n.4                | h  | h.GF               |
|-----------------------|-----------|-------------|-----|-----|-----|-----|--------------------|----|--------------------|-----|--------------------|----|--------------------|
| Philadelphia Flyers   | 2016/2017 | 82          | 211 | 230 | 69  | 30  | 0.130434782608696  | 14 | 0.0608695652173913 | 39  | 0.184834123222749  | 13 | 0.0616113744075829 |
| Philadelphia Flyers   | 2017/2018 | 82          | 249 | 235 | 76  | 36  | 0.153191489361702  | 22 | 0.0936170212765957 | 40  | 0.160642570281124  | 23 | 0.0923694779116466 |
| Philadelphia Flyers   | 2018/2019 | 82          | 240 | 280 | 76  | 39  | 0.139285714285714  | 15 | 0.0535714285714286 | 37  | 0.154166666666667  | 19 | 0.0791666666666667 |
| Philadelphia Flyers   | 2019/2020 | 72          | 236 | 199 | 73  | 38  | 0.190954773869347  | 17 | 0.085427135678392  | 35  | 0.148305084745763  | 13 | 0.0550847457627119 |
| Philadelphia Flyers   | 2020/2021 | 56          | 159 | 197 | 57  | 40  | 0.203045685279188  | 16 | 0.0812182741116751 | 17  | 0.106918238993711  | 8  | 0.050314465408805  |



# TeamGoalsafterXMin_SingleSeason

This is exactly like TeamGoalsAfterXMin but it is for only 1 single season instead of multiple seasons. So refer to that

