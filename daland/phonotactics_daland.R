library(readr)
library(ggplot2)
library(MASS)
library(ordinal)

rm(list=ls())

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/daland")

# new file uses unigram smoothing, scale columns 3 to 18
# if using original file, don't use "new_" prefix and scale columns 3 to 16
daland_data <- read_csv("new_daland_cleaned_metric_output.csv")
daland_data[3:18] = scale(daland_data[3:18])

uni_bi_model = glm(rating ~ uni_prob * bi_prob, data=daland_data)
summary(uni_bi_model)

pos_uni_bi_model = glm(rating ~ pos_uni_score * pos_bi_score, data = daland_data)
summary(pos_uni_bi_model)

pos_uni_bi_smoothed_model = glm(rating ~ pos_uni_score_smoothed * pos_bi_score_smoothed, 
                                 data = daland_data)
summary(pos_uni_bi_smoothed_model)

# for original metric output, use uni_prob column instead of uni_prob_smoothed
uni_bi_smoothed_model = glm(rating ~ uni_prob_smoothed * bi_prob_smoothed, data = daland_data)
summary(uni_bi_smoothed_model)

uni_bi_freq_model = glm(rating ~ uni_prob_freq_weighted * bi_prob_freq_weighted, data=daland_data)
summary(uni_bi_freq_model)

# for original metric output, use uni_prob_freq_weighted column instead of uni_prob_freq_weighted_smoothed
uni_bi_freq_smooth_model = glm(rating ~ uni_prob_freq_weighted_smoothed * bi_prob_freq_weighted_smoothed,
                             data=daland_data)
summary(uni_bi_freq_smooth_model)

pos_uni_bi_freq_model = glm(rating ~ pos_uni_score_freq_weighted * pos_bi_score_freq_weighted,
                             data=daland_data)
summary(pos_uni_bi_freq_model)

pos_uni_bi_freq_smoothed_model = glm(rating ~ pos_uni_score_freq_weighted_smoothed * pos_bi_score_freq_weighted_smoothed,
                                      data=daland_data)
summary(pos_uni_bi_freq_smoothed_model)

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
