#Characteristics of eligible pregnant women aged 15-49 Years during the 2010‒2011
#through 2019‒2020 Influenza Seasons 


#df2v1 <- df2 %>% 
#  rowwise() %>% 
#  mutate('2010-2011' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2010-09-01", "2011-03-31"))) %>% 
#  mutate('2011-2012' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2011-09-01", "2012-03-31"))) %>% 
#  mutate('2012-2013' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2012-09-01", "2013-03-31"))) %>% 
#  mutate('2013-2014' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2013-09-01", "2014-03-31"))) %>% 
#  mutate('2014-2015' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2014-09-01", "2015-03-31"))) %>% 
#  mutate('2015-2016' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2015-09-01", "2016-03-31"))) %>% 
#  mutate('2016-2017' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2016-09-01", "2017-03-31"))) %>% 
#  mutate('2017-2018' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2017-09-01", "2018-03-31"))) %>% 
#  mutate('2018-2019' = c(Pregstart, Pregend) %overlaps% 
#         as.Date(c("2018-09-01", "2019-03-31"))) %>% 
#  mutate('2019-2020' = c(Pregstart, Pregend) %overlaps% 
#           as.Date(c("2019-09-01", "2020-03-31")))



  
  
  #OR




#df2v2 <- df2 %>%
#  select(`Patient key`, Age , Ethnicity,
#         Diabetes, `Kidney disease`, CCG, Pregstart, Pregend) %>%
#  rowwise() %>%
#  mutate (
#    influsea = case_when (
#        c(Flushot) %overlaps% as.Date(c("2010-09-01", "2011-03-31")) ~ '2010-2011',
#        c(Flushot) %overlaps% as.Date(c("2011-09-01", "2012-03-31")) ~ '2011-2012',
#        c(Flushot) %overlaps% as.Date(c("2012-09-01", "2013-03-31")) ~ '2012-2013',
#        c(Flushot) %overlaps% as.Date(c("2013-09-01", "2014-03-31")) ~ '2013-2014',
#        c(Flushot) %overlaps% as.Date(c("2014-09-01", "2015-03-31")) ~ '2014-2015',
#        c(Flushot) %overlaps% as.Date(c("2015-09-01", "2016-03-31")) ~ '2015-2016',
#        c(Flushot) %overlaps% as.Date(c("2016-09-01", "2017-03-31")) ~ '2016-2017',
#        c(Flushot) %overlaps% as.Date(c("2017-09-01", "2018-03-31")) ~ '2017-2018',
#        c(Flushot) %overlaps% as.Date(c("2018-09-01", "2019-03-31")) ~ '2018-2019',
#        c(Flushot) %overlaps% as.Date(c("2019-09-01", "2020-03-31")) ~ '2019-2020'
        
#    )
#  )


#OR

library(tidyverse)
library(DescTools)


df2<-data_frames[[2]]


#create new columns to show number of days of overlap between a pregnancy and an influenza season
df2v3  <- df2 %>% 
  rowwise() %>% 
  mutate('2010-2011' = Overlap (c(Pregstart, Pregend), as.Date(c("2010-09-01", "2011-03-31")))) %>% 
  mutate('2011-2012' = Overlap (c(Pregstart, Pregend), as.Date(c("2011-09-01", "2012-03-31")))) %>% 
  mutate('2012-2013' = Overlap (c(Pregstart, Pregend), as.Date(c("2012-09-01", "2013-03-31")))) %>% 
  mutate('2013-2014' = Overlap (c(Pregstart, Pregend), as.Date(c("2013-09-01", "2014-03-31")))) %>% 
  mutate('2014-2015' = Overlap (c(Pregstart, Pregend), as.Date(c("2014-09-01", "2015-03-31")))) %>% 
  mutate('2015-2016' = Overlap (c(Pregstart, Pregend), as.Date(c("2015-09-01", "2016-03-31")))) %>% 
  mutate('2016-2017' = Overlap (c(Pregstart, Pregend), as.Date(c("2016-09-01", "2017-03-31")))) %>% 
  mutate('2017-2018' = Overlap (c(Pregstart, Pregend), as.Date(c("2017-09-01", "2018-03-31")))) %>% 
  mutate('2018-2019' = Overlap (c(Pregstart, Pregend), as.Date(c("2018-09-01", "2019-03-31")))) %>% 
  mutate('2019-2020' = Overlap (c(Pregstart, Pregend), as.Date(c("2019-09-01", "2020-03-31"))))


#create column with unique consecutive numbers
df2v3<-tibble::rowid_to_column(df2v3, "ID")

#delete columns
df2v3 <- df2v3[, -c(2:9)]

#gather to show each season for each pregnancy
df2v3 <- df2v3 %>%
  gather("fluseason", "overlap", 2:11)

#slice to maintain season with which a pregnancy has the most overlap
df2v3 <-
  df2v3 %>%
  group_by(`ID`) %>%
  slice(which.max(`overlap`))


df2v4<- df2 

df2v4 <- tibble::rowid_to_column(df2v4, "ID")

df2v4<- left_join(df2v4,df2v3,by = "ID")


#Demographics table
library(table1)


table1(~ Age + Ethnicity + CCG | fluseason  , data=df2v4, overall="Total")




