################
# Descriptive Statistics: SparkassenBoard
# Author: Jonas Markgraf
# Start: 10/03/16
# Last edit: 06/04/16
################

library(ggplot2)

# set working directory
possibles <- c("~/PairAssignment3/")
set_valid_wd(possibles)

# dynamically linking to file
source("SparkassenBoard_Data.R")

# DESCRIPTIVE STATISTICS: BANKS

## Number of Banks in Bank dataframe
length(unique(SparkassenBoard[,c("bank_name")])) # 79 banks in Database

## Board Size
summary(SparkassenBoard_UniqueBanks$board_size) # max: 32 seats, min: 6 seats, average (median): 12 seats

# DESCRIPTIVE STATISTICS: BOARD MEMBERS

## Number of name-year combinations
length(SparkassenBoard$NameCandidate1) #8974 name-year combinations

## Number of Profiles in Board dataframe
length(unique(SparkassenBoard[,c("NameCandidate1")])) # 1,663 unique profiles in dataframe

## Number and Share of Prof. Politicians in Board Dataframe
table(unique(SparkassenBoard[,c("NameCandidate1", "Incumbent")])$Incumbent) # 410 mayors; 174 Landräte; 1,157 others

prop.table(table(SparkassenBoard$Incumbent)) # 23% mayors; 11% Landrat; 65% others

# Number of municipalities with board seat
length(unique(SparkassenBoard$NameMunicipality)) # 357 municipalities

## Top Positions in Boards:

### Share of Top Positions based on BankData (not unique names)
table(SparkassenBoard$TopPosition) # 2,119 member-year observations in top positions, 6,855 not.

prop.table(table(SparkassenBoard$TopPosition)) # 24% in top positions; 76% no top position

ggplot(SparkassenBoard, aes(TopPosition, frequency(TopPosition))) + 
  geom_bar(stat = "identity") +
  xlab("") +
  ylab("Number of Seats") +
  ggtitle("Number of Top Positions in Boards")

### Analysis of Composition of Top Positions
table(subset(SparkassenBoard_TopPositions, TopPosition != "no")$Incumbent) # Of 2,115 observations in top positions, 875 mayors; 1,006 Landrat; 238 others

prop.table(table(SparkassenBoard_TopPositions$Incumbent)) # 11% not directly elected; 47% mayors; 41% Landrat

barplot(table(SparkassenBoard_TopPositions$Incumbent),
        main = "Share of Politicians in Top Positions on Bank Board",
        names.arg = c("Non-Political", "Mayor", "Landrat"),
        ylab = "Board Members in Top Positions")

### Comparison: Board Members in Top Positions and Entire Board
ggplot(SparkassenBoard, aes(TopPosition, frequency, fill = Incumbent)) +
  geom_bar(aes(y = (..count..)), position=position_dodge(), width=1) +
  xlab("") +
  scale_x_discrete(limit= c("0", "1"),
                   labels=c("Non-Top Positions", "Top Positions")) +
  ylab("Number of Board Members") +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_fill_discrete(name="Political Position",
                      breaks=c("0", "1", "2"),
                      labels=c("No Full-Time Politician", "Mayor", "County Commissioner"))