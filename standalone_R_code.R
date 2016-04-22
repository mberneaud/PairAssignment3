# Standalone R-Code 
# Author: Malte Berneaud

# Packages needed for the execution of this Rmd are listed in include.packages and checked against the installed packages on the machine executing the code. If they are not installed, they will be installed automatically.
include.packages <- c("dplyr", "ggplot2", "stringr", "readxl", "DataCombine", "texreg", "stargazer")
needed.packages <- include.packages[!(include.packages %in% installed.packages()[, "Package"])]
if(length(needed.packages)) install.packages(needed.packages, repos = "https://cran.uni-muenster.de/")

lapply(include.packages, library, character.only = TRUE)  # loading all packages at once


# Loading data ------------------------------------------------------------

# Sparkassen Board Membership data
SparkassenBoard <- read_excel("data/BankBoards_Bavaria_RImport.xlsx",
                              sheet = "BoardComp")
## define variable class:
SparkassenBoard$Incumbent <- as.character(SparkassenBoard$Incumbent)

# Municipal Election data
MayorElection <- read_excel("data/MayorElectionData.xlsx",
                            sheet = "Bgm_OB")


# Cleaning municipality election data set ---------------------------------

# removing newlines
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

# Cleaning of gender strings
MayorElection$Geschlecht1 <- str_trim(MayorElection$Geschlecht1)

# cleaning of party names
MayorElection$MayorParty <- MayorElection$"Wahlvorschlag 1"
MayorElection$MayorParty <- str_trim(MayorElection$MayorParty)
# reduce party to main party only
MayorElection$MayorParty <- sub("/.*","", MayorElection$MayorParty)



# Cleaning the party names for bar plotting
MayorElection$CleanParty <- NA
for(i in 1:nrow(MayorElection)) {
  if(is.na(MayorElection$MayorParty[i])) {
    next
  }
  if(grepl("CSU", MayorElection$MayorParty[i])) {
    MayorElection$CleanParty[i] <- "CSU"
  }else if(grepl("SPD", MayorElection$MayorParty[i])) {
    MayorElection$CleanParty[i] <- "SPD"
  } else {
    MayorElection$CleanParty[i] <- "Other"
  }
}


# Creating additional variables -------------------------------------------

# Extracting Phd titles
MayorElection$Phd <- NA
MayorElection$Phd <- ifelse(grepl("Dr.", MayorElection$NameCandidate1), 1, 0)
MayorElection$NameCandidate1 <- gsub(" Dr.", "", MayorElection$NameCandidate1)
MayorElection$NameCandidate1 <- gsub(" jur.", "", MayorElection$NameCandidate1)

# creating the total number of terms for each mayor
tally <- dplyr::tally(group_by(MayorElection, NameCandidate1))
names(tally)[2] <- "TotalTerms"
#merging that back into the data frame
MayorElection <- merge(MayorElection, tally)

# Extracting years from the election date character string
MayorElection$Year <- strtrim(MayorElection$ElectionDate, 4L)

# Dummy variable for contested elections
MayorElection$Contested <- ifelse(nchar(MayorElection$`Name 2Nachname Titel Vorname`)>2, 1, 0)

# Calculating votes shares from the data
MayorElection$VoteShareWinner <-  (MayorElection$VotesCandidate1 / MayorElection$ValBallots) * 100

## Lagged DV
# creating lagged incumbency for the calculation of the re-election binary variable
MayorElection <- slide(MayorElection, Var = "NameCandidate1", TimeVar = "ElectionDate", NewVar = "L.NameCandidate1")

MayorElection$Reelection <- ifelse(MayorElection$NameCandidate1 == MayorElection$L.NameCandidate1, 1, 0)

MayorElection$Reelection <- as.factor(MayorElection$Reelection)

# Lagging variables for analysis, lag of SparkassenMembership is already implemented above. Lag variable is called "IncumbentSparkassenMember"
MayorElection <- slide(MayorElection, Var = "Geschlecht1", TimeVar = "ElectionDate", NewVar = "L.Geschlecht1")
MayorElection <- slide(MayorElection, Var = "VoteShareWinner", TimeVar = "ElectionDate", NewVar = "L.VoteShareWinner")



# Subsetting the data set -------------------------------------------------

# subsetting by year
MayorElection$Year <- as.integer(MayorElection$Year)
sel <- MayorElection[, "Year"] >= 2006
MayorElection <- MayorElection[sel, ]

# subsetting by election type; excluding run-off elections
valids <- MayorElection[, "ElectionType"] != 3
MayorElection <- MayorElection[valids, ]

# Subsetting to contested elections only
contested <-  MayorElection[, "Contested"] == 1
MayorElection <- MayorElection[contested, ]



# Merging data sets -------------------------------------------------------

##: variable for board membership
MayorElection$SparkassenMember <- is.element(MayorElection$NameCandidate1, unique(SparkassenBoard$NameCandidate1))

##: variable for board membership of incumbent
#library(DataCombine) # I moved the loading of the library up in the initiatl code which checks whether all necessary packages are installed, installs missings and then load them (named: "fetching_library") (MB)
MayorElection <- slide(MayorElection, Var = "SparkassenMember",
                       NewVar = "IncumbentSparkassenMember")


# Descriptive statistics election data set --------------------------------

# plotting composition of mayors
ggplot(MayorElection, aes(x = CleanParty)) +
  geom_bar() + ylab("Number of Mayors") + xlab("Party Affiliation") + ggtitle("Number of Mayors by Party Affiliation")

# computing reelection chances
reelections <- group_by(MayorElection, CleanParty)
reelections$Reelection <- as.character(reelections$Reelection) %>%  as.integer(.)
reelections <- summarise(reelections, total.mayors.party = n(),
                         number.reelected.mayors = sum(Reelection, na.rm = TRUE))
reelections <- mutate(reelections, share.reelections = number.reelected.mayors / total.mayors.party)


# Plotting re-election changes
ggplot(reelections, aes(x = CleanParty, y = share.reelections)) +
  geom_point(stat = "identity") + ylab("Share of Re-elected Mayors") +
  xlab("Party Affiliation") + ggtitle("Re-election Chances of Mayors by Party")

# Plotting density distribution of municipality size
d <- density(MayorElection$NumberEligVoter, na.rm = TRUE)
plot(d, main = "Kernel density: Eligible Voters Per Municipality", xlab = "Eligible Voters Per Municipality")