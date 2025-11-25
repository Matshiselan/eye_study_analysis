################################################################################

## Authors: Evander Nyoni & Ntandoyenkosi Matshisela

## Description: Eye Tracking Study functions

## Date: 2 February 2024

## GitHub: --

################################################################################


# Load necessary R packages for data analysis 

library(tidyverse) # package for data manipulation and visualization.
library(janitor) # package for cleaning and tidying data.
# library("devtools")
# install_github("tmalsburg/saccades/saccades", 
#                dependencies=TRUE)
library(saccades) # package for analyzing eye movement data.



# Load external functions from "functions.R"
source("functions.R")


# Reading subject data ----------------------------------------------------


# List all folders in the specified directory containing subject data.
subject_folders <- list.files("PhD data shared/Mapped data per subject (per 
                              trial)") 

# Create full paths for each subject folder.
subject_folders <- str_c("PhD data shared/Mapped data per subject (per 
                         trial)", '/', subject_folders)




# Getting subject_data ---------------------------------------------------------

# Convert list of folders to tibble and read CSV files
subject_data <- subject_folders %>% 
  as_tibble() %>% 
  mutate(data = map(.x = value, .f = ~csv_reader(.x))) %>% 
  unnest(data)

# Filter rows with missing values in specific columns
subject_data_1 <- subject_data %>% 
  filter(is.na(`Subject	Treatment	screen_num	num_visit_screen
                x	y	time	trial`)) %>% 
  select(value:trial) %>% 
  clean_names() 



# Separate columns in subject_data DataFrame -----------------------------------


# Filter out rows with missing values in specific columns
subject_data_2 <- subject_data %>% 
  filter(!is.na(`Subject	Treatment	screen_num	num_visit_screen	x	y	time	
                 trial`)) %>% 
  # Select relevant columns
  select(value, `Subject	Treatment	screen_num	num_visit_screen	x	y	time	
         trial`) %>% 
  # Separate the combined column into individual columns
  separate(col = `Subject	Treatment	screen_num	num_visit_screen	x	y	time	
           trial`,
           into = c("subject", "treatment",	"screen_num",	"num_visit_screen",	
                    "x",	"y",	"time",	"trial"),
           sep = '\t') %>% 
  # Convert columns from character to double
  mutate(across(.cols = subject:trial, .fns = ~as.double(.x)))


# Combine the two data sets vertically
subject_data_fin <- bind_rows(subject_data_1,
                              subject_data_2)



# Saving the data as csv or rds files-------------------------------------------


# Save as csv
write_csv(subject_data_fin, 'subject_data/subject_data.csv')


# Save as rds
# write_rds(subject_data_fin,
          # 'subject_data/subject_data.rds')


# Load/Read the csv data
subject_data_fin <- read_csv("data/subject_data.csv")


subject_data_fin %>% 
  filter(screen_num ==0           )

# Calculate trial statistics for each subject ---------------------------------

trial_stats <- subject_data_fin %>%
  # Create a new column trial_1 and group by subject and trial_1
  mutate(trial_1= trial) %>% 
  group_by(subject, trial_1) %>% 
  # Nest the data for each group
  nest(data = c(treatment, screen_num, num_visit_screen, x, y, time, trial)) %>% 
  # Apply process_possibly function to each nested data
  mutate(stats = map(data, ~ process_possibly(.x))) %>% 
  # Apply pivot_wider_and_clean function to each set of statistics
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  # Unnest the resulting data frame
  unnest(stats) 

# View the trial_stats data frame
trial_stats %>% view()


# Calculate statistics for each subject in the dataset ----------------------


subject_stats <- subject_data_fin %>%
  # Group data by subject
  group_by(subject) %>%
  # Nest data for each subject
  nest(data = c(treatment, screen_num, num_visit_screen, x, y, time, trial)) %>%
  # Calculate statistics for each subject using process_possibly function
  mutate(stats = map(data, ~ process_possibly(.x))) %>%
  # Pivot wider and clean the statistics
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  # Unnest the data and statistics
  unnest(data) %>% 
  unnest(stats)

subject_stats %>% head(100) %>% view()

# Save subject_stats as csv
write_csv(screen_stats ,'subject_data/subject_stats_data.csv')

# fixations for subject 1, trial 1 and 2
# trial_fixations <- subject_data_fin %>%
#   mutate(trial_1= trial) %>% 
#   filter(subject == 1, trial %in% c(1,2)) %>%
#   group_by(subject, trial_1) %>% 
#   nest(data = c(treatment, screen_num, num_visit_screen, x, y, time, trial)) %>% 
#   mutate(stats = map(data, ~ fixations_possibly(.x))) %>% 
#   unnest(stats) 

# trial_fixations %>% view()

trial_stats <- subject_data_fin %>%
  mutate(trial_1= trial) %>% 
  group_by(subject, trial_1) %>% 
  nest(data = c(treatment, screen_num, num_visit_screen, x, y, time, trial)) %>% 
  mutate(stats = map(data, ~ process_possibly(.x))) %>% 
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  unnest(stats) %>% 
  mutate(screen_num = map(data, "screen_num")) %>% 
  mutate(num_visit_screen = map(data, "num_visit_screen")) %>% 
  unnest_longer(c(screen_num, num_visit_screen)) %>% 
  select(-data) %>% 
  select(value, subject, trial_1, screen_num, num_visit_screen,
         everything())
trial_stats %>% head(100) %>% view()

# Save trial_stats as csv
write_csv(trial_stats ,'subject_data/trial_stats_data.csv')

# Calculate screen-level statistics for eye-tracking data ----------------------
screen_stats <- subject_data_fin %>%
  # Group data by subject and screen number
  group_by(subject, screen_num) %>% 
  nest(data = c(treatment, x, y, time, trial)) %>% 
  # Calculate screen-level statistics using custom function process_possibly
  mutate(stats = map(data, ~ process_possibly(.x))) %>% 
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  # Unnest the statistics
  unnest(stats) %>% 
  # Remove the original nested data
  select(-data) %>% 
  # Remove grouping
  ungroup() %>%
  # Rename columns related to trials to be related to screens
  rename_with(~str_replace(., "trial", "screen"), contains("trial")) %>%
  # Select relevant columns
  select(subject, screen_num, mean_no_of_fixations_per_screen,
         mean_duration_of_fixations)
  

screen_stats %>% head(100) %>% view()

# Save screen_stats as csv file
write_csv(screen_stats ,'subject_data/screen_stats_data.csv')

screen_stats_output <- screen_stats %>% 
  # Generate treatment assignments 
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
  mutate(selection = case_when(groups == "group 1" & screen_num %in% 1:7 ~ 1,
                               groups == "group 2" & screen_num %in% 1:9 ~ 1, 
                               T ~ 0)) %>% 
  # Filter rows based on selection
  filter(selection == 1) %>%
  # Remove the temporary selection column
  select(-selection)

 
# Save screen_stats_output as csv file
write_csv(screen_stats_output ,'subject_data/screen_stats_output.csv')

screen_stats_output %>% head(100) %>% view()
  
#-------------------------------------------------------------------------------
#' Calculate screen view statistics for each subject, screen, and visit 
#' combination.
screen_view_stats <- subject_data_fin %>%
  # Group by subject, screen_num, and num_visit_screen
  group_by(subject, screen_num, num_visit_screen) %>%
  # Nest data for each group
  nest(data = c(treatment, x, y, time, trial)) %>% 
  # Calculate statistics for nested data using process_possibly
  mutate(stats = map(data, ~ process_possibly(.x))) %>% 
  # Pivot and clean the resulting statistics
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  # Unnest the statistics
  unnest(stats) %>% 
  # Select relevant columns and remove the nested data column
  select(-data) %>% 
  # Ungroup the data
  ungroup() %>%
  # Rename columns with trial to screen_visit
  rename_with(~str_replace(., "trial", "screen_visit"), contains("trial")) %>% 
  # Select specific columns for the final output
  select(subject, screen_num, num_visit_screen, mean_no_of_fixations_per_screen_visit,
         mean_duration_of_fixations)

screen_view_stats %>% head(100) %>% view()

# Save screen_view_stats_output as csv file
write_csv(screen_view_stats ,'subject_data/screen_view_stats_output.csv')


#-------------------------------------------------------------------------------
#' Compute statistics for each subject based on the provided data.
subject_stats <- subject_data_fin %>%
  # Group data by subject
  group_by(subject) %>% 
  nest(data = c(treatment, screen_num, num_visit_screen, x, y, time, trial)) %>% 
  # Compute statistics for each group
  mutate(stats = map(data, ~ process_possibly(.x))) %>% 
  # Pivot and clean the computed statistics
  mutate(stats = map(stats, ~ pivot_wider_and_clean(.x))) %>% 
  unnest(stats) %>% 
  # Select relevant columns and remove unnecessary ones
  select(-c(data, value)) %>% 
  ungroup() %>%
  # Rename columns with subject-specific information
  rename_with(~str_replace(., "trial", "subject"), 
              contains("trial")) %>%
  # Select final set of columns
  select(subject, 
         mean_duration_of_subjects,
         mean_duration_of_fixations,
         mean_no_of_fixations_per_subject)  
  

subject_stats %>% head(100) %>% view()

# Save as csv
write_csv(subject_stats ,'subject_data/subject_stats.csv')




