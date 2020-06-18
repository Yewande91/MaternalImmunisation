
#create vaccination coverage table stratified by season 
df3<-data_frames[[3]]


df3 <- tibble::rowid_to_column(df3, "ID")

df2v5<- df2v4 %>%
  left_join(select(df3,`ID`,`Flushot`),by = "ID")



df2v5 <- df2v5 %>%
 select(ID, `Patient key`, Age , Ethnicity, Diabetes,`Kidney disease`, CCG, Pregstart, Pregend, fluseason,
        overlap, Flushot) %>%
 rowwise() %>%
  mutate (
    flushotseason = case_when (
        c(Flushot) %overlaps% as.Date(c("2010-09-01", "2011-03-31")) ~ '2010-2011',
        c(Flushot) %overlaps% as.Date(c("2011-09-01", "2012-03-31")) ~ '2011-2012',
        c(Flushot) %overlaps% as.Date(c("2012-09-01", "2013-03-31")) ~ '2012-2013',
        c(Flushot) %overlaps% as.Date(c("2013-09-01", "2014-03-31")) ~ '2013-2014',
        c(Flushot) %overlaps% as.Date(c("2015-09-01", "2016-03-31")) ~ '2015-2016',
        c(Flushot) %overlaps% as.Date(c("2016-09-01", "2017-03-31")) ~ '2016-2017',
        c(Flushot) %overlaps% as.Date(c("2017-09-01", "2018-03-31")) ~ '2017-2018',
        c(Flushot) %overlaps% as.Date(c("2018-09-01", "2019-03-31")) ~ '2018-2019',
        c(Flushot) %overlaps% as.Date(c("2019-09-01", "2020-03-31")) ~ '2019-2020'

    )
  )


#does fluseason and flushotseason match
df2v5<- df2v5 %>%
  mutate(flushotmatch = if_else(flushotseason == fluseason , 1,0))

#replace na with 0 (what do we do with missing data)
df2v5 <- df2v5 %>% dplyr::mutate(flushotmatch = replace_na(flushotmatch, 0))


del<- table(df2v5$Ethnicity, df2v5$flushotmatch)

