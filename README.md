What this file is, is a collection of shift by shift data in order to calculate a couple things.

In the folder we will see 4 different files


# FlyersAfterGoal


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




# TeamGoalsafterXMin_SingleSeason



