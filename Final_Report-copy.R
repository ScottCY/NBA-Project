#' ---
#' title: "Predicting Score Differences in NBA Regular Season Basketball Games"
#' date: "`r Sys.Date()`"
#' author: "Yuqi He (Michael), Zijie Zhou (Luke), Chenyue Qian (Scott), Nick Ma"
#' output: pdf_document
#' # Or use output: pdf_document
#' # Or don't use either, in which case you will be prompted to choose
#' ---
#' 
#' ## Abstract
#' 
#' Accurately predicting the score differences in NBA basketball games
#' is no simple task. In this research, using game-by-game box scores
#' from 2012-2018 NBA regular seasons, we present a linear model
#' with design matrix, estimating the team strengths using previous results
#' and applying the model to predict score differences of NBA regular
#' season games. The model takes in team fatigue levels and starting line-up
#' salary weights to adjust the team strengths. The results are very close to 
#' the pointspreads, which are the market equilibria predictions before the 
#' start of the games.
#' 
#' ## 1. Introduction
#' 
#' The National Basketball Association (NBA) is the most influential 
#' professional basketball league in the world. Each of the 30 teams plays 82 
#' regular games every season, with potentially up to 28 playoff games. 
#' Each result to the game is determined in 4 quarters of 48 minutes of
#' regular time or additional overtime. 
#'
#' Being one of the most popular 
#' sporting events in the world, the NBA has been frequently analyzed for 
#' multiple applications. One popular approach is to predict the winning
#' probability of teams in a game. However, a potential problem of such objective
#' is that it fails to estimate the real strength differences between different
#' teams -- A binary prediction produces a probability, which is not a representation
#' of true team strengths. Another popular approach is directly using in game STATs to predict
#' outcomes of games, which could potentially lead to cheating or overfitting.
#' Other approaches include heavy use of feature engineering, which has a problem
#' with reproducibility and explainability.
#' 
#' One potential non-cheating method to predict score differences is trying to 
#' discover the variables determining pointspreads. 
#' The pointspreads are market equilibria betting statistics collected 24 hours
#' before the games. To a certain extent, the pointspreads represent the 
#' public confidence of teams winning/losing by certain numbers and serves as
#' an expected team strength difference supported by the information that 
#' could be obtained before the game starts. A -7.5 pointspread means that
#' the primary team is expected to win by more than 7.5 points.
#' 
#' It is important to note that basketball, or all sports games have high randomness -- some
#' key player might experience a bad night and the team lost by more than
#' expected -- it is the beauty of the games. This is why the market equilibrium
#' of score differences are not always accurate. However, the existence of
#' pointspreads provide a good baseline for us to investigate what pregame
#' information could explain when trying to predict score differences.
#' 
#' Here we raise our research question: Is there a non-cheating and interpretable
#' method for predicting and explaining the score differences in NBA games depending on
#' prior knowledge of the game? 
#' 
#' To approach this question, we think back to the concept of point spreads. Being
#' the market equilibrium of estimating point difference before the game starts,
#' it is an expected value of score differences from the public taking in
#' all information that could be considered before the game. Some key variables
#' that could affect the point spreads dramatically would be injury situations,
#' fatigue level of teams, previous team results, etc.
#' 
#' Preliminary data processing and analysis is made and creation of some key variables as well as using previous results of teams to build
#' individual team strengths coefficients before the games helped the construction
#' of a design matrix linear model. The predictions from the model, after experimentation,
#' are proved to be performing slightly worse than the pointspreads.
#' 
#' 
#' ## 2. Data processing
#' 
#' ### 2.1. Data Source
#' 
#' There is a total of 5 datasets from external sources used in this research.
#' The team box scores data[1] consists of game-by-game records from the
#' 2012-2013 season to 2017-2018 season. Each row is exactly one game, with a
#' unique combination of dates, teams, and scores, along with 120 other variables of
#' in game Statistics and advance statistics. Players box scores data[2] is a 
#' game-by-game record of all players' in game statistics. Each row is a 
#' record of a single performance of a single player in a single game, along with
#' 100 columns of in game statistics related to the player. A player salary 
#' dataset[3] is used. Each row consists of a unique combination of player, team,
#' and season. Some other data sources provided aid for variable explorations, but
#' the variables created was eventually not selected in the model. A dataset formed
#' by web scrapping[4] provided game-by-game pointspreads before the games from
#' the 2012-2013 season to 2016-2017 season. 
#' 
#' ### 2.2. Prior explorations on data
#' Since the objective of the research is to predict the score differences of
#' games, it is obvious that the main dataset used for explorations and 
#' predictions is the team box score data. A problem with predicting using the
#' dataset alone is that the variables it has are in game statistics, which are not
#' exactly known before each game. This could lead to potential "cheating"
#' when predicting games -- sure the predictions will be very accurate, but
#' how does anyone know the in game statistics before the game starts? 
#' 
#' For the sake of non-cheating, a lot of variables by themselves are
#' useless. A good approach would be taking the average of some
#' variables of the previous games by some number of games that would
#' make the variables valid, and use the resulting variables. In this case, these 
#' processed variables are prior knowledge before games, hence "non-cheating".
#' 
#' Since there are 110 variables that are in game statistics (not counting
#' those that will be merged), it is a huge
#' engineering process to manipulate every single in game statistics into 
#' a non-cheating form. It is obvious that some variables will be chosen for 
#' modeling, and many others will not. Some pre-game variables that proved to be
#' important are the indication of whether the team is playing full 
#' strength. A weight of total salary of on court players with respect
#' to the team total salary seems logical to have. Another variable proved to be
#' crucial is fatigue, teams that played back-to-back games are less likely
#' to play in full strength. 
#' 
#' ### 2.3. Data Wrangling
#' The objective of data wrangling at this stage is to provide datasets with variables
#' that could be further explored and engineered for the modeling stage.
#' The two game-by-game box score datasets (team and player) are the primary data for further explorations.
#' Some prior explorations were done separately
#' on each dataset, leading to some changes to the datasets. To start, 
#' some variables in the team box score data that are unimportant for this
#' project (such as referee names) were deleted. Some new variables were created
#' for the sake of merging datasets in a more preferred way(such as Season). After cleaning
#' the individual datasets separately, potential desired variables from 
#' the salary and the pointspread datasets were merged into the box score datasets.
#' We define the variables (such as salary and pointspreads) that are not originally in the box score datasets
#' additional variables.
#' These steps resulted in a dataset with team box score records,
#' with variables team total salary (tss), season, game date(gmDate), primary and
#' second team back to back records (teamBacktoBack and opptBacktoBack), 
#' team dayoffs (teamDayoff, opptDayoff), Pointspread, Score difference (scorediff),
#' and some other variables that we think should be kept for further explorations.
#' Another dataset results from the cleaning is the the game-by-game box score data
#' with variables season, player name, gmDate, individual salary and other variables
#' that will eventually not be used.
#' 
#' We decided to keep many of the in-game STATs variables. These variables might
#' not be able to be engineered into a "non-cheating" form in such a short
#' period of time, but could be attempted in the future.
#' 
#' All games in the team box score data have two rows of records, one with the 
#' home team being the primary team, one with the away team being the primary team.
#' Only the games where primary teams are selected for modeling since
#' this would be a problem when a model is fitted on the data -- the standard error
#' of each coefficient will be small and that would lead to potential overfitting.
#' Another reason to choose games either as only the primary team being the 
#' home team or away team is that the intercept of the model would indicate
#' some home advantage coefficient.
#' 
#' The final team box score data that is eventually used for feature engineering
#' and modeling has 108 columns of 7379 rows, with each unique game being a row.
#' 
# 7 important columns showed for the resulting data, there are 101 more 
# variables, technically, we could look at all these variables, but
# that would be taking half the page.
x <- read.csv("final_data_nba.csv", stringsAsFactors = FALSE)
head(x[ ,c("gmDate", "teamAbbr", "opptAbbr", "Season", "teamLoc", "scorediff", "tss")])
dim(x)
#' Table 1: A glance of some variables in the team box score data after wrangling.
#' The dimension of the data is also shown.

#' 
#' ## 3. Methodology
#' 
#' Our exploratory data analysis (EDA) focuses mostly on calculating baseline indices 
#' for team strengths and engineer our additional variables (variables originally
#' not from the box score datasets) into valid indicators of situations before the start
#' of the games. Then, the EDA findings are implemented in the feature engineering
#' and modeling stages. A prediction on the data is then made by fitting the 
#' model multiple times on different dates of games (testing data).
#' 
#' ### 3.1. Exploratory Data Analysis (EDA)
#' 
#' A clean and exploration-ready data does not have the best variables for prediction.
#' As a start, the team strength coefficients are not present. Thus, it is 
#' ideal to start by looking for a way to create a team strength index 
#' for measuring the differences between NBA teams' competitive levels. A potential way
#' to address individual team strengths is to look at the previous games by their results.
#' The reason here is the previous results usually includes the form, attacking strength, and
#' defensive strengths of teams before the game starts.
#' 
#' In addition, data merged from datasets with additional variables are not perfect.
#' For instance, individual player salaries cannot predict the outcomes of games.
#' It would be helpful if salary information is used to address the team starting
#' situation (i.e. whether a team's starting lineup is consist of their best players).
#' Back to back records before the game could also be addressing the fatigue situation
#' of the team. A worthy note is that since the data is now one row per game,
#' it would be ideal to look at the difference between the home team and away team
#' of the above mentioned situations. The differences would automatically provide
#' a comparison between the teams, which could be build into the model.
#' 
#' ### 3.2. Feature manipulation/engineering
#' Some non-cheating information are required for reflecting the 
#' fatigue and injury to predict more realistically. Whether there are some back-to-back 
#' games may affect the performance. (Back-to-back games: one team play two games 
#' in consecutive two days)  Similarly, the days off before the game can also become a feature.
#' Also, some stars may change the whole games with their incredible personal ability. 
#' The number of key players in the team should also be included in our variables for prediction.
#' The integrity of the lineup is another key factor for influencing the game. Moreover, 
#' there is a difference between the absence of a superstar and the one of a fringe player. It is 
#' believed that salary can reflect the ability of a player to some extent. 
#' Hence, the health of the lineup can be calculated by the history data of the proportion of 
#' total salary of players on the court in the total salary for this season.
#' Hence, a new variable salaryw_g (salary weight in a single game) is produced
#' by adding up the weight of salaries(divide single player salary by the team total salary) 
#' of each starting lineup player for both teams. Since there is a home team salaryw_g and an away team salaryw_g
#' , it is logical to take the difference of the two variables to form an interactive
#' variable diffsalary. Another new variable diffback is created through subtracting
#' the home team back to back records by the away team back to back records.
#' Similar procudure is done on the Dayoff variable for both teams,
#' creating a new variable Dayoffdiff.
#' 
#' ![Figure 1: This plot shows a weak, positive relationship between the Score difference and the diffsalary variable, implying higher slarydiff could lead to greater advantages for the home team. This indicates that diffsalary could be a useful factor in the linear model.](salaryweight_plot.png)
#'
#' ### 3.3. Modeling
#' 
#' To address the aforementioned method of using previous results for estimating
#' team strengths before each game, we decide to construct a model matrix. Since 
#' our goal is to predict point differences, it is only logical to use previous
#' scorediff as the previous results in the model. In this case, a prediction
#' of score difference is the subtraction between team strengths.
#' 
#' The prediction of score difference is achieved through building a linear 
#' model with all the variables selected in the previous stage. For each game 
#' with the home team as $i$ and the away team as $j$, a simple model for 
#' predicting the score difference for a specific game is 
#' 
#' $$Y_{ij} = \lambda_0 + x_i - x_j + \epsilon_{ij}$$ 
#'   
#' where $\lambda_0$ represents the constant home advantage for the home team, 
#' $x_i$ and $x_j$ represents the 
#' strength of team i and team j, respectively. For $\epsilon_{ij}$, it is a 
#' random variable representing the error in here and are normally distributed 
#' with mean $0$ and variables $\sigma^2$. 
#' 
#' 
#' Now, as a simple model is recognized, value of $\lambda_0, x_i, x_j$ can be calculated through solving a linear model by 
#' constructing a design matrix. The linear model is given by:
#' 
#' $$ 
#' \textbf{y} = A\textbf{x} + \epsilon
#' $$
#' 
#' where $\textbf{y}$ is a vector contains the score difference for all the 
#' games chosen to include in the model. $\textbf{x}$ is the vector containing 
#' the necessary parameters for doing the prediction, i.e. containing $X_i$ for twenty-nine teams, with one 
#' team excluded in purpose. 
#' 
#' Here, $X$ is the design matrix for only the team coefficient, which could 
#' look like:
#' 
#' $$ X = 
#' \begin{bmatrix}  1 & \cdots & 0 & \cdots & -1 & \cdots & 0  \\ 
#' 0 & 1 & \cdots & -1 & 0 & \cdots & 0 \\
#' \vdots && \ddots &&&& \vdots\\
#' \vdots &&& \ddots &&& \vdots\\
#' \vdots &&&& \ddots && \vdots\\
#' 0 & \cdots & 0 & -1 & 1 & \cdots & 0\\
#' 0 & \cdots & 0 & \cdots & -1 & \cdots & 1 \end{bmatrix}
#' $$
#' 
#' $X$ is $n$ by $29$, where $n$ is the number of games used in the model. For 
#' each row, the place corresponds to the home team would have $1$ while the 
#' place corresponds to the away team would have $-1$ and all other places in 
#' the row is $0$, representing this game is only associate with that two 
#' specific teams. This matrix along can used for predicting the team strength 
#' along. The reason to keep only 29 teams and omit the team strength for last 
#' team is because one team strength is entirely depends on other teams, so it 
#' can be directly set to $0$. Then, after obtaining this basic matrix, 
#' information about diffsalary and backdiff for each game can be adding 
#' onto the matrix by appending by column, which would consequently become the 
#' design matrix $A$ for prediction. Then, by applying the normal equation of 
#' linear regression, which is $\textbf{x} = ({A^{T}A})^{-1}A^{T}\textbf{y}$, 
#' the parameters can be estimated. The final model with additional variables
#' (diffsalary and backdiff) is then:
#' 
#' $$Y_{ij} = \lambda_0 + \beta_1 \lambda_1 + 
#' \beta_2\lambda_2 + x_i - x_j + \epsilon_{ij}$$ 
#'   
#' Where $\lambda_1$ represents the advantage of the team with better line up, 
#' indicating by the salary difference, and $\lambda_2$ represents the advantage
#' of the team that is not playing back to back game. For $\beta_1$ and 
#' $\beta_2$, they are two coefficients indicates the salary difference and 
#' back_to_back difference for the two teams, which helps to measure the 
#' influence of relative advantage brought by better line up and not playing 
#' back to back to that game's score difference. 
#' 
#' Implemented in R, the above full model fitted on one season of data
#' is as such:
#' 
lm1 <- readRDS("lm1.rds")
summary(lm1)
#' The summary of the linear model shows that all additional variables are 
#' valid, and that positive salarydiff and backdiff values do provide positive advantages to
#' the primary teams. A 0.2312 r-square value is achieved, showing that the model
#' explains 23.12% of the variability in the games. It is important to note that
#' the rest of the ~77% of variability mostly come from randomness, again, it is
#' the beauty of the game. The R-square value and p-values of variables vary
#' when different dates of games are fitted. The variations are generally very
#' small and it does not hurt the prediction process.
#'
#' ![Figure 2: An evenly distributed cloud of points are around the x-axis, which indicates that the variance of the errors does not depend on the values of the predictor variables. The equal variances assumption is valid](residualvfitted.png)
#' 
#' 
#' ![Figure 3: A normal probability plot (Q-Q plot). The residuals are almost all on the qqline, which implies that our model meet the assumption of normality](qqplot.png)
#' 
#' 
#' 
#' 
#' ### 3.4. Prediction
#' The prediction task in the research is one that require fitting a model for
#' each single day of games. For games in each gameday, all games played in the
#' previous season and the current season is used to fit the above-mentioned model.
#' The model coefficients is then extracted and multiplied on a matrix indicating
#' which teams played each other on this day. The resulting 
#' vector is the prediction for games on this gameday. 
#' 
#' To produce more reliable results, the set of games data and 
#' each game's weight have been chosen careful. For each game, all the games 
#' prior to that day in this season and all games in last season would be used 
#' for training. After carefully trying different methods of weight assignments,
#' the final selection of weight assignment has 
#' the last season's games end up to be set a relative weight of 0.1. In this 
#' season, a game would weight more if its time is more closer to the game we 
#' want to predict. This season's relative weights $w$ are set according to the
#' formula $w = 0.1i + 1$, where i represents the index of the date (e.g. 1 
#' represents the first day in a season).
#'  
#' Combinations of additional variables are also examined. Some 
#' observations yield decisions to keep variables key_player_diff
#' and dayoffdiff out of the model.
#' Variable key_player_diff is overwhelmingly possessed by 0s, whereas
#' dayoffdiff is a slightly more complex version of backdiff, which performed
#' slightly worse in prediction performance compare to backdiff.  
#' 
#' ## 4. Results
#' In most prediction tasks, the significance of variables do not merely
#' depend on the metrics produced by the fitted models themselves. Hence,
#' some experiments have been done, focusing on comparing the performance of prediction
#' with the point spreads (which are market equilibria of predictions) using 
#' the root mean square error (RMSE) of the predictions (versus the
#' actual score differences), given by:
#' 
#' $$ RMSE = \sqrt{\frac{1}{n}\Sigma_{i=1}^{n}{\Big(\frac{d_i -f_i}{\sigma_i}\Big)^2}} $$
#' 
#' The actual point spreads, compare to the final score differences in games,
#' produce a RMSE of 11.851 (for all NBA regular games from the 2012-2013 to
#' the 2016-2017 season). Our model's prediction in the same selected seasons 
#' produces a RMSE of 12.271, which is slightly worse than the market equilibrium.
#' The results makes decent sense since prior to the games, the public would 
#' understand the situations by looking at variables similar to that implemented
#' in the model, such as team lineup situations, previous results, etc..
#' 
#' Not surprisingly, Our
#' predictions are also highly correlated with the pointspreads, which implies
#' that the model contains most of the information that would be needed
#' to form a market equilibrium. The correlation between our predictions
#' and the pointspreads, after adjusting the pointspreads as a difference of
#' primary team score subtracted by second team score, is 0.925.
#' 
#' A certain pattern can be observed within the estimated team strengths. 
#' This is because in the beginning of each season we have limited amount of 
#' data for prediction, therefore a greater fluctuation and inconsistency is
#' seen in the estimated team strength. As more games are played towards the end
#' of the season, more data of the current season yield more accurate predictions, hence
#' the fluctuation reduces.
#' 
#' 
#' ![Figure 4: Matplot for team strengths from 2013-2020. It shows the trend of changes in team strength index for all the game score differences predicted.](matplot.png)  
#'
#' ![Figure 5: A detailed trend for changes in team strength index for 2013-2014 Season](matplot_singleseason.png)
#' 
#' ## 5. Conclusion
#' 
#' The beauty of sports games is the randomness -- we never know what is going
#' to happen in a game. It is also the same reason that sports analysts have been
#' trying so many ways throughout the years to predict accurate outcomes
#' of sports games. In this research, a design matrix linear regression is attempted
#' with non-cheating training data and it produces predictions on score differences
#' that are very close to the point spreads, explaining most variables 
#' considered before NBA basketball games generalized in a market equilibrium.
#' 
#' ## 6. Future Recommendations
#' 
#' Both variables selection and modeling are places that can be further improved. 
#' Future research could try to investigate more variables that might influence the team strengths, 
#' such as presenting of super star in a team. Adding estimation algorithms 
#' such as the Kalman filter could be a way of improving prediction accuracy. 
#' In addition, models can be made so that it would not produce score difference prediction 
#' that is too close to zero (e.g. 0.1) since such a score difference does not 
#' really tell who is the stronger team. Finally, Machine Learning methods could
#' be attempted with optimization methods such as boosting.
#' 
#' ## References
#' 
#' [1] Rossotti, P. (2018, November 8). NBA enhanced box score and Standings (2012 - 2018). Kaggle. Retrieved August 12, 2022, from https://www.kaggle.com/datasets/pablote/nba-enhanced-stats?select=2012-18_officialBoxScore.csv 
#' 
#' [2] Rossotti, P. (2018, November 8). NBA enhanced box score and Standings (2012 - 2018). Kaggle. Retrieved August 12, 2022, from https://www.kaggle.com/datasets/pablote/nba-enhanced-stats?select=2012-18_playerBoxScore.csv 
#' 
#' [3] Erikgregorywebb. (n.d.). Datasets/NBA-salaries.csv at master erikgregorywebb/datasets. GitHub. Retrieved August 12, 2022, from https://github.com/erikgregorywebb/datasets/blob/master/nba-salaries.csv 
#' 
#' [4] The gold sheet. The Gold Sheet. (n.d.). Retrieved August 12, 2022, from https://www.goldsheet.com/ 
#' 
#' [5] RStudio Team (2020). RStudio: Integrated Development for R. RStudio, PBC, Boston, MA URL http://www.rstudio.com/.
