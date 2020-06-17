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
                         'Patient key'= col_integer(),
                         'Age' = col_integer(),
                         'Ethnicity' = col_character(),
                         'Diabetes' = col_date(format = ""),
                         'Kidney disease' =	col_date(format = ""),
                         'CCG' =	col_character(),
                         'Pregstart' =	col_date(format = ""),
                         'Pregend'= col_date(format = ""))
  )
  })
}

#create variable called data_frames which contains the list of dataframes 
#with the data-raw/Matimms_Data_extension
data_frames <- load_data_files(fileNames)


