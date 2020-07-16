#install the following packages
install.packages(c("magrittr","lubridate","tidyverse"))

#load magrittr
library(magrittr)

#load lubridate
library(lubridate)

#load tidyverse
library(tidyverse)

#find file names with a data-raw/Matimms_Data_extension
fileNames<-Sys.glob("data-raw/Matimms_Data_*.csv")

#create a function to load data files
load_data_files<-function(fN){
  lapply(fN, function(x)
  {loadfiles<-read_csv(x,
                       col_types=cols(
                         'mother_wsic_id'= col_integer(),
                         'preg_episode_id' = col_guess(), 
                         'preg_start_date' = col_date(format = ""),
                         'preg_end_date' = col_date(format = ""),
                         'mother_age_sop' = col_integer(),
                         'ethnicity' = col_factor(levels = c("Asian or asian british",
                                                             "Black or black british", 
                                                             "Mixed", 
                                                             "White",
                                                             "UNKNOWN",
                                                             "Other ethnic groups",
                                                             "Not known")),
                         'local_authority' =	col_character(),
                         'asthma' =	col_integer(),
                         'chr_respiratory_disease' =	col_integer(),
                         'chr_heart_disease'  =	col_integer(),
                         'chr_kidney_disease' =	col_integer(),
                         'chr_liver_disease' =	col_integer(),
                         'asplenia_or_dys_spleen' =	col_integer(),
                         'chr_neurological_disease' =	col_integer(),
                         'diabetes' =	col_integer(),
                         'immunosuppression' =  col_integer(),
                         'morbid_obesity'=  col_integer())
  )
  })
}

#create variable called data_frames which contains the list of dataframes 
#with the data-raw/Matimms_Data_extension
data_frames <- load_data_files(fileNames)



