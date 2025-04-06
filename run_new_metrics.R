library(lme4)
library(tidyverse)
library(rlang)

datasets <- c(
  # 'albright/albright_new.csv',
  # 'daland/daland_new.csv',
  # # 'needle/needle_new.csv',
  # 'polish/polish_new.csv',
  # 'scholes/scholes_new.csv',
  'spanish/spanish_new.csv',
  'turkish/turkish_new.csv',
  'white_hayes/white_hayes_new.csv'
)

models <- tribble(
  ~model_name, ~uni_param, ~bi_param,
  'cond_nonpos_wb_prod', 'uni_nonpos_prod', 'bi_nonpos_cond_wb_prod',
  'cond_nonpos_wb_sum', 'uni_nonpos_sum', 'bi_nonpos_cond_wb_sum',
  'cond_nonpos_nwb_prod', 'uni_nonpos_prod', 'bi_nonpos_cond_nwb_prod',
  'cond_nonpos_nwb_sum', 'uni_nonpos_sum', 'bi_nonpos_cond_nwb_sum',
  'joint_nonpos_wb_prod', 'uni_nonpos_prod', 'bi_nonpos_joint_wb_prod',
  'joint_nonpos_wb_sum', 'uni_nonpos_sum', 'bi_nonpos_joint_wb_sum',
  'joint_nonpos_nwb_prod', 'uni_nonpos_prod', 'bi_nonpos_joint_nwb_prod',
  'joint_nonpos_nwb_sum', 'uni_nonpos_sum', 'bi_nonpos_joint_nwb_sum',
  'cond_pos_wb_prod', 'uni_pos_prod', 'bi_pos_cond_wb_prod',
  'cond_pos_wb_sum', 'uni_pos_sum', 'bi_pos_cond_wb_sum',
  'cond_pos_nwb_prod', 'uni_pos_prod', 'bi_pos_cond_nwb_prod',
  'cond_pos_nwb_sum', 'uni_pos_sum', 'bi_pos_cond_nwb_sum',
  'joint_pos_wb_prod', 'uni_pos_prod', 'bi_pos_joint_wb_prod',
  'joint_pos_wb_sum', 'uni_pos_sum', 'bi_pos_joint_wb_sum',
  'joint_pos_nwb_prod', 'uni_pos_prod', 'bi_pos_joint_nwb_prod',
  'joint_pos_nwb_sum', 'uni_pos_sum', 'bi_pos_joint_nwb_sum',
)

results <- tribble(~dataset, ~model_type, ~AIC)

for (dataset in datasets) {
  data <- read_csv(dataset) %>%
    mutate(across(everything(), ~replace(., . == -Inf  , -50)))
  data[3:ncol(data)] <- scale(data[3:ncol(data)]) 
  
  if (dataset == 'albright/albright_new.csv') {
    ratings <- read_csv('albright/albright_hayes_2003.csv') %>%
      select(Verb_apra, `Phonological Well-Formedness Rating (PhonWF)`) %>%
      drop_na() %>%
      rename(rating = `Phonological Well-Formedness Rating (PhonWF)`,
             word = Verb_apra) %>%
      mutate(word = ifelse(word == 'F LEH', "F L EH T", word))
    
    data <- data %>%
      inner_join(ratings) 
    
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- glm(as.formula(str_glue("rating ~ {row$uni_param} * {row$bi_param}")), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'daland/daland_new.csv') {
    ratings <- read_csv('daland/daland-scores.csv')
    data$rating <- ratings$likert_rating
    
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- glm(as.formula(str_glue("rating ~ {row$uni_param} * {row$bi_param}")), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'needle/needle_new.csv') {
    ratings <- read_csv('needle/needle_data.csv')  %>%
      select(subjID, cmu, rating) 
    data$rating <- ratings$rating
    data$subject <- ratings$subjID
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- lmer(str_glue("rating ~ {row$uni_param} * {row$bi_param} + (1|word) + (1|subject)"), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'polish/polish_new.csv') {
    ortho_key <- read_tsv('polish/IbexHeadsV.txt', col_names=FALSE) %>%
      mutate(word = str_replace(X1, " V", ""),
             ihead=X3) %>%
      select(word, ihead)
    
    ratings <- read_csv('polish/all_legit_data.csv') %>%
      rename(full_word = word) %>%
      inner_join(ortho_key) %>%
      select(full_word, response, subj, word)
    
    data <- data %>% 
      inner_join(ratings)
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- lmer(str_glue("response ~ {row$uni_param} * {row$bi_param} + (1|full_word) + (1|subj)"), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'scholes/scholes_new.csv') {
    ratings <- read_csv('scholes/new_scholes_cleaned_metric_output.csv') %>%
      select(word, rating)
    data <- data %>%
      inner_join(ratings)
    
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- glm(str_glue("rating ~ {row$uni_param} * {row$bi_param}"), data=data, family="binomial")
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'spanish/spanish_new.csv') {
    ratings <- read_csv('spanish/new_spanish_responses_phonotactics_paper_scored.csv') %>%
      select(ID, response, word)
    data <- data %>%
      unique() %>%
      inner_join(ratings)
    model <- lmer(str_glue("response ~ {row$uni_param} * {row$bi_param} + (1|word) + (1|ID)"), data=data)
  }
  else if (dataset == 'turkish/turkish_new.csv') {
    ratings <- read_csv('turkish/new_turkish_responses_phonotactics_paper_scored.csv') %>%
      select(ID, response, word)
    data <- data %>% 
      unique() %>%
      inner_join(ratings)
    
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- lmer(str_glue("response ~ {row$uni_param} * {row$bi_param} + (1|word) + (1|ID)"), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
  else if (dataset == 'white_hayes/white_hayes_new.csv') {
    ratings <- read_csv('white_hayes/white_hayes_2012.csv') %>%
      mutate(ARPA = ifelse(ARPA == 'T W I K AH N', "T W IH K AH N", ARPA)) %>%
      mutate(ARPA = ifelse(ARPA == 'C AH N IH F L', "K AH N IH F L", ARPA)) %>%
      select(LogResponse, ARPA, Subject) %>%
      rename(rating = LogResponse,
             word = ARPA,
             subject = Subject)
    
    data <- data %>%
      unique() %>%
      inner_join(ratings)
    
    for (model_idx in 1:nrow(models)) {
      row <- models[model_idx, ]
      model <- lmer(str_glue("rating ~ {row$uni_param} * {row$bi_param} + (1|subject)"), data=data)
      results <- rbind(results, 
                       tribble(~dataset, ~model_name, ~AIC,
                               dirname(dataset), row$model_name, AIC(model)))
    }
  }
}

bar <- results %>%
  group_by(dataset) %>%
  separate(model_name, c('prob', 'pos', 'wb', 'agg'), remove=FALSE) %>%
  filter(agg == 'prod') %>%
  mutate(scaled_aic=c(scale(AIC)))

bar %>%
  group_by(pos) %>%
  summarize(mean_aic = mean(scaled_aic)) %>%
  arrange(-mean_aic)

big_model <- glm(scaled_aic ~ prob + pos * wb, data=bar)
summary(big_model)
