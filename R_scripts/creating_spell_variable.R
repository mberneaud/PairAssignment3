# Creating a new variable which indicates the number of terms a mayor has served
# Date: 18.04.2016


# Installing the DataCombine package from Christopher's repo
devtools::install_github("christophergandrud/DataCombine")

# loading packages
lapply(c("DataCombine", "readxl"), library, character.only = TRUE)

# loading the election data into R
MayorElection <- read_excel("data/MayorElectionData.xlsx", sheet = "Bgm_OB")


# Cleaning variable names -------------------------------------------------

# Trimming whitespace
SparkassenBoard$NameMunicipality <- str_trim(SparkassenBoard$NameMunicipality)
SparkassenBoard$NameCandidate1 <- str_trim(SparkassenBoard$NameCandidate1)

# removing newlines
names(MayorElection) <- str_replace_all(names(MayorElection), "[\r\n]" , "")  
# removing punctuation
names(MayorElection) <- gsub("[[:punct:]]", "", names(MayorElection))
# removing whitespace
names(MayorElection) <- str_trim(names(MayorElection))
# correc# removing newlines
names(MayorElection) <- str_replace_all(names(MayorElection), "[\r\n]" , "")  
# removing punctuation
names(MayorElection) <- gsub("[[:punct:]]", "", names(MayorElection))
# removing whitespace
names(MayorElection) <- str_trim(names(MayorElection))
# correcting "Geschlecht"
names(MayorElection) <- gsub("^Geschl", "Geschlecht", names(MayorElection))

# Changing label names
newnames <- c("IDMunicipality","NameMunicipality", "ElectionDate", "RunOffNecessary", "ElectionType", "ProfPolitician", "NumberEligVoter", "NumberVoters", "InvalBallots", "ValBallots", "NameCandidate1")

names(MayorElection)[1:11] <- newnames

names(MayorElection) <- gsub("gültigeStimmen 1", "VotesCandidate1", names(MayorElection))
names(MayorElection) <- gsub("Stimmen für nicht genannte Bewerber zusammen", "VotesRest", names(MayorElection))
names(MayorElection) <- gsub("^Geschl", "Geschlecht", names(MayorElection))

# Creating spell variable -------------------------------------------------
names(MayorElection) <- gsub("Stimmen für nicht genannte Bewerber zusammen", "VotesRest", names(MayorElection))
# Creating the Spell variable for the entire data set
MayorElection$FakeVar <- 1
MayorElection <- CountSpell(MayorElection, TimeVar = "ElectionDate", 
                            SpellVar = "FakeVar", GroupVar = "NameCandidate1", 
                            NewVar = "TermMayor", SpellValue = as.numeric(1))
