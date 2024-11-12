# install.packages("ez"); install.packages("ggplot2"); install.packages("nlme");
# install.packages("pastecs"); install.packages("reshape"); 
# install.packages ("WRS", repos="http://R-Forge.R-project.org")

# script initially named: mixed_anova_expt1and2

# library(ez); 
library(ggplot2);
library(nlme);
# library(pastecs);
library(reshape);
# library(WRS2);
library(performance)

# Load Experiment 1 data 
tda_e1 = read.csv('/Users/annamynick/Dartmouth College Dropbox/Anna Mynick/projects/pattern-completion/analysis-scripts-CurrBioB-submission-for-github/mem-based-predictions-main/data-mats/tda_lf_Experiment1.csv')

# make things factors 
tda_e1$targetName = as.factor(tda_e1$targetName)
tda_e1$condition = as.factor(tda_e1$condition)
tda_e1$subject_id = as.factor(tda_e1$subject_id)

tda_e1$targetNameSide <- paste(tda_e1$targetName, tda_e1$targetSide, sep = "_")
tda_e1$targetNameSide <- as.factor(tda_e1$targetNameSide)

tda_e1$expt = 'Experiment1'

# load Experiment 2 data 
tda_e2 = read.csv('/Users/annamynick/Dartmouth College Dropbox/Anna Mynick/projects/pattern-completion/analysis-scripts-CurrBioB-submission-for-github/mem-based-predictions-main/data-mats/tda_lf_Experiment2.csv')

# make things factors 
tda_e2$targetName = as.factor(tda_e2$targetName)
tda_e2$condition = as.factor(tda_e2$condition)
tda_e2$subject_id = as.factor(tda_e2$subject_id)

tda_e2$targetNameSide <- paste(tda_e2$targetName, tda_e2$targetSide, sep = "_")
tda_e2$targetNameSide <- as.factor(tda_e2$targetNameSide)

tda_e2$expt = 'Experiment2'

# Combine data for experiment 1 and experiment 2
library(dplyr)
whit_tda_e1 <- tda_e1 %>% select(subject_id, condition, expt, rt, targetName)
whit_tda_e2 <- tda_e2 %>% select(subject_id, condition, expt, rt, targetName)
tda_edata <- rbind(whit_tda_e1,whit_tda_e2)

# Using random intercepts for subjects (subjects can start at different mean RTs) and scenes; 
tda_edata$inv_sqrt_rt = (tda_edata$rt)^(-1/2)
model5 = lmer(inv_sqrt_rt ~ condition * expt + (1 | subject_id) + (1 | targetName), data = tda_edata, REML = F)
summary(model5)
anova(model5)
quartz()
check_model(model5)

library(effectsize)
eta_squared(model5, partial=TRUE)
