
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

#replace na with 0 (what do we do with missing data???)
df2v5 <- df2v5 %>% dplyr::mutate(flushotmatch = replace_na(flushotmatch, 0))


#creates dataframe cross tabulation
del<- df2v5 %>% group_by(flushotmatch, Ethnicity) %>% 
  summarise(freq = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = flushotmatch, values_from = freq, values_fill = list(freq = 0)) 

#create table for chisq
del2<-table(df2v5$Ethnicity,df2v5$flushotmatch)

#chi square test example (repeat for other variables)
chisq.test(del2)

 
# for interpretation and worked example
#http://www.biostathandbook.com/chiind.html
#https://rcompanion.org/rcompanion/b_05.html
#https://mran.microsoft.com/snapshot/2016-10-12/web/packages/fifer/fifer.pdf

#if chi square test is significant do post hoc test with bonferroni correction
library(rcompanion)

pairwiseNominalIndependence(del2,
                            fisher = FALSE,
                            gtest  = FALSE,
                            chisq  = TRUE,
                            method = "bonferroni")

or

library(fifer)
chisq.post.hoc(del2, test = c("fisher.test"),
                         popsInRows = TRUE,
                         control = c("bonferroni"),
                         digits = 4)
