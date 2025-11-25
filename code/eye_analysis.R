


# packages ----------------------------------------------------------------

library(tidyverse)
library(data.table)
library("GGally")


# data --------------------------------------------------------------------

#df <- read_csv("data/trial_stats_data.csv")


df <- fread("data/trial_stats_data.csv")



# filter the data
data <- df %>% 
  as_tibble() %>% # make it a tibble
  group_by(subject, trial_1) %>% 
  mutate(subject = as_factor(subject), # have these as factors
         trial_1 = as_factor(trial_1),
         screen_num = as_factor(screen_num)) %>% 
  slice_head(n = 1) %>% # get the first row for each subject and row
  select(-value,
         -mean_number_of_trials, # redundant
         -starts_with("sd")) # remove the path and standard deviations




# eda ---------------------------------------------------------------------


data %>% 
  select(subject) %>% 
  class()
  # summary()
  # group_by(trial_1) %>% 
  # summarise(n = n(),
  #           mean_visits = mean(num_visit_screen)) %>% 
  # View()

  
  
data %>% 
  ungroup() %>% 
  select(-subject, -trial_1) %>% 
  ggpairs(.)+theme_bw()
