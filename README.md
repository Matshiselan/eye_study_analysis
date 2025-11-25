# Eye Study Analysis Report

## Overview

This repository contains the complete analysis pipeline for an eye-tracking study that processes fixation data across multiple subjects, screens, and visits. The analysis follows reproducible research principles and implements efficient data processing workflows.

## Project Structure

```
eye_study/
├── data/
│   └── PhD data shared/
│       └── Mapped data per subject (per trial)/
├── subject_data/
│   ├── subject_data.csv
│   ├── subject_stats.csv
│   ├── screen_stats_data.csv
│   ├── screen_view_stats_output.csv
│   └── fixation_stats.csv
├── functions.R
└── eye_study_analysis_report.Rmd
```

## Requirements

### R Packages
- `tidyverse` - for data manipulation and visualization
- `janitor` - for data cleaning and tidying
- `saccades` - for eye movement analysis (install from GitHub)
- `devtools` - for installing GitHub packages

### Installation
```r
# Install from CRAN
install.packages(c("tidyverse", "janitor", "devtools"))

# Install saccades from GitHub
devtools::install_github("tmalsburg/saccades/saccades", dependencies = TRUE)
```

## Analysis Pipeline

### 1. Data Extraction and Combination
- Reads individual subject CSV files from nested folders
- Combines all subject data into a single master dataset
- Handles data structure inconsistencies and missing values
- Saves combined data as `subject_data.csv`

### 2. Fixation Analysis Levels

The analysis is performed at three hierarchical levels:

#### A. Subject Level (`subject_stats.csv`)
- Overall fixation statistics per subject
- Mean number of fixations per subject
- Mean duration of fixations

#### B. Subject × Screen Level (`screen_stats_data.csv`)
- Fixation statistics for each subject-screen combination
- Filters screens based on treatment groups:
  - Treatments 1-4: Screens 1-7
  - Treatments 5-8: Screens 1-9

#### C. Subject × Screen × Visit Level (`screen_view_stats_output.csv`)
- Most granular level of analysis
- Fixation statistics for each screen visit
- Tracks multiple visits to the same screen

### 3. Final Combined Dataset (`fixation_stats.csv`)
- Merges all three analysis levels into a single comprehensive dataset
- Includes source identifiers for each analysis level

## Key Features

### Reproducible Workflow
- Project-based organization eliminates need for `setwd()`
- Consistent folder structure across different environments
- Modular function-based approach

### DRY Principle Implementation
- Custom functions stored in `functions.R`
- Reusable data processing pipelines
- Consistent statistical calculations across analysis levels

### Data Quality Checks
- Missing value analysis for critical columns (x, y, time, trial)
- Treatment group assignment validation
- Screen number filtering based on experimental design

## Usage

1. **Setup**: Create an R Project following the folder structure above
2. **Data Preparation**: Place raw data in `data/PhD data shared/Mapped data per subject (per trial)/`
3. **Run Analysis**: Execute the R Markdown file to generate all outputs
4. **Results**: Access processed data in the `subject_data/` folder

## Output Files

- `subject_data.csv` - Raw combined data from all subjects
- `subject_stats.csv` - Subject-level fixation statistics
- `screen_stats_data.csv` - Screen-level fixation statistics  
- `screen_view_stats_output.csv` - Screen-visit level fixation statistics
- `fixation_stats.csv` - Combined dataset of all analysis levels

## Treatment Groups

- **Subjects 1-33**: Treatment 1
- **Subjects 34-66**: Treatment 2  
- **Subjects 67-96**: Treatment 3
- **Subjects 97-128**: Treatment 4
- **Subjects 129-160**: Treatment 5
- **Subjects 161-193**: Treatment 6
- **Subjects 194-227**: Treatment 7
- **Remaining Subjects**: Treatment 8

## Note

The data extraction step may take considerable time to run due to the large number of individual CSV files being processed and combined.