# Author: Ntando & Evander
#
# Date: 21 April 2024
#
# Description: Make changes in the fixations and remove screen 0, 8 [treatment grp 1-4], and 10 [treatment grp 5-8]
#
# Github link:



# packages ----------------------------------------------------------------

library(tidyverse) # package for data manipulation and visualization.
library(janitor) # package for cleaning and tidying data.
# library("devtools")
# install_github("tmalsburg/saccades/saccades", 
#                dependencies=TRUE)
library(saccades) #

# filter data -------------------------------------------------------------

subject_data_nw <- bind_rows(subject_data_1,
                              subject_data_2) %>%  # combine the data sets
  filter(screen_num != 0, screen_num == '0') %>%  # remove screen number 0
  mutate(treatment = case_when(
    subject %in% 1:33 ~ 1,
    subject %in% 34:66 ~ 2,
    subject %in% 67:96 ~ 3,
    subject %in% 97:128 ~ 4,
    subject %in% 129:160 ~ 5,
    subject %in% 161:193 ~ 6,
    subject %in% 194:226 ~ 7,
    subject %in% c(88, 114, 248) ~ 0,
    TRUE ~ 8 # Handle other cases if needed
  )) %>% 
  
  # Calculate groups based on treatment
  mutate(groups = case_when(treatment %in% 1:4 ~ "group 1",
                            T ~ "group 2")) %>%
  # mutate(groups = case_when(treatment %in% 1:4 ~ "group 1",
  #                         T ~ "group 2")) %>% 
  # Calculate selection based on groups and screen number conditions
  mutate(selection = case_when(groups == "group 1" & screen_num == 8 ~ 1, #screen num 8 & Teatment 1-4
                               groups == "group 2" & screen_num == 10 ~ 1, #screen num 10 & Teatment 5-8 
                               T ~ 0)) %>% 
  # Filter rows based on selection
  filter(selection != 1) %>% # remove selection
  # Remove the temporary selection column
  select(-selection) 



