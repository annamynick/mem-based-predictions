# pattern completion reviewer comment about whether linear mixed effects models yield the same outcome as ANOVA

library(lme4)
library(lmerTest)
library(effectsize)
library(performance)

# Fill this out based on individual computer's file structure 
path_to_data = "~/Dropbox_Lab/projects/pattern-completion/analysis-scripts-CurrBioB-submission-for-github/mem-based-predictions-main/data-mats/"


# Experiment 1 (familiar) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# load data 
tda = read.csv(paste0(path_to_data,"tda_lf_Experiment1.csv"))

# make things factors 
tda$targetName = as.factor(tda$targetName)
tda$condition = as.factor(tda$condition)
tda$subject_id = as.factor(tda$subject_id)

tda$targetNameSide <- paste(tda$targetName, tda$targetSide, sep = "_")
tda$targetNameSide <- as.factor(tda$targetNameSide)


# get inverse square root of response time 
tda$inv_sqrt_rt = tda$rt^(-1/2)

# Using random intercepts for subjects and scenes; 
model1 <- lmer(inv_sqrt_rt ~ condition + (1 | subject_id) + (1 | targetName), data = tda, REML = F)
summary(model1)
anova(model1)
check_model(model1)

# Find effect size (partial eta squared)
eta_squared(model1, partial = TRUE)


# Experiment 2 (unfamiliar) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tda = read.csv(paste0(path_to_data,"tda_lf_Experiment2.csv"))

# make things factors 
tda$targetName = as.factor(tda$targetName)
tda$condition = as.factor(tda$condition)
tda$subject_id = as.factor(tda$subject_id)

tda$targetNameSide <- paste(tda$targetName, tda$targetSide, sep = "_")
tda$targetNameSide <- as.factor(tda$targetNameSide)

# get inverse square root of response time 
tda$inv_sqrt_rt = tda$rt^(-1/2)

# Using random intercepts for subjects and scenes; 
model1 <- lmer(inv_sqrt_rt ~ condition + (1 | subject_id) + (1 | targetName), data = tda, REML = F)
summary(model1)
anova(model1)
check_model(model1)

# Find effect size (partial eta squared)
eta_squared(model1, partial = TRUE)


# Experiment 3 (arrows) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tda3 = read.csv(paste0(path_to_data,"tda_lf_Experiment3.csv"))

# make things factors 
tda3$targetName = as.factor(tda3$targetName)
tda3$primeCondition = as.factor(tda3$primeCondition)
tda3$arrowValidity = as.factor(tda3$arrowValidity)
tda3$subject_id = as.factor(tda3$subject_id)

tda3$targetNameSide <- paste(tda3$targetName, tda3$targetSide, sep = "_")
tda3$targetNameSide <- as.factor(tda3$targetNameSide)

# get inverse square root of response time 
tda3$inv_sqrt_rt = tda3$rt^(-1/2)

# Using random intercepts for subjects and scenes; 
model3 <- lmer(inv_sqrt_rt ~ primeCondition * arrowValidity + (1 | subject_id) + (1 | targetName), data = tda3, REML = F)
summary(model3)
anova(model3)
check_model(model3)

# Find effect size (partial eta squared)
eta_squared(model3, partial = TRUE)


# Experiment 4 (Globally-reversed / Spatially displaced) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tda = read.csv(paste0(path_to_data,"tda_lf_Experiment6.csv"))
#Experiment 4 in Current Biology manuscript is named  Experiment 6 in the code 

# make things factors 
tda$targetName = as.factor(tda$targetName)
tda$condition = as.factor(tda$condition)
tda$subject_id = as.factor(tda$subject_id)

tda$targetNameSide <- paste(tda$targetName, tda$targetSide, sep = "_")
tda$targetNameSide <- as.factor(tda$targetNameSide)

# get inverse square root of response time 
tda$inv_sqrt_rt = tda$rt^(-1/2)

# Using random intercepts for subjects and scenes; 
model1 <- lmer(inv_sqrt_rt ~ condition + (1 | subject_id) + (1 | targetName), data = tda, REML = F)
summary(model1)
anova(model1)
check_model(model1)

# Find effect size (partial eta squared)
eta_squared(model1, partial = TRUE)
