
#Purpose of this script is to show procedure for running run chi square tests 
#Here ethnicity is a categorical nominal variable and flushotmatch is categorical
#binary variable (equivalent to vaccinated yes=1, no=0)


#Create table for chisquare test
test1<-table(df2v5$Ethnicity,df2v5$flushotmatch)

#run chisquare test
chisq.test(test1)

# for interpretation and worked examples
#http://www.biostathandbook.com/chiind.html
#https://rcompanion.org/rcompanion/b_05.html
#https://mran.microsoft.com/snapshot/2016-10-12/web/packages/fifer/fifer.pdf

#if chi square test is significant, then do pairwise comparisons
#chisquare post hoc tests with bonferroni correction
library(rcompanion)

pairwiseNominalIndependence(test1,
                            fisher = FALSE,
                            gtest  = FALSE,
                            chisq  = TRUE,
                            method = "bonferroni")

#or

library(fifer)
chisq.post.hoc(test1, test = c("fisher.test"),
                         popsInRows = TRUE,
                         control = c("bonferroni"),
                         digits = 4)

##Create barchart y-axis is the vaccination uptake proportion and x-axis is ethnicity
# Add sums and confidence intervals to del (i.e. dataframe version of del2)
# Need help explaining how function that calculates confidence intervals works???


#creates dataframe version of test1 called test2
test2<- df2v5 %>% group_by(flushotmatch, Ethnicity) %>% 
  summarise(freq = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = flushotmatch, values_from = freq, values_fill = list(freq = 0)) 


test2 <-
  mutate(test2,
         Sum = `1` + `0`)

test2 <-
  mutate(test2,
         Prop = `1` / `Sum`,
         low.ci = apply(test2[c("1", "0")], 1,
                        function(y) binom.test(y['1'], y['0'])$ conf.int[1]),
         high.ci = apply(test2[c("1", "0")], 1,
                         function(y) binom.test(y['1'], y['0'])$ conf.int[2])
  )

test2


### Plot (Bar chart plot)

library(ggplot2)

ggplot(test2,
       aes(x=Ethnicity, y=Prop)) +
  geom_bar(stat="identity", fill="gray40",
           colour="black", size=0.5,
           width=0.7) +
  geom_errorbar(aes(ymax=high.ci, ymin=low.ci),
                width=0.2, size=0.5, color="black") +
  xlab("Ethnicity") +
  ylab("vaccine uptake proportion") +
  scale_x_discrete(labels=c("Black", "Mixed",
                            "Other","White")) +
  ## ggtitle("Main title") +
  theme(axis.title=element_text(size=14, color="black",
                                face="bold", vjust=3)) +
  theme(axis.text = element_text(size=12, color = "gray25",
                                 face="bold")) +
  theme(axis.title.y = element_text(vjust= 1.8)) +
  theme(axis.title.x = element_text(vjust= -0.5))



#is there an association with age group and vaccine uptake
# This test is appropriate only when one variable has two levels and the other variable is ordinal
# for interpretation see:
#https://www.rdocumentation.org/packages/DescTools/versions/0.99.36/topics/CochranArmitageTest

test4<-table(df2v5$age_groups, df2v5$flushotmatch)
CochranArmitageTest(test4)

#or

prop.trend.test(test4[,1], apply(test4,1, sum))


#chi square test trend - is there association between year and vaccination uptake
# This test is appropriate only when one variable has two levels and the other variable is ordinal
# for interpretation see:
#https://www.rdocumentation.org/packages/DescTools/versions/0.99.36/topics/CochranArmitageTest


test3<-table(df2v5$fluseason, df2v5$flushotmatch)
CochranArmitageTest(test3)

#or

prop.trend.test(test3[,1], apply(test3,1, sum))

