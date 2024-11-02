# Load necessary libraries
library(baseballr)
library(dplyr)
library(data.table)

# Open csv files & put into 1 file
savant_data_2015 <- read.csv("savant_data_2015.csv", header = TRUE)
savant_data_2016 <- read.csv("savant_data_2016.csv", header = TRUE)
savant_data_2017 <- read.csv("savant_data_2017.csv", header = TRUE)
savant_data_2018 <- read.csv("savant_data_2018.csv", header = TRUE)
savant_data_2019 <- read.csv("savant_data_2019.csv", header = TRUE)
savant_data_2020 <- read.csv("savant_data_2020.csv", header = TRUE)
savant_data_2021 <- read.csv("savant_data_2021.csv", header = TRUE)
savant_data_2022 <- read.csv("savant_data_2022.csv", header = TRUE)
savant_data_2023 <- read.csv("savant_data_2023.csv", header = TRUE)
savant_data_2024 <- read.csv("savant_data_2024.csv", header = TRUE)
savantlist <- list(savant_data_2015, savant_data_2016, savant_data_2017, savant_data_2018,
                   savant_data_2019, savant_data_2020, savant_data_2021, savant_data_2022, 
                   savant_data_2023, savant_data_2024) 
savant_data <- rbindlist(savantlist, fill = TRUE)
rm(savant_data_2015, savant_data_2016, savant_data_2017, savant_data_2018,
   savant_data_2019, savant_data_2020, savant_data_2021, savant_data_2022, 
   savant_data_2023, savant_data_2024, savantlist)
