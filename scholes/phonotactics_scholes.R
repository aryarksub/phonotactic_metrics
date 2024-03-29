library(readr)
library(tidyverse)
library(lme4)
library(lmerTest)

rm(list=ls())

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/scholes")

scholes_data <- read_csv("scholes_cleaned_metric_output.csv")
scholes_data[3:16] = scale(scholes_data[3:16])

uni_bi_model = glm(rating ~ uni_prob * bi_prob, data=scholes_data, family="binomial")
summary(uni_bi_model)

pos_uni_bi_model = glm(rating ~ pos_uni_score * pos_bi_score, data=scholes_data, family="binomial")
summary(pos_uni_bi_model)

pos_uni_bi_smooth_model = glm(rating ~ pos_uni_score_smoothed * pos_bi_score_smoothed, data=scholes_data, family="binomial")
summary(pos_uni_bi_smooth_model)

uni_bi_smoothed_model = glm(rating ~ uni_prob * bi_prob_smoothed, data=scholes_data, family="binomial")
summary(uni_bi_smoothed_model)

uni_bi_freq_model = glm(rating ~ uni_prob_freq_weighted * bi_prob_freq_weighted, data=scholes_data, family="binomial")
summary(uni_bi_freq_model)

uni_bi_freq_smooth_model = glm(rating ~ uni_prob_freq_weighted * bi_prob_freq_weighted_smoothed, data=scholes_data, family="binomial")
summary(uni_bi_freq_smooth_model)

pos_uni_bi_freq_model = glm(rating ~ pos_uni_score_freq_weighted * pos_bi_score_freq_weighted, data=scholes_data, family="binomial")
summary(pos_uni_bi_freq_model)

pos_uni_bi_freq_smooth_model = glm(rating ~ pos_uni_score_freq_weighted_smoothed * pos_bi_score_freq_weighted_smoothed, data=scholes_data, family="binomial")
summary(pos_uni_bi_freq_smooth_model)

all_model_names = vector()
all_models = vector()
for (var in ls()) {
    if (endsWith(var, "model")) {
        all_model_names = append(all_model_names, var)
        all_models = append(all_models, get(var))
    }
}

num_models = length(all_model_names)

intercept = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
bi_coef = vector(mode="numeric", length=num_models)
interaction_coef = vector(mode="numeric", length=num_models)
AIC = vector(mode="numeric", length=num_models)

for (index in 1:num_models) {
    coef_index = 30*(index-1) + 1
    aic_index = 30*(index-1) + 11
    intercept[index] = all_models[[coef_index]][1]
    uni_coef[index] = all_models[[coef_index]][2]
    bi_coef[index] = all_models[[coef_index]][3]
    interaction_coef[index] = all_models[[coef_index]][4]
    AIC[index] = all_models[[aic_index]]
}

df = data.frame(intercept, uni_coef, bi_coef, interaction_coef, AIC, row.names=all_model_names)
df

sorted_df = df[order(df$AIC),]
sorted_df

