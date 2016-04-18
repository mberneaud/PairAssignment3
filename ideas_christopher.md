## Christopher's idea for modelling the effect of *Sparkassen* board membership

1. Match data set in similar observations with an R package like MatchIt to create matching observations and then run a regression model on the resulting data set. This models board membership as a "treatment" effect which differentiates the two groups.

2. We could run the model with term fixed-effects, by including the number of terms per candidate as a factor variable. This would essentially control for the incumbency advantage.
  + However, this makes all the other predictors statistically insignificant, as it might be controlling for the mechanism
  + Alternative: run (1) one model with term fixed effects and compare it to a (2) model not directly measuring the number of terms per candidate
    + The second model is attempting a decomposition of the incumbency advantage
