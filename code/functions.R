################################################################################

## Authors: Evander Nyoni & Ntandoyenkosi Matshisela

## Description: Eye Tracking Study functions

## Date: 2 February 2024

## GitHub: --

################################################################################


csv_reader <- function(folder_path){
  
  #' This function takes a folder path as input, reads all CSV files within the
  #' folder, and combines them into a single data frame.
  #'
  #' @param 
  #' ------
  #' folder_path: The path to the folder containing CSV files.
  #'
  #' @return:
  #' -------
  #'        : A data frame containing the combined data from all CSV files.
  #'
  #' @examples:
  #' ----------
  #' folder_path <- "path/to/csv/files"
  #' combined_data <- csv_reader(folder_path)
  
  
  # Get a list of all CSV files in the folder
  csv_files <- list.files(folder_path, pattern = "\\.csv$", 
                          full.names = TRUE)
  
  # Read all CSV files and combine them into one data frame
  suppressMessages({
    combined_data <- map_dfr(csv_files, read_csv)
  })
  
  
  # Return the combined data
  combined_data
  
  
}


# Define a function to process each subject
process_subject <- function(subject_data) {
  
  #' This function takes subject data and detects fixations using the 
  #' detect.fixations function. It then subsets the fixations to include only 
  #' those with the event type "fixation".
  #'
  #' @param
  #' ------
  #' subject_data: The data for a specific subject.
  #' 
  #' @return
  #' -------
  #'        : A data frame containing fixations for the given subject.
  #'
  #' @examples
  #' ---------
  #' subject_data <- read.csv("subject_data.csv")
  #' fixations_data <- process_subject(subject_data)
  
  # Detect fixations using smooth coordinates and saccades
  fixations <- subset(detect.fixations(subject_data, 
                                       smooth.coordinates = TRUE, 
                                       smooth.saccades = F), 
                      event == "fixation")
  
  # Create a diagnostic plot
  # diagnostic_plot <- diagnostic.plot(subject_data, fixations,
  #                                    start.time=2000,
  #                                    duration=10000,
  #                                    interactive=F,
  #                                    ylim=c(0,1000))
  
  
  
  # Calculate summary statistics
  stats <- calculate.summary(fixations)
  stats <- round(stats, digits = 2)
  stats$row_names <- row.names(stats)
  stats <- stats %>% select(row_names, mean, sd)
  
  # Save the plot and statistics
  subject_id <- unique(subject_data$subject)
  plot_filename <- paste0("subject_data/plots/", subject_id, "_plot.png")
  # stats_filename <- paste0("subject_data/stats/", subject_id, "_stats.txt")
  stats_filename_csv <- paste0("subject_data/stats/", subject_id, "_stats.csv")
  
  
  ggsave(plot_filename, diagnostic_plot)
  write_csv(stats, stats_filename_csv)
  # write.table(stats, stats_filename, sep = "\t", row.names = T)
  
  # Return the filenames for reference
  #return(list(plot_filename = plot_filename, stats_filename = stats_filename))
}


# Define the process_subject function
process_trial <- function(subject_data) {
  #' This function takes subject data as input, detects fixations, calculates 
  #' summary statistics, and performs data wrangling to return a processed data 
  #' frame.
  #'
  #' @param
  #' ------
  #' subject_data: A data frame containing subject-specific eye-tracking data.
  #' 
  #' @return
  #' -------
  #'        :A data frame with summary statistics for fixations.
  #'
  #' @examples
  #' ---------
  #' processed_data <- process_trial(my_subject_data)
  #'
  
  
  # Detect fixations 
  fixations <- detect.fixations(subject_data, 
                                smooth.coordinates = TRUE, 
                                smooth.saccades = F)
  
  
  # Calculate summary statistics and round to 2 decimal places
  stats <- calculate.summary(fixations)
  stats <- round(stats, digits = 2)
  stats$row_names <- row.names(stats)
  stats <- stats %>% select(row_names, mean, sd)
  
  # Data wrangling
  # stats_fin <- stats %>%
  #   rownames_to_column() %>%
  #   pivot_longer(-rowname) %>%
  #   pivot_wider(names_from = rowname, values_from = value) %>%
  #   janitor::clean_names() %>%
  #   slice(1)
  
  stats
}

process_possibly <- possibly(process_trial, otherwise = NA)


# Define a function to pivot wider and clean column names, handling errors
pivot_wider_and_clean <- possibly(function(x) {
  
  #' This function takes a data frame, pivots it wider using the specified row 
  #' names, calculates mean and standard deviation for each group, and then 
  #' cleans the column names.
  #'
  #' @param
  #' ------
  #'     x: A data frame to be processed.
  #'
  #' @return
  #' ------- 
  #'        :A data frame with wider pivoted columns containing mean and 
  #'         standard deviation values,and cleaned column names.
  #'
  #' @examples
  #' ---------
  #' result <- pivot_wider_and_clean(my_data_frame)
  #' print(result)
  #'
  
  # Pivot the data wider using row names and calculate mean and sd
  stats_wide <- pivot_wider(data = x, names_from = row_names, 
                            values_from = c(mean, sd))
  # Clean the column names
  stats_clean <- stats_wide %>% clean_names()
  
  # Return the cleaned and pivoted data
  return(stats_clean)
}, otherwise = NULL)


# fixations function
fixation_trial <- function(subject_data) {
  
  #' This function detects fixations in eye-tracking data using the provided subject data.
  #'
  #' @param
  #' ------
  #' subject_data: A data frame containing eye-tracking data for a specific subject.
  #' 
  #' @return
  #' -------
  #'fixations: A data frame representing fixations detected in the eye-tracking data.
  #' 
  #' @examples
  #' ---------
  #' # fixation_data <- fixation_trial(my_subject_data)
  #' 
  
  
  # Detect fixations using external function detect.fixations
  # Parameters:
  # - subject_data: Eye-tracking data for the subject
  # - smooth.coordinates: Perform smoothing on eye coordinates (default: TRUE)
  # - smooth.saccades: Perform smoothing on saccade data (default: TRUE)
  fixations <- detect.fixations(subject_data, 
                                smooth.coordinates = TRUE, 
                                smooth.saccades = F)
  
  
  fixations
}

# Wrapper function for possibly handling errors in fixation_trial
fixations_possibly <- possibly(fixation_trial, otherwise = NA)





data_splitter <- function(df){
  
  data <- df %>% 
    group_nest(subject)
  
  
  by_data <- data %>% 
    mutate(path = str_glue("individual_data_{subject}.csv"))
  
  
  walk2(by_data$data, by_data$path, write_csv)
  
}






