###############
# Sparkassen Board Data: Import and cleaning
# Author: Jonas Markgraf
# Last change: 13/04/16
###############

library(stringr)
library(repmis)
# set working directory
possibles <- c("~/Dropbox/Data-BankElec-Malte-Jonas/")
set_valid_wd(possibles)

# import Board database
SparkassenBoard <- read.table("BankBoards_Bavaria_RImport.txt", 
                        sep="\t", header = TRUE, fileEncoding ="UTF-16")

# define variable class:
SparkassenBoard$Incumbent <- as.character(SparkassenBoard$Incumbent)


# tidy data:
## Rename Variables
### :Municipality Name
SparkassenBoard <- plyr::rename(SparkassenBoard,
                          replace = c("Name_CountyMunicipality" = "NameMunicipality"))
### :Candidate Name
SparkassenBoard <- plyr::rename(SparkassenBoard,
                          replace = c("name" = "NameCandidate1"))

## Clean Variables: Municipality Name & Candidate Name
SparkassenBoard$NameMunicipality <- str_trim(SparkassenBoard$NameMunicipality)
SparkassenBoard$NameCandidate1 <- str_trim(SparkassenBoard$NameCandidate1)

# Define New Variables:
## Top Position
SparkassenBoard$TopPosition <- 0
SparkassenBoard$TopPosition[SparkassenBoard$chair != "no"] <- 1
SparkassenBoard$TopPosition <- as.character(SparkassenBoard$TopPosition)

# Create sub-dataframes
## :unique board members
SparkassenBoard_UniqueMembers <- unique(SparkassenBoard[,c("NameCandidate1", "occupation", "Incumbent", "TopPosition",
                                      "NameMunicipality")])
## :mayors at board
SparkassenBoard_UniqueBoardMayors <- subset(SparkassenBoard_UniqueMembers, Incumbent == "1")
## :Top Positions only
SparkassenBoard_TopPositions <- subset(SparkassenBoard, TopPosition == 1)
