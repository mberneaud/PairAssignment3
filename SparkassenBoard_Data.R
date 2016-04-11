###############
# Sparkassen Board Data: Import and cleaning
# Author: Jonas Markgraf
# Start: 09/03/16
# Last change: 01/04/16
###############

library(stringr)
# set working directory
setwd("~/Dropbox/Data BankElec Malte-Jonas/")

# import Board database
SparkassenBoard <- read.table("BankBoards_Bavaria_RImport.txt", 
                        sep="\t", header = TRUE, fileEncoding ="UTF-16")

# rename variables (in preparation of merge)
## Municipality Name
SparkassenBoard <- plyr::rename(SparkassenBoard,
                          replace = c("Name_CountyMunicipality" = "NameMunicipality"))
## Candidate Name
SparkassenBoard <- plyr::rename(SparkassenBoard,
                          replace = c("name" = "NameCandidate1"))

# new variables:
## Top Position
SparkassenBoard$TopPosition <- ifelse((SparkassenBoard$chair == "yes"), "yes",
                                ifelse((SparkassenBoard$chair == "deputy"), "yes",
                                       ifelse((SparkassenBoard$chair == "no"), "no", "no")))

# Clean Variables: Municipality Name & Candidate Name
SparkassenBoard$NameMunicipality <- str_trim(SparkassenBoard$NameMunicipality)
SparkassenBoard$NameCandidate1 <- str_trim(SparkassenBoard$NameCandidate1)


# subset of dataframe
## :unique board members
SparkassenBoard_UniqueMembers <- unique(SparkassenBoard[,c("name", "occupation", "Incumbent", "TopPosition",
                                      "NameMunicipality")])
## :mayors at board
SparkassenBoard_UniqueBoardMayors <- subset(SparkassenBoard_UniqueMembers, Incumbent == "1")

## :unique banks
SparkassenBoard_UniqueBanks <- unique(SparkassenBoard[,c("bank_ID", "bank_name", "federal_state", 
                                    "city", "board_size")])

# save data frames
write.csv(SparkassenBoard, file = "DataManipulation/SparkassenBoard.csv")
write.csv(SparkassenBoard_UniqueMembers, file = "DataManipulation/SparkassenBoard_UniqueMembers.csv")
write.csv(SparkassenBoard_UniqueBanks, file = "DataManipulation/SparkassenBoard_UniqueBanks.csv")
