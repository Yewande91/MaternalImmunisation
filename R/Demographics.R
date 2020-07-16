#Characteristics of eligible pregnant women aged 15-49 Years during the 2010‒2011
#through 2019‒2020 Influenza Seasons 
install.packages(c("DescTools","tidyverse","magrittr"))

#load DescTools
library(DescTools)

#load tidyverse
library(tidyverse)

#load magrittr
library(magrittr)

df1<-data_frames[[1]]


#create new columns to show number of days of overlap between a pregnancy and an influenza season
Preg_flu_season  <- df1 %>% 
  rowwise() %>% 
  mutate('2010-2011' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2010-09-01", "2011-03-31")))) %>% 
  mutate('2011-2012' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2011-09-01", "2012-03-31")))) %>% 
  mutate('2012-2013' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2012-09-01", "2013-03-31")))) %>% 
  mutate('2013-2014' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2013-09-01", "2014-03-31")))) %>% 
  mutate('2014-2015' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2014-09-01", "2015-03-31")))) %>% 
  mutate('2015-2016' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2015-09-01", "2016-03-31")))) %>% 
  mutate('2016-2017' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2016-09-01", "2017-03-31")))) %>% 
  mutate('2017-2018' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2017-09-01", "2018-03-31")))) %>% 
  mutate('2018-2019' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2018-09-01", "2019-03-31")))) %>% 
  mutate('2019-2020' = Overlap (c(preg_start_date, preg_end_date), as.Date(c("2019-09-01", "2020-03-31"))))


#create column with unique consecutive numbers
Preg_flu_season<-tibble::rowid_to_column(Preg_flu_season, "ID")

#delete columns
Preg_flu_season <- Preg_flu_season[, -c(2:18)]

#gather to show each season for each pregnancy
Preg_flu_season <- Preg_flu_season %>%
  gather("fluseason", "overlap", 2:11)

#slice to maintain season with which a pregnancy has the most overlap
Preg_flu_season <-
  Preg_flu_season %>%
  group_by(`ID`) %>%
  slice(which.max(`overlap`))


demographics<- df1

demographics <- tibble::rowid_to_column(demographics, "ID")

demographics<- left_join(demographics,Preg_flu_season,by = "ID")


#categorise age column

agelabelspop <- c("15-24","25-34","35-44","45+")
agebreakspop <- c(15,25,35,45,59)
demographics<- demographics %>% 
  dplyr::mutate(age_groups = cut(mother_age_sop, breaks = agebreakspop, right = FALSE, labels = agelabelspop))


#Demographics table
library(table1) 


table1(~ age_groups + ethnicity + local_authority | fluseason, data=demographics, overall="Total")




