library(readr)
library(tidyverse)
library(lme4)
library(lmerTest)

setwd("C:/hplaptop/4thYearUCI/PhonotacticsResearch/polish")

# new file uses unigram smoothing, scale columns 27 to 42
# if using original file, don't use "new_" prefix and scale columns 27 to 40
polish_data <- read_csv("polish/new_cleaned_response_data.csv")
polish_data[27:42] = scale(polish_data[27:42])

uni_bi_model = lmer(response ~ uni_prob * bi_prob + (1|word) + (1|subj), data=polish_data)
summary(uni_bi_model)

pos_uni_bi_model = lmer(response ~ pos_uni_score * pos_bi_score + (1|word) + (1|subj), data=polish_data)
summary(pos_uni_bi_model)

pos_uni_bi_smooth_model = lmer(response ~ pos_uni_score_smoothed * pos_bi_score_smoothed + (1|word) + (1|subj), data=polish_data)
summary(pos_uni_bi_smooth_model)

# for original metric output, use uni_prob column instead of uni_prob_smoothed
uni_bi_smoothed_model = lmer(response ~ uni_prob_smoothed * bi_prob_smoothed + (1|word) + (1|subj), data=polish_data)
summary(uni_bi_smoothed_model)

uni_bi_freq_model = lmer(response ~ uni_prob_freq_weighted * bi_prob_freq_weighted + (1|word) + (1|subj), data=polish_data)
summary(uni_bi_freq_model)

# for original metric output, use uni_prob_freq_weighted column instead of uni_prob_freq_weighted_smoothed
uni_bi_freq_smooth_model = lmer(response ~ uni_prob_freq_weighted_smoothed * bi_prob_freq_weighted_smoothed + (1|word) + (1|subj), data=polish_data)
summary(uni_bi_freq_smooth_model)

pos_uni_bi_freq_model = lmer(response ~ pos_uni_score_freq_weighted * pos_bi_score_freq_weighted + (1|word) + (1|subj), data=polish_data)
summary(pos_uni_bi_freq_model)

pos_uni_bi_freq_smooth_model = lmer(response ~ pos_uni_score_freq_weighted_smoothed * pos_bi_score_freq_weighted_smoothed + (1|word) + (1|subj), data=polish_data)
summary(pos_uni_bi_freq_smooth_model)

all_model_names = vector()
all_models = vector()
for (var in ls()) {
    if (endsWith(var, "model")) {
        all_model_names = append(all_model_names, var)
        all_models = append(all_models, get(var))
    }
}

model_comp = do.call(anova, as.list(all_models))
model_comp

num_models = length(all_models)

fixed_effects = sapply(all_models, FUN=fixef)

intercept = vector(mode="numeric", length=num_models)
uni_coef = vector(mode="numeric", length=num_models)
bi_coef = vector(mode="numeric", length=num_models)
interaction_coef = vector(mode="numeric", length=num_models)

for (index in 1:num_models) {
    intercept[index] = fixed_effects[(index-1) * 4 + 1]
    uni_coef[index] = fixed_effects[(index-1) * 4 + 2]
    bi_coef[index] = fixed_effects[(index-1) * 4 + 3]
    interaction_coef[index] = fixed_effects[(index-1) * 4 + 4]
}

df = data.frame(intercept, uni_coef, bi_coef, interaction_coef, model_comp[2], model_comp[3], model_comp[4], row.names=all_model_names)
df

sorted_df = df[order(df$AIC),]
sorted_df
