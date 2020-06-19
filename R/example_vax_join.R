# Example of joining relevant vaccination data into pregnancy table

# Run Load.R and Demographics.R first to ensure that the df2v4 object is in the environment
source("R/Load.R")
source("R/Demographics.R")

# set up data
pregnancies_data <- df2v4

# First simulate some vaccination data
pt_ids <- pregnancies_data %>% dplyr::distinct(`Patient key`) # NB easier to use column names with no spaces in
flu_seasons <- pregnancies_data %>% dplyr::distinct(fluseason)

# Simulation probability that pt. will receive vaccination in each season
prob_vaxed <- 0.4
# Note of course it is unrealistic to assume a constant probability of
# vaccination as the whole point is that women should be explicitly offered
# the flu vaccination when they are pregnant, and thus are on average much
# more likely to be vaccinated in seasons when they are pregnant vs not.
# But for the purposes of testing approaches to assembling the study dataframe,
# this is not a problem.

# Create a tibble of all combinations of patient and season
vaccination_data <- tidyr::expand_grid(`Patient key` = pt_ids, fluseason = flu_seasons)
# Simulate a column for whether the patient was vaccinated in the season in question
set.seed(1234)
vaccination_data <- vaccination_data %>%
  dplyr::mutate(vaccinated = as.logical(rbinom(nrow(vaccination_data), 1, prob_vaxed)))
# One approach would be to have the vaccination data in this format, i.e. one row for
# every woman-season combination, with a boolean column indicating whether they received the
# vaccination in that season or not.
# Another approach would be to have a table with one row for every woman-season for
# which the woman recieved the vaccination in that season. This is smaller and thus
# may be preferable. A potential disadvantage of the latter approach is that it wouldn't be possible to
# distinguish between a season in which a woman did not have the vaccination and one in which
# we do not know whether she did (missing vaccination status data). However, I'm not sure that
# we will be able to make this distinction anyway, so for proceeding with this latter option.
vaccination_data <- vaccination_data %>%
  dplyr::filter(vaccinated == TRUE) %>%
  dplyr::select(-vaccinated)

# Now create a new column in the pregnancy table to indicate whether the woman had
# a vaccination in the season corresponding to that pregnancy.

# Define a function that returns a boolean:
# TRUE if the woman is a vaccination recorded for the season in question,
# FALSE if not
vaccinated <- function(pt_key, season, vaccination_data) {
  vaccination_data %>%
    filter(`Patient key` == pt_key, fluseason == season) %>%
    nrow() > 0
}

# test this function out
vaccinated(1, "2011-2012", vaccination_data = vaccination_data)
vaccinated(1, "2016-2017", vaccination_data = vaccination_data)

# use the function to add the new column to the pregnancy table
pregnancies_data <- pregnancies_data %>%
  rowwise() %>%
  mutate(vax_in_season = vaccinated(`Patient key`, fluseason, vaccination_data)) %>%
  ungroup()
# there is probably a more elegant/faster way to do this than having to use
# rowwise here. But this is intended as a proof of concept - and may be ok in
# the end too.

# View(pregnancies_data) to see the result
